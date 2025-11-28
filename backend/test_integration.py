"""
Integration Testing Script
Tests end-to-end workflows and module integration
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from uuid import uuid4
from app.core.db import SessionLocal
from app.models.project import Project
from app.models.asset import Asset
from app.models.job import Job
from app.models.input_brain import WorkflowDraft
from app.models.publishing import ContentChannel, Series, Episode
from app.services.integration_service import IntegrationService

def test_integration():
    """Test module integration"""
    print("\n" + "="*60)
    print("Phase 7: Integration & Testing")
    print("="*60 + "\n")
    
    db = SessionLocal()
    integration_service = IntegrationService()
    
    try:
        # Test 1: Workflow Execution
        print("[TEST 1] Workflow Execution")
        print("-" * 60)
        
        # Create test workflow draft
        workflow_draft = WorkflowDraft(
            idea_id=uuid4(),
            steps=[
                {"type": "image.generate", "params": {"prompt": "Test image"}},
                {"type": "video.generate", "params": {"prompt": "Test video"}}
            ],
            status="draft"
        )
        db.add(workflow_draft)
        db.commit()
        db.refresh(workflow_draft)
        
        print(f"✓ Created workflow draft: {workflow_draft.id}")
        
        # Execute workflow
        result = integration_service.execute_workflow_draft(db, workflow_draft.id)
        print(f"✓ Executed workflow: {result['project_id']}")
        print(f"  - Created {len(result['job_ids'])} jobs")
        
        # Test 2: Episode Creation from Asset
        print("\n[TEST 2] Episode Creation from Asset")
        print("-" * 60)
        
        # Create test project and asset
        project = Project(
            name="Test Project",
            owner_id="test_user",
            meta_data={}
        )
        db.add(project)
        db.flush()
        
        asset = Asset(
            project_id=project.id,
            type="video",
            path="https://test.com/video.mp4",
            provider="test",
            meta_data={}
        )
        db.add(asset)
        db.flush()
        
        # Create channel and series
        channel = ContentChannel(
            owner_id=uuid4(),
            name="Test Channel",
            description="Test"
        )
        db.add(channel)
        db.flush()
        
        series = Series(
            content_channel_id=channel.id,
            name="Test Series",
            description="Test"
        )
        db.add(series)
        db.commit()
        db.refresh(series)
        
        # Create episode from asset
        episode = integration_service.create_episode_from_asset(
            db, asset.id, series.id, "Test Episode", "Test description"
        )
        print(f"✓ Created episode: {episode.id}")
        print(f"  - Title: {episode.title}")
        print(f"  - Status: {episode.status}")
        
        # Test 3: Workflow Status
        print("\n[TEST 3] Workflow Status")
        print("-" * 60)
        
        status_info = integration_service.get_workflow_status(db, workflow_draft.id)
        print(f"✓ Workflow status retrieved")
        print(f"  - Status: {status_info['status']}")
        print(f"  - Total jobs: {status_info['total_jobs']}")
        print(f"  - Progress: {status_info['progress']:.1f}%")
        
        print("\n" + "="*60)
        print("✅ ALL INTEGRATION TESTS PASSED")
        print("="*60 + "\n")
        
        return True
        
    except Exception as e:
        print(f"\n❌ TEST FAILED: {str(e)}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        db.close()


if __name__ == "__main__":
    success = test_integration()
    sys.exit(0 if success else 1)

