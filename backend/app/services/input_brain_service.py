"""
Input Brain Service
Business logic for Content Ideas, Versions, and Workflow Drafts
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from app.models.input_brain import ContentIdea, IdeaVersion, WorkflowDraft
from app.models.project import Project
from app.schemas.input_brain import (
    ContentIdeaCreate,
    ContentIdeaUpdate,
    IdeaVersionCreate,
    WorkflowDraftCreate,
    WorkflowStep
)


class InputBrainService:
    """Service for Input Brain operations"""

    @staticmethod
    def create_idea(db: Session, idea_data: ContentIdeaCreate, user_id: Optional[UUID] = None) -> ContentIdea:
        """Create a new content idea"""
        # Create project if not provided
        if not idea_data.project_id:
            project = Project(
                name=f"Idea: {idea_data.prompt[:50]}...",
                owner_id=user_id,
                meta_data={"source": "input_brain"}
            )
            db.add(project)
            db.flush()
            idea_data.project_id = project.id

        idea = ContentIdea(
            project_id=idea_data.project_id,
            type=idea_data.type,
            prompt=idea_data.prompt,
            options=idea_data.options or {},
            ai_suggestions={},
            status="draft"
        )
        db.add(idea)
        db.commit()
        db.refresh(idea)
        return idea

    @staticmethod
    def get_idea(db: Session, idea_id: UUID) -> Optional[ContentIdea]:
        """Get content idea by ID"""
        return db.query(ContentIdea).filter(ContentIdea.id == idea_id).first()

    @staticmethod
    def update_idea(db: Session, idea_id: UUID, update_data: ContentIdeaUpdate) -> Optional[ContentIdea]:
        """Update content idea"""
        idea = db.query(ContentIdea).filter(ContentIdea.id == idea_id).first()
        if not idea:
            return None

        if update_data.selected_version is not None:
            idea.selected_version = update_data.selected_version
        if update_data.status:
            idea.status = update_data.status

        db.commit()
        db.refresh(idea)
        return idea

    @staticmethod
    def create_version(db: Session, version_data: IdeaVersionCreate) -> IdeaVersion:
        """Create an idea version"""
        version = IdeaVersion(
            idea_id=version_data.idea_id,
            version_index=version_data.version_index,
            preview_asset_id=version_data.preview_asset_id,
            meta_data=version_data.metadata or {}
        )
        db.add(version)
        db.commit()
        db.refresh(version)
        return version

    @staticmethod
    def get_versions(db: Session, idea_id: UUID) -> List[IdeaVersion]:
        """Get all versions for an idea"""
        return db.query(IdeaVersion).filter(IdeaVersion.idea_id == idea_id).order_by(IdeaVersion.version_index).all()

    @staticmethod
    def generate_ai_suggestions(db: Session, idea_id: UUID, num_versions: int = 4) -> List[IdeaVersion]:
        """
        Generate AI suggestions (mock implementation)
        In production, this would call actual AI services
        """
        idea = db.query(ContentIdea).filter(ContentIdea.id == idea_id).first()
        if not idea:
            return []

        # Mock AI suggestions - generate versions
        versions = []
        for i in range(num_versions):
            version_data = IdeaVersionCreate(
                idea_id=idea_id,
                version_index=i + 1,
                metadata={
                    "prompt_variation": f"{idea.prompt} (variation {i + 1})",
                    "style": ["cute", "realistic", "artistic", "minimalist"][i % 4],
                    "confidence": 0.7 + (i * 0.05)
                }
            )
            version = InputBrainService.create_version(db, version_data)
            versions.append(version)

        # Update idea with suggestions
        from datetime import datetime
        idea.ai_suggestions = {
            "num_versions": num_versions,
            "generated_at": datetime.utcnow().isoformat()
        }
        db.commit()

        return versions

    @staticmethod
    def create_workflow_draft(db: Session, draft_data: WorkflowDraftCreate) -> WorkflowDraft:
        """Create a workflow draft"""
        draft = WorkflowDraft(
            idea_id=draft_data.idea_id,
            steps=[step.model_dump() if hasattr(step, 'model_dump') else step.dict() for step in draft_data.steps],
            meta_data=draft_data.metadata or {},
            status="draft"
        )
        db.add(draft)
        db.commit()
        db.refresh(draft)
        return draft

    @staticmethod
    def generate_workflow_draft(db: Session, idea_id: UUID, version_index: int) -> WorkflowDraft:
        """
        Generate workflow draft from selected idea version (mock implementation)
        In production, this would analyze the idea and generate appropriate workflow
        """
        idea = db.query(ContentIdea).filter(ContentIdea.id == idea_id).first()
        if not idea:
            raise ValueError("Idea not found")

        version = db.query(IdeaVersion).filter(
            IdeaVersion.idea_id == idea_id,
            IdeaVersion.version_index == version_index
        ).first()
        if not version:
            raise ValueError("Version not found")

        # Mock workflow generation based on idea type
        steps = []
        if idea.type == "image":
            steps = [
                {"module": "image", "action": "generate", "params": {"prompt": idea.prompt}},
                {"module": "image", "action": "upscale", "params": {"scale": 2}}
            ]
        elif idea.type == "video":
            steps = [
                {"module": "video", "action": "generate", "params": {"prompt": idea.prompt}},
                {"module": "video", "action": "subtitle", "params": {"auto": True}}
            ]
        elif idea.type == "music":
            steps = [
                {"module": "music", "action": "generate", "params": {"prompt": idea.prompt}}
            ]
        else:  # mixed
            steps = [
                {"module": "image", "action": "generate", "params": {"prompt": idea.prompt}},
                {"module": "video", "action": "generate", "params": {"prompt": idea.prompt}},
                {"module": "music", "action": "generate", "params": {"prompt": idea.prompt}}
            ]

        draft_data = WorkflowDraftCreate(
            idea_id=idea_id,
            steps=[WorkflowStep(**step) for step in steps],
            metadata={
                "version_index": version_index,
                "estimated_cost": 0.5,
                "estimated_time": 300
            }
        )

        return InputBrainService.create_workflow_draft(db, draft_data)

    @staticmethod
    def get_workflow_draft(db: Session, draft_id: UUID) -> Optional[WorkflowDraft]:
        """Get workflow draft by ID"""
        return db.query(WorkflowDraft).filter(WorkflowDraft.id == draft_id).first()

    @staticmethod
    def start_workflow(db: Session, draft_id: UUID) -> Dict[str, Any]:
        """
        Start workflow from draft
        This would integrate with Core Foundation's workflow system
        """
        draft = db.query(WorkflowDraft).filter(WorkflowDraft.id == draft_id).first()
        if not draft:
            raise ValueError("Workflow draft not found")

        if draft.status != "ready":
            draft.status = "ready"

        # Update idea status
        idea = db.query(ContentIdea).filter(ContentIdea.id == draft.idea_id).first()
        if idea:
            idea.status = "converted_to_workflow"

        db.commit()

        # In production, this would create a WorkflowRun in Core Foundation
        return {
            "draft_id": str(draft.id),
            "status": "started",
            "message": "Workflow started successfully (mock)"
        }

