"""
External Application Integration Service
Business logic for Phase 12
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc
from typing import Optional, List, Dict, Any
from uuid import UUID
from decimal import Decimal
import hashlib
import secrets

from app.models.external_app import (
    ExternalApplication,
    APIKey,
    ExternalAppUser,
    ExternalAppUsage
)
from app.schemas.external_app import (
    ExternalApplicationCreate,
    ExternalApplicationUpdate,
    APIKeyCreate,
    ExternalAppUserCreate
)


class ExternalAppService:
    """Service for external application integration operations"""

    @staticmethod
    def get_external_apps(db: Session, status: Optional[str] = None) -> List[ExternalApplication]:
        """Get all external applications"""
        query = db.query(ExternalApplication)
        if status:
            query = query.filter(ExternalApplication.status == status)
        return query.all()

    @staticmethod
    def get_external_app(db: Session, app_id: UUID) -> Optional[ExternalApplication]:
        """Get external application by ID"""
        return db.query(ExternalApplication).filter(ExternalApplication.id == app_id).first()

    @staticmethod
    def create_external_app(db: Session, app_data: ExternalApplicationCreate) -> ExternalApplication:
        """Create a new external application"""
        app = ExternalApplication(**app_data.model_dump())
        db.add(app)
        db.commit()
        db.refresh(app)
        return app

    @staticmethod
    def update_external_app(db: Session, app_id: UUID, app_data: ExternalApplicationUpdate) -> Optional[ExternalApplication]:
        """Update external application"""
        app = db.query(ExternalApplication).filter(ExternalApplication.id == app_id).first()
        if not app:
            return None
        
        update_data = app_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(app, key, value)
        
        db.commit()
        db.refresh(app)
        return app

    @staticmethod
    def generate_api_key(db: Session, key_data: APIKeyCreate) -> tuple[APIKey, str]:
        """Generate a new API key"""
        # Generate random API key
        api_key = f"mv2_{secrets.token_urlsafe(32)}"
        key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        key_prefix = api_key[:8]
        
        # Create API key record
        db_key = APIKey(
            app_id=key_data.app_id,
            key_hash=key_hash,
            key_prefix=key_prefix,
            name=key_data.name,
            scopes=key_data.scopes,
            rate_limit=key_data.rate_limit,
            expires_at=key_data.expires_at,
            status="active"
        )
        db.add(db_key)
        db.commit()
        db.refresh(db_key)
        
        return db_key, api_key

    @staticmethod
    def get_api_keys(db: Session, app_id: UUID) -> List[APIKey]:
        """Get API keys for an application"""
        return db.query(APIKey).filter(APIKey.app_id == app_id).all()

    @staticmethod
    def revoke_api_key(db: Session, key_id: UUID) -> Optional[APIKey]:
        """Revoke an API key"""
        key = db.query(APIKey).filter(APIKey.id == key_id).first()
        if not key:
            return None
        
        key.status = "revoked"
        db.commit()
        db.refresh(key)
        return key

    @staticmethod
    def register_external_user(db: Session, user_data: ExternalAppUserCreate) -> ExternalAppUser:
        """Register an external app user"""
        # Check if user already exists
        existing = db.query(ExternalAppUser).filter(
            and_(
                ExternalAppUser.app_id == user_data.app_id,
                ExternalAppUser.external_user_id == user_data.external_user_id
            )
        ).first()
        
        if existing:
            return existing
        
        user = ExternalAppUser(**user_data.model_dump())
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def record_usage(
        db: Session,
        app_id: UUID,
        api_key_id: Optional[UUID],
        user_id: Optional[UUID],
        endpoint: str,
        method: str,
        response_status: int,
        cost: Optional[Decimal] = None,
        credits_used: int = 0,
        duration_ms: Optional[int] = None
    ) -> ExternalAppUsage:
        """Record API usage"""
        usage = ExternalAppUsage(
            app_id=app_id,
            api_key_id=api_key_id,
            user_id=user_id,
            endpoint=endpoint,
            method=method,
            response_status=response_status,
            cost=cost,
            credits_used=credits_used,
            duration_ms=duration_ms
        )
        db.add(usage)
        
        # Update API key last_used_at
        if api_key_id:
            key = db.query(APIKey).filter(APIKey.id == api_key_id).first()
            if key:
                from datetime import datetime
                key.last_used_at = datetime.now().isoformat()
        
        db.commit()
        db.refresh(usage)
        return usage

    @staticmethod
    def get_usage_summary(db: Session, app_id: UUID, start_date: Optional[str] = None, end_date: Optional[str] = None) -> Dict[str, Any]:
        """Get usage summary for an application"""
        query = db.query(ExternalAppUsage).filter(ExternalAppUsage.app_id == app_id)
        
        if start_date:
            query = query.filter(ExternalAppUsage.created_at >= start_date)
        if end_date:
            query = query.filter(ExternalAppUsage.created_at <= end_date)
        
        usages = query.all()
        
        total_requests = len(usages)
        total_cost = sum(usage.cost or Decimal("0") for usage in usages)
        total_credits_used = sum(usage.credits_used or 0 for usage in usages)
        
        # Group by endpoint
        requests_by_endpoint = {}
        cost_by_endpoint = {}
        for usage in usages:
            endpoint = usage.endpoint or "unknown"
            requests_by_endpoint[endpoint] = requests_by_endpoint.get(endpoint, 0) + 1
            cost_by_endpoint[endpoint] = cost_by_endpoint.get(endpoint, Decimal("0")) + (usage.cost or Decimal("0"))
        
        return {
            "total_requests": total_requests,
            "total_cost": float(total_cost),
            "total_credits_used": total_credits_used,
            "requests_by_endpoint": requests_by_endpoint,
            "cost_by_endpoint": {k: float(v) for k, v in cost_by_endpoint.items()}
        }

