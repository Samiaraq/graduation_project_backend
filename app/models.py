from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

# ----------------------------
# DB Models
# ----------------------------

class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(Text, nullable=False)

    dob = Column(String(50), nullable=True)
    gender = Column(String(20), nullable=True)

    created_at = Column(TIMESTAMP, server_default=func.now())

    phq9_answers = relationship("PHQ9Answer", back_populates="user", cascade="all, delete")
    sentiments = relationship("SentimentEntry", back_populates="user", cascade="all, delete")
    images = relationship("ImageUpload", back_populates="user", cascade="all, delete")
    depression_levels = relationship("DepressionLevel", back_populates="user", cascade="all, delete")
    reset_tokens = relationship("PasswordResetToken", back_populates="user", cascade="all, delete")


class PHQ9Answer(Base):
    __tablename__ = "phq9_answers"

    phq_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)

    q1 = Column(Integer, nullable=False)
    q2 = Column(Integer, nullable=False)
    q3 = Column(Integer, nullable=False)
    q4 = Column(Integer, nullable=False)
    q5 = Column(Integer, nullable=False)
    q6 = Column(Integer, nullable=False)
    q7 = Column(Integer, nullable=False)
    q8 = Column(Integer, nullable=False)
    q9 = Column(Integer, nullable=False)

    total_score = Column(Integer, nullable=False)
    depression_level = Column(String(50), nullable=False)

    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="phq9_answers")


class SentimentEntry(Base):
    __tablename__ = "sentiment_entries"

    sentiment_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)

    raw_text = Column(Text, nullable=True)
    processed_text = Column(Text, nullable=True)
    prediction = Column(String(50), nullable=True)

    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="sentiments")


class ImageUpload(Base):
    __tablename__ = "image_uploads"

    image_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)

    image_path = Column(Text, nullable=True)
    prediction = Column(String(50), nullable=True)

    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="images")


class DepressionLevel(Base):
    __tablename__ = "depression_levels"

    record_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)

    source = Column(String(50), nullable=True)  # phq9/sentiment/image/combined
    score = Column(Integer, nullable=True)
    level = Column(String(50), nullable=True)

    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="depression_levels")


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    token_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)

    token = Column(Text, nullable=False)
    expiration_date = Column(TIMESTAMP, nullable=True)
    used = Column(Boolean, default=False)

    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="reset_tokens")
