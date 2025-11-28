"""Generic worker for testing"""
from app.core.celery_app import celery_app
from app.core.db import SessionLocal
from app.services.job_service import JobService
from app.core.events import publish_event, EventTypes
import uuid


@celery_app.task(name="jobs.run_generic_task")
def run_generic_task(job_id: str):
    """Generic worker task for testing"""
    db = SessionLocal()
    try:
        job = JobService.get_job(db, uuid.UUID(job_id))
        if not job:
            return {"error": "Job not found"}
        
        # Update status to running
        JobService.update_status(db, uuid.UUID(job_id), "running")
        
        # Publish event
        publish_event(
            EventTypes.JOB_STARTED,
            {
                "job_id": job_id,
                "module_id": job.module_id,
                "type": job.type
            }
        )
        
        # Mock processing
        import time
        time.sleep(1)  # Simulate work
        
        # Complete job
        output_payload = {
            "status": "success",
            "message": "Generic task completed",
            "result": "mock_result"
        }
        
        JobService.complete(db, uuid.UUID(job_id), output_payload)
        
        # Publish event
        publish_event(
            EventTypes.JOB_COMPLETED,
            {
                "job_id": job_id,
                "module_id": job.module_id,
                "output": output_payload
            }
        )
        
        return {"status": "success", "job_id": job_id}
        
    except Exception as e:
        if db:
            try:
                JobService.fail(db, uuid.UUID(job_id), str(e))
                publish_event(
                    EventTypes.JOB_FAILED,
                    {
                        "job_id": job_id,
                        "error": str(e)
                    }
                )
            except:
                pass
        return {"error": str(e)}
    finally:
        if db:
            db.close()

