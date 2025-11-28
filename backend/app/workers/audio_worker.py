"""Audio worker - placeholder for Phase 5"""
from app.core.celery_app import celery_app


@celery_app.task(name="jobs.run_audio_task")
def run_audio_task(job_id: str):
    """Audio worker task - placeholder"""
    # Will be implemented in Phase 5
    return {"status": "not_implemented", "phase": 5}

