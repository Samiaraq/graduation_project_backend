import os
import json
import hashlib

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session

from .database import engine, SessionLocal
from . import models
from .models import User

# Create tables if not exist
models.Base.metadata.create_all(bind=engine)

# Ensure uploads folder exists
os.makedirs("uploads", exist_ok=True)

app = FastAPI(title="Graduation Project API")


# ----------------------------
# Basic endpoints
# ----------------------------
@app.get("/")
def root():
    return {"message": "API is running"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


# ----------------------------
# DB dependency
# ----------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ----------------------------
# Auth schemas
# ----------------------------
class RegisterRequest(BaseModel):
    email: str
    password: str
    dob: str | None = None
    gender: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str


# ----------------------------
# Auth endpoints
# ----------------------------
@app.post("/auth/register")
def register_user(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()

    user = User(
        email=payload.email,
        password_hash=password_hash,
        dob=payload.dob,
        gender=payload.gender,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully"}


@app.post("/auth/login")
def login_user(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    password_hash = hashlib.sha256(payload.password.encode()).hexdigest()
    if user.password_hash != password_hash:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"message": "Login successful"}


# ----------------------------
# Assessments endpoint
# ----------------------------
@app.post("/assessments")
async def create_assessment(
    user_id: int = Form(...),
    text_input: str = Form(""),
    phq_answers: str = Form(...),
    image: UploadFile = File(...),
):
    # Parse PHQ answers safely (JSON list or comma-separated)
    try:
        raw = (phq_answers or "").strip()

        try:
            answers = json.loads(raw)
        except Exception:
            raw = raw.strip("[]() \n\r\t")
            answers = [int(x.strip()) for x in raw.split(",") if x.strip() != ""]

        if not isinstance(answers, list) or len(answers) != 9:
            raise HTTPException(status_code=400, detail="phq_answers must contain exactly 9 numbers")

    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid phq_answers format")

    phq_total = sum(int(x) for x in answers)

    # PHQ-9 severity level (EN)
    if phq_total <= 4:
        phq_level = "Minimal"
    elif phq_total <= 9:
        phq_level = "Mild"
    elif phq_total <= 14:
        phq_level = "Moderate"
    elif phq_total <= 19:
        phq_level = "Moderately Severe"
    else:
        phq_level = "Severe"

    # PHQ-9 severity level (AR)
    phq_level_ar_map = {
        "Minimal": "طبيعي/بسيط جدًا",
        "Mild": "خفيف",
        "Moderate": "متوسط",
        "Moderately Severe": "شديد نسبيًا",
        "Severe": "شديد",
    }
    phq_level_ar = phq_level_ar_map.get(phq_level, phq_level)

    # Save image
    file_path = os.path.join("uploads", image.filename)
    with open(file_path, "wb") as f:
        f.write(await image.read())

    return {
        "message": "assessment received",
        "user_id": user_id,
        "text_input": text_input,
        "phq_total": phq_total,
        "phq_level": phq_level,
        "phq_level_ar": phq_level_ar,
        "image_saved_as": file_path,
        "model_score":4,
        "model_lebel_ar":"اكتئاب شديد"
    }