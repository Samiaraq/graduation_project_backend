import os
import json
import hashlib
from typing import Optional, List

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session

from .database import engine, get_db
from . import models

# ML
from app.models import MLP
from app.ml_models.model_loader import load_phq9_model


app = FastAPI(title="Graduation Project API")

# uploads folder (ملاحظة: على Render الملفات مش دائمة إلا إذا فعلتي Disk)
os.makedirs("uploads", exist_ok=True)

phq9_model = None


def build_phq9_mlp():
    """
    بنحاول نركّب MLP حسب ال signature الموجود عندك.
    لأن الخطأ على Render بيحكي إنه MLP بدها باراميترز إلزامية.
    """
    # جرّبي أكثر من شكل (positional + named) لحتى يزبط مع أي constructor
    tries = [
        lambda: MLP(),                              # إذا عنده defaults
        lambda: MLP(9, 64),                         # (input_dim, hidden_dim)
        lambda: MLP(9, 128),
        lambda: MLP(input_size=9, hidden_size=64),  # (input_size, hidden_size)
        lambda: MLP(input_dim=9, hidden_dim=64),    # (input_dim, hidden_dim)
        lambda: MLP(n_features=9, hidden=64),       # تسميات بديلة
    ]

    last_err = None
    for t in tries:
        try:
            return t()
        except TypeError as e:
            last_err = e

    # إذا ولا محاولة زبطت
    raise TypeError(f"Could not build MLP for PHQ9. Last error: {last_err}")


@app.on_event("startup")
def on_startup():
    global phq9_model

    # Create tables if not exist
    models.Base.metadata.create_all(bind=engine)

    # Load PHQ-9 model once (بس بطريقة ما تكسّر الديبلوي)
    try:
        # مهم: نمرر factory/function مش الكلاس مباشرة
        # عشان model_loader لما يعمل model_class() يطلع موديل جاهز بالباراميترز
        phq9_model = load_phq9_model(build_phq9_mlp)
        print("PHQ9 model loaded:", type(phq9_model))
    except Exception as e:
        # ما نخلي السيرفر يوقع
        phq9_model = None
        print("WARNING: PHQ9 model failed to load. App will run بدون PHQ model.")
        print("ERROR:", repr(e))


# ----------------------------
# Basic endpoints
# ----------------------------
@app.get("/")
def root():
    return {"message": "API is running"}


@app.get("/health")
def health_check():
    return {"status": "ok", "phq_model_loaded": phq9_model is not None}


# ----------------------------
# Auth schemas
# ----------------------------
class RegisterRequest(BaseModel):
    email: str
    password: str
    dob: Optional[str] = None
    gender: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str


# ----------------------------
# Auth endpoints
# ----------------------------
@app.post("/auth/register")
def register_user(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(models.User).filter(models.User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()

    user = models.User(
        email=payload.email,
        password_hash=password_hash,
        dob=payload.dob,
        gender=payload.gender,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully", "user_id": user.user_id}


@app.post("/auth/login")
def login_user(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()
    if user.password_hash != password_hash:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"message": "Login successful", "user_id": user.user_id}


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

    # JSON list
    try:
        ans = json.loads(raw)
        if isinstance(ans, list):
            return [int(x) for x in ans]
    except Exception:
        pass

    # comma separated
    raw = raw.strip("[]() \n\r\t")
    return [int(x.strip()) for x in raw.split(",") if x.strip() != ""]


# ----------------------------
# PHQ submit endpoint (JSON body)
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
        "phq_id": getattr(phq_row, "id", None),
        "user_id": payload.user_id,
        "phq_total": total,
        "phq_level": level,
        "phq_level_ar": level_ar,
        "answers": answers,
        "phq_model_loaded": phq9_model is not None,
    }


# ----------------------------
# Assessments endpoint (PHQ + image upload path)
# ----------------------------
@app.post("/assessments")
async def create_assessment(
    user_id: int = Form(...),
    text_input: str = Form(""),
    phq_answers: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    ensure_user_exists(db, user_id)

    answers = parse_phq_answers(phq_answers)
    if len(answers) != 9:
        raise HTTPException(status_code=400, detail="phq_answers must contain exactly 9 numbers")

    total = sum(int(x) for x in answers)
    level = phq_level_from_score(total)
    level_ar = PHQ_AR.get(level, level)

    # save PHQ row
    phq_row = models.PHQ9Answer(
        user_id=user_id,
        q1=answers[0], q2=answers[1], q3=answers[2],
        q4=answers[3], q5=answers[4], q6=answers[5],
        q7=answers[6], q8=answers[7], q9=answers[8],
        total_score=total,
        depression_level=level,
    )
    db.add(phq_row)

    # save depression_levels row (source=phq9)
    db.add(models.DepressionLevel(
        user_id=user_id,
        source="phq9",
        score=total,
        level=level,
    ))

    # save image locally (مؤقت)
    safe_name = image.filename.replace("/", "_").replace("\\", "_")
    file_path = os.path.join("uploads", safe_name)
    with open(file_path, "wb") as f:
        f.write(await image.read())

    # store image_upload row
    db.add(models.ImageUpload(
        user_id=user_id,
        image_path=file_path,
        prediction=None,
    ))

    db.commit()

    return {
        "message": "assessment received",
        "user_id": user_id,
        "text_input": text_input,
        "phq_total": total,
        "phq_level": level,
        "phq_level_ar": level_ar,
        "image_saved_as": file_path,
        "phq_model_loaded": phq9_model is not None,
    }


# ----------------------------
# Sentiment endpoint
# ----------------------------
class SentimentRequest(BaseModel):
    user_id: int
    raw_text: str
    processed_text: Optional[str] = None
    prediction: Optional[str] = None


@app.post("/sentiment")
def save_sentiment(payload: SentimentRequest, db: Session = Depends(get_db)):
    ensure_user_exists(db, payload.user_id)

    row = models.SentimentEntry(
        user_id=payload.user_id,
        raw_text=payload.raw_text,
        processed_text=payload.processed_text,
        prediction=payload.prediction,
    )
    db.add(row)

    if payload.prediction is not None:
        db.add(models.DepressionLevel(
            user_id=payload.user_id,
            source="sentiment",
            score=None,
            level=payload.prediction,
        ))

    db.commit()
    db.refresh(row)

    return {"message": "sentiment saved", "sentiment_id": row.sentiment_id}


# ----------------------------
# Image endpoint (يحفظ صورة + prediction)
# ----------------------------
@app.post("/image")
async def upload_image(
    user_id: int = Form(...),
    prediction: str = Form(""),
    image: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    ensure_user_exists(db, user_id)

    safe_name = image.filename.replace("/", "_").replace("\\", "_")
    file_path = os.path.join("uploads", safe_name)
    with open(file_path, "wb") as f:
        f.write(await image.read())

    row = models.ImageUpload(
        user_id=user_id,
        image_path=file_path,
        prediction=prediction or None,
    )
    db.add(row)

    if prediction:
        db.add(models.DepressionLevel(
            user_id=user_id,
            source="image",
            score=None,
            level=prediction,
        ))

    db.commit()
    db.refresh(row)

    return {"message": "image saved", "image_id": row.image_id, "image_path": file_path}
