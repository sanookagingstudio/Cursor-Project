"""Job service - business logic for jobs"""
from sqlalchemy.orm import Session
from typing import Optional
from uuid import UUID
from app.models.job import Job
from datetime import datetime


class JobService:
    """Service for job operations"""
    
    @staticmethod
    def get_job(db: Session, job_id: UUID) -> Optional[Job]:
        """Get job by ID"""
        return db.query(Job).filter(Job.id == job_id).first()
    
    @staticmethod
    def update_status(
        db: Session,
        job_id: UUID,
        status: str,
        output_payload: Optional[dict] = None,
        error_message: Optional[str] = None
    ) -> Job:
        """Update job status"""
        job = JobService.get_job(db, job_id)
        if not job:
            raise ValueError(f"Job {job_id} not found")
        
        job.status = status
        
        if status == "running":
            job.started_at = datetime.utcnow()
        elif status in ["success", "failed", "canceled"]:
            job.finished_at = datetime.utcnow()
        
        if output_payload:
            job.output_payload = output_payload
        
        if error_message:
            job.error_message = error_message
        
        db.commit()
        db.refresh(job)
        return job
    
    @staticmethod
    def complete(db: Session, job_id: UUID, output_payload: dict) -> Job:
        """Mark job as completed"""
        return JobService.update_status(db, job_id, "success", output_payload)
    
    @staticmethod
    def fail(db: Session, job_id: UUID, error_message: str) -> Job:
        """Mark job as failed"""
        return JobService.update_status(db, job_id, "failed", error_message=error_message)

