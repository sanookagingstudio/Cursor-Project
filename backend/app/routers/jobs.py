"""Jobs router"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.core.celery_app import celery_app
from app.core.events import publish_event, EventTypes
from app.models.job import Job
from app.schemas.job import JobCreate, JobResponse

router = APIRouter()


@router.post("/", response_model=JobResponse)
async def create_job(job: JobCreate, db: Session = Depends(get_db)):
    """Create a new job"""
    db_job = Job(**job.dict())
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    
    # Publish event
    publish_event(
        EventTypes.JOB_CREATED,
        {
            "job_id": str(db_job.id),
            "project_id": str(db_job.project_id),
            "module_id": db_job.module_id,
            "type": db_job.type
        }
    )
    
    # Dispatch to Celery worker
    # Map module_id to task name
    task_name_map = {
        "image.basic": "jobs.run_image_task",
        "video.render": "jobs.run_video_task",
        "audio.process": "jobs.run_audio_task",
    }
    
    task_name = task_name_map.get(db_job.module_id, "jobs.run_generic_task")
    
    try:
        celery_app.send_task(task_name, args=[str(db_job.id)])
    except Exception as e:
        print(f"Failed to dispatch job: {e}")
    
    return db_job


@router.get("/{job_id}", response_model=JobResponse)
async def get_job(job_id: str, db: Session = Depends(get_db)):
    """Get job by ID"""
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job


@router.get("/project/{project_id}", response_model=List[JobResponse])
async def list_project_jobs(project_id: str, db: Session = Depends(get_db)):
    """List jobs for a project"""
    jobs = db.query(Job).filter(Job.project_id == project_id).all()
    return jobs

