import os
import json
import hashlib
from typing import Optional, List
from datetime import date
import datetime
import torch
import traceback
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session
from .database import engine, get_db
from . import models

# ----------------------------
# ML imports (داخل try حتى ما يكسر الديبلوي)
# ----------------------------
try:
    from app.ml_models.image.loader import predict_image
except Exception:
    predict_image = None

try:
    from app.ml_models.sentimant.predict import predict_depression_text
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


# ----------------------------
# Startup
# ----------------------------
@app.on_event("startup")
def on_startup():
    global phq9_model

    models.Base.metadata.create_all(bind=engine)
    # تحميل موديل PHQ (إذا موجود)
    if load_phq9_model and MLP:
        try:
            # ✅ مرري الـ CLASS نفسه (زي شغلك الحالي)
            phq9_model = load_phq9_model(MLP)
            print("PHQ9 model loaded ✅")
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
from sqlalchemy import text

@app.get("/db-ping")
def db_ping(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        return {"ok": True}
    except Exception as e:
        # ✅ هذا أهم سطر: يطبع السبب الحقيقي في Logs تبعون Render
        print("DB PING ERROR:", repr(e))
        raise HTTPException(status_code=500, detail=f"DB connection failed: {repr(e)}")

# ----------------------------
# Helpers (DOB)
# DB عندك dob VARCHAR(50) => نخزن dob نص
# ----------------------------
def normalize_dob_str(dob_str: Optional[str]) -> Optional[str]:
    if not dob_str:
        return None
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y", "%Y/%m/%d"):
        try:
            dt = datetime.datetime.strptime(dob_str, fmt).date()
            return dt.strftime("%Y-%m-%d")  # نخزنه كنص موحّد
        except ValueError:
            continue
    return dob_str


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
    try:
        existing = db.query(models.User).filter(models.User.email == payload.email).first()
    except Exception as e:
        print("DB ERROR in /auth/register:", repr(e))
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Database error. Check server logs.")
    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()

    user = models.User(
        username=payload.username,
        email=payload.email,
        password_hash=password_hash,
        dob=normalize_dob_str(payload.dob),     # ✅ string (مو date)
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


PHQ_LEVELS_5 = ["Minimal", "Mild", "Moderate", "Moderately Severe", "Severe"]


def calc_age(dob_str: str) -> int:
    if not dob_str:
        return 0
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y", "%Y/%m/%d"):
        try:
            dt = datetime.datetime.strptime(dob_str, fmt).date()
            today = date.today()
            age = today.year - dt.year - ((today.month, today.day) < (dt.month, dt.day))
            return max(age, 0)
        except Exception:
            continue
    return 0


# ✅ نفس دالة التدريب بالزبط
def age_to_group(age: int) -> int:
    if age < 18:
        return 0
    elif age < 30:
        return 1
    elif age < 50:
        return 2
    else:
        return 3


@app.post("/phq/submit")
def submit_phq(payload: PHQRequest, db: Session = Depends(get_db)):
    user = ensure_user_exists(db, payload.user_id)

    answers = [int(x) for x in payload.phq_answers]
    if len(answers) != 9:
        raise HTTPException(status_code=400, detail="phq_answers must contain exactly 9 numbers")

    # (A) نخزن التقليدي
    total = sum(answers)
    level_rule = phq_level_from_score(total)
    level_rule_ar = PHQ_AR.get(level_rule, level_rule)

    phq_row = models.PHQ9Answer(
        user_id=payload.user_id,
        q1=answers[0], q2=answers[1], q3=answers[2],
        q4=answers[3], q5=answers[4], q6=answers[5],
        q7=answers[6], q8=answers[7], q9=answers[8],
        total_score=total,
        depression_level=level_rule,
    )
    db.add(phq_row)

    # (B) تنبؤ الموديل (11 مدخل: 9 + gender + age_group) ✅ مطابق للتدريب
    model_level = None
    model_level_ar = None
    model_class = None

    if phq9_model is not None:
        # age_group بدل age الحقيقي
        age_real = calc_age(user.dob) if user.dob else 0
        age_group = age_to_group(age_real)

        # ✅ gender نفس التدريب: F=0 / M=1
        g = (user.gender or "").strip().lower()
        if g in ["m", "male", "ذكر", "ولد", "رجل", "man"]:
            gender_val = 1
        elif g in ["f", "female", "أنثى", "انثى", "بنت", "امرأة", "woman"]:
            gender_val = 0
        else:
            gender_val = 0  # default آمن

        # ✅ ترتيب الأعمدة مثل التدريب تماماً: q1..q9, gender, age_group
        x = answers + [gender_val, age_group]  # 11
        from app.ml_models.model_loader import scale_phq_input
        import numpy as np
        x_np = np.array([x], dtype=np.float32)  # shape (1, 11)
        x_scaled = scale_phq_input(x_np)

        with torch.no_grad():
            inp = torch.tensor(x_scaled, dtype=torch.float32)
            logits = phq9_model(inp)
            model_class = int(torch.argmax(logits, dim=1).item())
            model_level = PHQ_LEVELS_5[model_class]
            model_level_ar = PHQ_AR.get(model_level, model_level)

        db.add(models.DepressionLevel(
            user_id=payload.user_id,
            source="phq_model",
            score=model_class,   # 0..4
            level=model_level,
        ))

    # نخزن كمان التقليدي
    db.add(models.DepressionLevel(
        user_id=payload.user_id,
        source="phq9",
        score=total,
        level=level_rule,
    ))

    db.commit()
    db.refresh(phq_row)

    return {
        "message": "phq saved",
        "phq_id": getattr(phq_row, "phq_id", None) or phq_row.id,
        "user_id": payload.user_id,
        "phq_total": total,
        "phq_level": level_rule,
        "phq_level_ar": level_rule_ar,
        "model_level": model_level,
        "model_level_ar": model_level_ar,
        "model_class": model_class,
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

    try:
        label = predict_depression_text(payload.text)
    except Exception as e:
        # بدل ما يوقع السيرفر ويصير 502
        raise HTTPException(status_code=503, detail=f"Sentiment failed/warming up: {str(e)}")

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
        score=0,
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
        score=int(prob * 100),
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