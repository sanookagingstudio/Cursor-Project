"""Workflows router"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from uuid import UUID
from app.core.db import get_db
from app.core.events import publish_event, EventTypes
from app.models.workflow import WorkflowRun
from app.models.job import Job
from app.schemas.workflow import WorkflowRunResponse

router = APIRouter()


@router.post("/run")
async def run_workflow(
    project_id: UUID,
    name: str,
    steps: List[Dict[str, Any]],
    db: Session = Depends(get_db)
):
    """Run a workflow"""
    # Create workflow run
    workflow = WorkflowRun(
        project_id=project_id,
        name=name,
        steps=steps,
        status="running"
    )
    db.add(workflow)
    db.commit()
    db.refresh(workflow)
    
    # Publish event
    publish_event(
        EventTypes.WORKFLOW_STARTED,
        {
            "workflow_id": str(workflow.id),
            "project_id": str(project_id),
            "name": name,
            "steps_count": len(steps)
        }
    )
    
    # Create jobs for each step
    created_jobs = []
    for step in steps:
        job = Job(
            project_id=project_id,
            module_id=step.get("module_id"),
            type=step.get("type"),
            input_payload=step.get("input", {}),
            status="queued"
        )
        db.add(job)
        created_jobs.append(job)
    
    db.commit()
    
    return {
        "workflow_id": str(workflow.id),
        "status": "running",
        "jobs_created": len(created_jobs)
    }


@router.get("/{workflow_id}", response_model=WorkflowRunResponse)
async def get_workflow(workflow_id: str, db: Session = Depends(get_db)):
    """Get workflow by ID"""
    workflow = db.query(WorkflowRun).filter(WorkflowRun.id == workflow_id).first()
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return workflow

