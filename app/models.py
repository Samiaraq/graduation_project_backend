from sqlalchemy import Column, Integer, String
from .database import Base

from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    dob = Column(String, nullable=True)
    gender = Column(String, nullable=True)


class PHQ9Answer(Base):
    __tablename__ = "phq9_answers"

    phq_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"))

    q1 = Column(Integer)
    q2 = Column(Integer)
    q3 = Column(Integer)
    q4 = Column(Integer)
    q5 = Column(Integer)
    q6 = Column(Integer)
    q7 = Column(Integer)
    q8 = Column(Integer)
    q9 = Column(Integer)

    total_score = Column(Integer)
    depression_level = Column(String(50))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

