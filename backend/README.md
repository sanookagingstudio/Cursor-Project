# Media Creator Core Foundation - Backend

## 🚀 Phase 1: Core Foundation

Backend API สำหรับ Media Creator System

---

## 📋 Tech Stack

- **FastAPI** - Web framework
- **PostgreSQL** - Database (via Supabase)
- **Redis** - Cache & Queue
- **Celery** - Task queue
- **SQLAlchemy** - ORM
- **Alembic** - Database migrations

---

## 🏗️ Project Structure

```
backend/
├── app/
│   ├── core/           # Core configuration
│   │   ├── config.py   # Settings
│   │   ├── db.py       # Database
│   │   ├── redis.py    # Redis
│   │   ├── celery_app.py  # Celery
│   │   └── events.py   # Event Bus
│   ├── models/         # Database models
│   ├── schemas/        # Pydantic schemas
│   ├── routers/        # API routes
│   ├── services/       # Business logic
│   ├── workers/        # Celery workers
│   └── main.py         # FastAPI app
├── alembic/            # Migrations
├── tests/              # Tests
└── requirements.txt    # Dependencies
```

---

## 🚀 Setup

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Setup Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

### 3. Database Migrations

```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Initial schema"

# Apply migration
alembic upgrade head
```

### 4. Run Development Server

```bash
uvicorn app.main:app --reload --port 8000
```

### 5. Run Celery Worker

```bash
celery -A app.core.celery_app worker --loglevel=info
```

---

## 📡 API Endpoints

### Health
- `GET /health` - Health check

### Projects
- `POST /projects` - Create project
- `GET /projects` - List projects
- `GET /projects/{id}` - Get project

### Jobs
- `POST /jobs` - Create job
- `GET /jobs/{id}` - Get job
- `GET /jobs/project/{project_id}` - List project jobs

### Workflows
- `POST /workflows/run` - Run workflow
- `GET /workflows/{id}` - Get workflow

### Modules
- `POST /modules/register` - Register module
- `GET /modules` - List modules
- `GET /modules/{id}` - Get module

### Assets
- `GET /assets/project/{project_id}` - List project assets
- `GET /assets/{id}` - Get asset

---

## 🔧 Development

### Run Tests
```bash
pytest
```

### Format Code
```bash
black app/
```

### Lint Code
```bash
ruff check app/
```

---

## 📚 Documentation

- API Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

---

*Phase 1: Core Foundation - Backend API*

