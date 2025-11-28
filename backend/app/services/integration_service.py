"""
Integration Service
Handles integration between modules: Input Brain → Media Modules → Dashboard → Publishing
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.project import Project
from app.models.asset import Asset
from app.models.job import Job
from app.models.input_brain import WorkflowDraft
from app.models.publishing import Episode, Series, ContentChannel
from app.services.input_brain_service import InputBrainService
from app.services.dashboard_service import DashboardService
from app.core.events import publish_event


class IntegrationService:
    """Service for module integration"""
    
    def __init__(self):
        self.input_brain_service = InputBrainService()
        self.dashboard_service = DashboardService()
    
    def execute_workflow_draft(
        self,
        db: Session,
        workflow_draft_id: UUID,
        project_id: Optional[UUID] = None,
        user_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Execute workflow draft: Create jobs for each step
        
        Flow:
        1. Get workflow draft
        2. For each step, create appropriate job
        3. Return job IDs
        """
        # Get workflow draft
        workflow_draft = db.query(WorkflowDraft).filter(
            WorkflowDraft.id == workflow_draft_id
        ).first()
        
        if not workflow_draft:
            raise ValueError("Workflow draft not found")
        
        # Create or get project
        if project_id:
            project = db.query(Project).filter(Project.id == project_id).first()
        else:
            project = Project(
                name=f"Workflow {workflow_draft_id}",
                owner_id=str(user_id) if user_id else "system",
                meta_data={"workflow_draft_id": str(workflow_draft_id)}
            )
            db.add(project)
            db.flush()
        
        # Execute steps
        job_ids = []
        steps = workflow_draft.steps or []
        
        for step in steps:
            step_type = step.get("type") if isinstance(step, dict) else getattr(step, "type", None)
            step_params = step.get("params", {}) if isinstance(step, dict) else getattr(step, "params", {})
            
            # Create job based on step type
            job = Job(
                project_id=project.id,
                type=step_type,
                status="pending",
                input_payload=step_params,
                output_payload={}
            )
            db.add(job)
            db.flush()
            job_ids.append(str(job.id))
            
            # Publish event
            publish_event("WORKFLOW_STEP_CREATED", {
                "workflow_draft_id": str(workflow_draft_id),
                "step_type": step_type,
                "job_id": str(job.id)
            })
        
        db.commit()
        
        # Update workflow draft status
        workflow_draft.status = "executing"
        db.commit()
        
        publish_event("WORKFLOW_EXECUTED", {
            "workflow_draft_id": str(workflow_draft_id),
            "project_id": str(project.id),
            "job_ids": job_ids
        })
        
        return {
            "workflow_draft_id": str(workflow_draft_id),
            "project_id": str(project.id),
            "job_ids": job_ids,
            "status": "executing"
        }
    
    def create_episode_from_asset(
        self,
        db: Session,
        asset_id: UUID,
        series_id: UUID,
        title: str,
        description: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Episode:
        """
        Create episode from asset (after media generation)
        
        Flow:
        1. Get asset
        2. Create episode linked to asset
        3. Update episode status to 'ready'
        """
        # Get asset
        asset = db.query(Asset).filter(Asset.id == asset_id).first()
        if not asset:
            raise ValueError("Asset not found")
        
        # Create episode
        episode = Episode(
            series_id=series_id,
            project_id=asset.project_id,
            primary_asset_id=asset_id,
            title=title,
            description=description,
            status="ready",
            metadata=metadata or {}
        )
        db.add(episode)
        db.commit()
        db.refresh(episode)
        
        # Publish event
        publish_event("EPISODE_CREATED_FROM_ASSET", {
            "episode_id": str(episode.id),
            "asset_id": str(asset_id),
            "series_id": str(series_id)
        })
        
        return episode
    
    def auto_publish_episode(
        self,
        db: Session,
        episode_id: UUID,
        platform_account_id: UUID,
        scheduled_time: Optional[Any] = None
    ) -> Dict[str, Any]:
        """
        Auto-publish episode to platform
        
        Flow:
        1. Get episode
        2. Create publication record
        3. Create publishing job
        """
        from app.services.publishing_service import PublishingService
        from app.schemas.publishing import PublishingPlanRequest
        from datetime import datetime
        
        publishing_service = PublishingService()
        
        # Create publishing plan
        plan = PublishingPlanRequest(
            episode_id=episode_id,
            platform_account_id=platform_account_id,
            scheduled_time=scheduled_time,
            metadata={"auto_published": True}
        )
        
        publication = publishing_service.create_publishing_plan(
            db, plan, UUID("00000000-0000-0000-0000-000000000000")  # Mock user_id
        )
        
        return {
            "publication_id": str(publication.id),
            "status": publication.status,
            "scheduled_time": publication.scheduled_time.isoformat() if publication.scheduled_time else None
        }
    
    def get_workflow_status(
        self,
        db: Session,
        workflow_draft_id: UUID
    ) -> Dict[str, Any]:
        """Get workflow execution status"""
        workflow_draft = db.query(WorkflowDraft).filter(
            WorkflowDraft.id == workflow_draft_id
        ).first()
        
        if not workflow_draft:
            raise ValueError("Workflow draft not found")
        
        # Get related jobs
        project = db.query(Project).filter(
            Project.meta_data["workflow_draft_id"].astext == str(workflow_draft_id)
        ).first()
        
        jobs = []
        if project:
            jobs = db.query(Job).filter(Job.project_id == project.id).all()
        
        # Calculate status
        total_jobs = len(jobs)
        completed_jobs = len([j for j in jobs if j.status == "completed"])
        failed_jobs = len([j for j in jobs if j.status == "failed"])
        pending_jobs = len([j for j in jobs if j.status in ["pending", "processing"]])
        
        return {
            "workflow_draft_id": str(workflow_draft_id),
            "status": workflow_draft.status,
            "total_jobs": total_jobs,
            "completed_jobs": completed_jobs,
            "failed_jobs": failed_jobs,
            "pending_jobs": pending_jobs,
            "progress": (completed_jobs / total_jobs * 100) if total_jobs > 0 else 0
        }

