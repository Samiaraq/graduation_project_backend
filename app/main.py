import os
import json
import hashlib
from typing import Optional, List

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session

from .database import engine, get_db
from . import models

# ML imports (خليهم داخل try عشان ما يكسروا الديبلوي لو ناقص dependency)
try:
    from app.ml_models.image.loader import predict_image
except Exception:
    predict_image = None

try:
    from app.ml_models.sentemant.predict import predict_depression_text
except Exception:
    predict_depression_text = None

# PHQ model loader
try:
    from app.ml_models.phq_9.model_def import MLP
    from app.ml_models.model_loader import load_phq9_model
except Exception:
    MLP = None
    load_phq9_model = None



app = FastAPI(title="Graduation Project API")

os.makedirs("uploads", exist_ok=True)

phq9_model = None


def build_phq9_mlp():
    """
    حسب كودك: MLP(in_dim, num_classes)
    للـ PHQ غالبًا output واحد (1)
    """
    return MLP(9, 1)


@app.on_event("startup")
def on_startup():
    global phq9_model

    models.Base.metadata.create_all(bind=engine)

    # PHQ9 load
    if load_phq9_model and MLP:
        try:
            phq9_model = load_phq9_model(build_phq9_mlp)  # loader لازم يقبل callable
            print("PHQ9 model loaded:", type(phq9_model))
        except Exception as e:
            phq9_model = None
            print("WARNING: PHQ9 model failed to load:", repr(e))
    else:
        print("PHQ9 loader not available (skipped).")


@app.get("/")
def root():
    return {"message": "API is running"}


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "phq_model_loaded": phq9_model is not None,
        "image_model_loaded": predict_image is not None,
        "sentiment_model_loaded": predict_depression_text is not None,
    }


# ----------------------------
# Auth schemas
# ----------------------------
class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str
    dob: Optional[str] = None
    gender: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str


@app.post("/auth/register")
def register_user(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(models.User).filter(models.User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()

    user = models.User(
        username=payload.username,
        email=payload.email,
        password_hash=password_hash,
        dob=payload.dob,
        gender=payload.gender,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "message": "User registered successfully",
        "user_id": user.user_id,
        "username": user.username,
        "email": user.email,
    }


@app.post("/auth/login")
def login_user(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()
    if user.password_hash != password_hash:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {
        "message": "Login successful",
        "user_id": user.user_id,
        "username": user.username,
        "email": user.email,
    }


# ----------------------------
# Helpers
# ----------------------------
def ensure_user_exists(db: Session, user_id: int):
    user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="user_id not found")
    return user


def phq_level_from_score(total: int) -> str:
    if total <= 4:
        return "Minimal"
    if total <= 9:
        return "Mild"
    if total <= 14:
        return "Moderate"
    if total <= 19:
        return "Moderately Severe"
    return "Severe"


PHQ_AR = {
    "Minimal": "طبيعي/بسيط جدًا",
    "Mild": "خفيف",
    "Moderate": "متوسط",
    "Moderately Severe": "شديد نسبيًا",
    "Severe": "شديد",
}


def parse_phq_answers(phq_answers: str) -> List[int]:
    raw = (phq_answers or "").strip()
    try:
        ans = json.loads(raw)
        if isinstance(ans, list):
            return [int(x) for x in ans]
    except Exception:
        pass

    raw = raw.strip("[]() \n\r\t")
    return [int(x.strip()) for x in raw.split(",") if x.strip() != ""]


# ----------------------------
# PHQ submit (JSON)
# ----------------------------
class PHQRequest(BaseModel):
    user_id: int
    phq_answers: List[int]


@app.post("/phq/submit")
def submit_phq(payload: PHQRequest, db: Session = Depends(get_db)):
    ensure_user_exists(db, payload.user_id)

    answers = [int(x) for x in payload.phq_answers]
    if len(answers) != 9:
        raise HTTPException(status_code=400, detail="phq_answers must contain exactly 9 numbers")

    total = sum(answers)
    level = phq_level_from_score(total)
    level_ar = PHQ_AR.get(level, level)

    phq_row = models.PHQ9Answer(
        user_id=payload.user_id,
        q1=answers[0], q2=answers[1], q3=answers[2],
        q4=answers[3], q5=answers[4], q6=answers[5],
        q7=answers[6], q8=answers[7], q9=answers[8],
        total_score=total,
        depression_level=level,
    )
    db.add(phq_row)

    db.add(models.DepressionLevel(
        user_id=payload.user_id,
        source="phq9",
        score=total,
        level=level,
    ))

    db.commit()
    db.refresh(phq_row)

    return {
        "message": "phq saved",
        "phq_id": phq_row.phq_id,
        "user_id": payload.user_id,
        "phq_total": total,
        "phq_level": level,
        "phq_level_ar": level_ar,
        "answers": answers,
    }


# ----------------------------
# Sentiment predict
# ----------------------------
class SentimentRequest(BaseModel):
    user_id: int
    text: str


@app.post("/sentiment/predict")
def sentiment_predict(payload: SentimentRequest, db: Session = Depends(get_db)):
    ensure_user_exists(db, payload.user_id)

    if predict_depression_text is None:
        raise HTTPException(status_code=503, detail="Sentiment model not loaded on server")

    label = predict_depression_text(payload.text)

    row = models.SentimentEntry(
        user_id=payload.user_id,
        raw_text=payload.text,
        processed_text=None,
        prediction=label,
    )
    db.add(row)

    db.add(models.DepressionLevel(
        user_id=payload.user_id,
        source="sentiment",
        score=None,
        level=label,
    ))

    db.commit()
    db.refresh(row)

    return {
        "message": "sentiment predicted",
        "user_id": payload.user_id,
        "label": label,
        "sentiment_id": row.sentiment_id,
    }


# ----------------------------
# Image endpoint (upload + predict)
# ----------------------------
@app.post("/image")
async def upload_image(
    user_id: int = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    ensure_user_exists(db, user_id)

    if predict_image is None:
        raise HTTPException(status_code=503, detail="Image model not loaded on server")

    safe_name = image.filename.replace("/", "_").replace("\\", "_")
    file_path = os.path.join("uploads", safe_name)

    with open(file_path, "wb") as f:
        f.write(await image.read())

    prob = predict_image(file_path)  # 0..1
    pred = 1 if prob >= 0.5 else 0
    label = "depressed" if pred == 1 else "not_depressed"

    row = models.ImageUpload(
        user_id=user_id,
        image_path=file_path,
        prediction=str(pred),
    )
    db.add(row)

    db.add(models.DepressionLevel(
        user_id=user_id,
        source="image",
        score=int(prob * 100),   # نسبة مئوية مثلاً
        level=label,
    ))

    db.commit()
    db.refresh(row)

    return {
        "message": "image saved",
        "image_id": row.image_id,
        "image_path": file_path,
        "probability": prob,
        "prediction": pred,
        "label": label,
    }
