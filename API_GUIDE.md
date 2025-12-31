# Graduation Project API Guide

## Base URL
https://graduation-project-backend-bx8k.onrender.com

---

## Technology Stack
- FastAPI (Python)
- PostgreSQL
- SQLAlchemy ORM
- Deployed on Render
- Swagger UI: `/docs`

---

## Authentication

### Register
**POST** `/auth/register`

**Body (JSON):**
```json
{
  "username": "rama",
  "email": "rama@email.com",
  "password": "123456",
  "dob": "2002-01-01",
  "gender": "female"
}
