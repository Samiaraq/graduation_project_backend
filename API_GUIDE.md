# Graduation Project API Guide

This document provides an overview of the backend API developed for the
Graduation Project. The API is responsible for handling user authentication,
psychological assessments, and data storage.

---

## Base URL
https://graduation-project-backend-bx8k.onrender.com

---

## Technology Stack

- **Backend Framework:** FastAPI (Python)
- **Database:** PostgreSQL
- **ORM:** SQLAlchemy
- **Deployment:** Render (Cloud Platform)
- **API Documentation:** Swagger UI (`/docs`)

---

## Available Endpoints

### 🔐 Authentication

#### Register User
**POST** `/auth/register`

Registers a new user in the system.

#### Login User
**POST** `/auth/login`

Authenticates an existing user.

---

### 🧠 Psychological Assessments

#### Submit PHQ-9
**POST** `/phq/submit`

Submits PHQ-9 questionnaire answers and stores the calculated result.

#### Create Combined Assessment
**POST** `/assessments`

Submits a combined assessment that may include:
- PHQ-9 answers
- Optional text input
- Optional image upload

This endpoint is designed to support multi-modal data collection.

---

### 💬 Sentiment Data

#### Save Sentiment
**POST** `/sentiment`

Stores user text and sentiment analysis results for later evaluation.

---

### 🖼️ Image Data

#### Upload Image
**POST** `/image`

Uploads an image and stores its metadata for future processing.

---

## Request & Response Format

- All API requests and responses use **JSON**
- File uploads use **multipart/form-data**
- Each request is validated before processing
- Meaningful HTTP status codes are returned

---

## Database Design

The database follows a **relational schema** with normalized tables.

- User information is stored in the `users` table
- Each assessment type (PHQ-9, sentiment, image) is stored in a separate table
- All assessment records are linked to users using foreign keys (`user_id`)

This structure reduces redundancy and supports scalability.

---

## Security Notes

- Passwords are stored using secure hashing
- Sensitive configuration values are managed through environment variables
- Database access is handled via ORM to prevent SQL injection

---

## Deployment Notes

- The API is deployed on Render with Auto-Deploy enabled from GitHub
- The backend is designed to be cloud-ready and scalable
- Persistent database storage is maintained across deployments

---

## Health Check

**GET** `/health`

Returns the current status of the API and confirms service availability.

---

## Future Improvements

- Token-based authentication (JWT)
- Full AI model inference for sentiment and image analysis
- Advanced role-based access control
- Improved logging and monitoring

---

