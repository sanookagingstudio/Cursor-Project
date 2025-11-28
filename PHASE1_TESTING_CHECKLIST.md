# ✅ Phase 1: Core Foundation - Testing Checklist

## 🎯 เป้าหมาย: ทดสอบให้แน่ใจ 100% ก่อนไป Phase ถัดไป

---

## 📋 Testing Checklist

### 1. Backend Setup ✅

- [ ] Install dependencies
  ```bash
  cd backend
  pip install -r requirements.txt
  ```

- [ ] Setup environment
  ```bash
  cp .env.example .env
  # Edit .env with your settings
  ```

- [ ] Verify structure
  - [ ] All directories exist
  - [ ] All Python files exist
  - [ ] No syntax errors

### 2. Database Setup ✅

- [ ] Run migration
  ```sql
  -- Run: supabase/migrations/20251128000000_core_foundation.sql
  ```

- [ ] Verify tables created
  - [ ] `projects` table
  - [ ] `assets` table
  - [ ] `jobs` table
  - [ ] `workflow_runs` table
  - [ ] `modules` table
  - [ ] `cost_records` table

- [ ] Verify indexes created

### 3. API Testing ✅

- [ ] Start API server
  ```bash
  uvicorn app.main:app --reload --port 8000
  ```

- [ ] Test endpoints:
  - [ ] `GET /health` - Returns status
  - [ ] `GET /` - Returns app info
  - [ ] `GET /docs` - API documentation loads
  - [ ] `POST /projects` - Creates project
  - [ ] `GET /projects` - Lists projects
  - [ ] `POST /jobs` - Creates job
  - [ ] `GET /jobs/{id}` - Gets job
  - [ ] `POST /workflows/run` - Runs workflow
  - [ ] `POST /modules/register` - Registers module
  - [ ] `GET /modules` - Lists modules

### 4. Workers Testing ✅

- [ ] Start Celery worker
  ```bash
  celery -A app.core.celery_app worker --loglevel=info
  ```

- [ ] Test job execution:
  - [ ] Create job via API
  - [ ] Worker picks up job
  - [ ] Job completes successfully
  - [ ] Job status updates correctly

### 5. Event Bus Testing ✅

- [ ] Test event publishing:
  - [ ] Job created event
  - [ ] Job completed event
  - [ ] Asset created event

- [ ] Test event subscription:
  - [ ] Subscribe to events
  - [ ] Receive events correctly

### 6. Frontend Preview ✅

- [ ] Access preview page
  ```
  http://localhost:8080/admin/core-foundation
  ```

- [ ] Verify displays:
  - [ ] System status (API, DB, Redis, Celery, Event Bus)
  - [ ] Statistics (Projects, Jobs, Assets, Modules)
  - [ ] API endpoints list
  - [ ] Database schema preview
  - [ ] Testing instructions

### 7. Integration Testing ✅

- [ ] End-to-end test:
  1. Create project
  2. Create job
  3. Worker processes job
  4. Job completes
  5. Asset created
  6. Events published
  7. Status updates

---

## 🔍 Testing Commands

### Quick Test
```bash
cd backend
python test_phase1.py
```

### Full Test
```bash
# Terminal 1: Start API
cd backend
uvicorn app.main:app --reload --port 8000

# Terminal 2: Start Celery
cd backend
celery -A app.core.celery_app worker --loglevel=info

# Terminal 3: Run tests
cd backend
pytest tests/
```

### Frontend Preview
```bash
# Start frontend
npm run dev

# Visit
http://localhost:8080/admin/core-foundation
```

---

## ✅ Success Criteria

Phase 1 ถือว่า **100% Complete** เมื่อ:

- [x] ✅ Backend structure created
- [ ] ✅ All dependencies installed
- [ ] ✅ Database migration successful
- [ ] ✅ API endpoints working
- [ ] ✅ Workers processing jobs
- [ ] ✅ Event Bus working
- [ ] ✅ Frontend preview accessible
- [ ] ✅ All tests passing
- [ ] ✅ No errors in logs

---

## 🐛 Common Issues & Fixes

### Issue: Import errors
**Fix:** Check `__init__.py` files exist in all directories

### Issue: Database connection failed
**Fix:** Check `.env` file and database credentials

### Issue: Redis connection failed
**Fix:** Check Redis is running and `REDIS_URL` in `.env`

### Issue: Celery worker not picking up jobs
**Fix:** Check Celery broker URL and worker is running

---

## 📊 Testing Report Template

```
Phase 1 Testing Report
======================

Date: [Date]
Tester: [Name]

Backend Setup: ✅ / ❌
Database Setup: ✅ / ❌
API Testing: ✅ / ❌
Workers Testing: ✅ / ❌
Event Bus Testing: ✅ / ❌
Frontend Preview: ✅ / ❌
Integration Testing: ✅ / ❌

Issues Found:
- [List issues]

Status: READY / NOT READY
```

---

**ทดสอบให้แน่ใจ 100% ก่อนไป Phase 2! 🎯**

