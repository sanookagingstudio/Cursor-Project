"""
Analytics & Statistics Service
Business logic for Phase 10
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc, extract
from datetime import datetime, timedelta, date
from typing import Optional, List, Dict, Any
from uuid import UUID

from app.models.analytics import (
    UserSession,
    PageView,
    ContentInteraction,
    FeatureUsage,
    AnalyticsSnapshot
)
from app.schemas.analytics import (
    UserSessionCreate,
    PageViewCreate,
    ContentInteractionCreate,
    FeatureUsageCreate
)


class AnalyticsService:
    """Service for analytics and statistics operations"""

    @staticmethod
    def create_user_session(db: Session, session_data: UserSessionCreate) -> UserSession:
        """Create a new user session"""
        session = UserSession(**session_data.model_dump())
        db.add(session)
        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def end_user_session(db: Session, session_id: UUID, duration_seconds: int) -> Optional[UserSession]:
        """End a user session"""
        session = db.query(UserSession).filter(UserSession.id == session_id).first()
        if not session:
            return None
        
        session.session_end = datetime.now().isoformat()
        session.duration_seconds = duration_seconds
        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def create_page_view(db: Session, view_data: PageViewCreate) -> PageView:
        """Create a page view record"""
        view = PageView(**view_data.model_dump())
        db.add(view)
        
        # Update session page_views count
        if view_data.session_id:
            session = db.query(UserSession).filter(UserSession.id == view_data.session_id).first()
            if session:
                session.page_views += 1
        
        db.commit()
        db.refresh(view)
        return view

    @staticmethod
    def create_content_interaction(db: Session, interaction_data: ContentInteractionCreate) -> ContentInteraction:
        """Create a content interaction record"""
        interaction = ContentInteraction(**interaction_data.model_dump())
        db.add(interaction)
        db.commit()
        db.refresh(interaction)
        return interaction

    @staticmethod
    def record_feature_usage(db: Session, usage_data: FeatureUsageCreate) -> FeatureUsage:
        """Record feature usage"""
        # Check if usage exists
        existing = db.query(FeatureUsage).filter(
            and_(
                FeatureUsage.user_id == usage_data.user_id,
                FeatureUsage.feature_name == usage_data.feature_name
            )
        ).first()
        
        if existing:
            existing.usage_count += 1
            existing.last_used_at = datetime.now().isoformat()
            db.commit()
            db.refresh(existing)
            return existing
        else:
            usage = FeatureUsage(**usage_data.model_dump())
            db.add(usage)
            db.commit()
            db.refresh(usage)
            return usage

    @staticmethod
    def get_user_analytics(db: Session, start_date: Optional[date] = None, end_date: Optional[date] = None) -> Dict[str, Any]:
        """Get user analytics summary"""
        # Total users
        total_users = db.query(func.count(func.distinct(PageView.user_id))).scalar() or 0
        
        # Active users (DAU, WAU, MAU)
        today = date.today()
        week_ago = today - timedelta(days=7)
        month_ago = today - timedelta(days=30)
        
        dau = db.query(func.count(func.distinct(PageView.user_id))).filter(
            func.date(PageView.created_at) == today.isoformat()
        ).scalar() or 0
        
        wau = db.query(func.count(func.distinct(PageView.user_id))).filter(
            func.date(PageView.created_at) >= week_ago.isoformat()
        ).scalar() or 0
        
        mau = db.query(func.count(func.distinct(PageView.user_id))).filter(
            func.date(PageView.created_at) >= month_ago.isoformat()
        ).scalar() or 0
        
        # New users (users who first visited in the period)
        if start_date and end_date:
            new_users = db.query(func.count(func.distinct(PageView.user_id))).filter(
                and_(
                    func.date(PageView.created_at) >= start_date.isoformat(),
                    func.date(PageView.created_at) <= end_date.isoformat()
                )
            ).scalar() or 0
        else:
            new_users = 0
        
        return {
            "total_users": total_users,
            "active_users": {
                "dau": dau,
                "wau": wau,
                "mau": mau
            },
            "new_users": new_users,
            "returning_users": wau - new_users if wau > new_users else 0,
            "retention_rate": (wau / mau * 100) if mau > 0 else 0,
            "growth_rate": 0  # TODO: Calculate growth rate
        }

    @staticmethod
    def get_content_analytics(db: Session, limit: int = 10) -> Dict[str, Any]:
        """Get content analytics summary"""
        # Most viewed
        most_viewed = db.query(
            ContentInteraction.content_id,
            ContentInteraction.content_type,
            func.count(ContentInteraction.id).label("views")
        ).filter(
            ContentInteraction.interaction_type == "view"
        ).group_by(
            ContentInteraction.content_id,
            ContentInteraction.content_type
        ).order_by(desc("views")).limit(limit).all()
        
        # Most liked
        most_liked = db.query(
            ContentInteraction.content_id,
            ContentInteraction.content_type,
            func.count(ContentInteraction.id).label("likes")
        ).filter(
            ContentInteraction.interaction_type == "like"
        ).group_by(
            ContentInteraction.content_id,
            ContentInteraction.content_type
        ).order_by(desc("likes")).limit(limit).all()
        
        # Most shared
        most_shared = db.query(
            ContentInteraction.content_id,
            ContentInteraction.content_type,
            func.count(ContentInteraction.id).label("shares")
        ).filter(
            ContentInteraction.interaction_type == "share"
        ).group_by(
            ContentInteraction.content_id,
            ContentInteraction.content_type
        ).order_by(desc("shares")).limit(limit).all()
        
        # Most downloaded
        most_downloaded = db.query(
            ContentInteraction.content_id,
            ContentInteraction.content_type,
            func.count(ContentInteraction.id).label("downloads")
        ).filter(
            ContentInteraction.interaction_type == "download"
        ).group_by(
            ContentInteraction.content_id,
            ContentInteraction.content_type
        ).order_by(desc("downloads")).limit(limit).all()
        
        return {
            "most_viewed": [{"content_id": str(c[0]), "content_type": c[1], "count": c[2]} for c in most_viewed],
            "most_liked": [{"content_id": str(c[0]), "content_type": c[1], "count": c[2]} for c in most_liked],
            "most_shared": [{"content_id": str(c[0]), "content_type": c[1], "count": c[2]} for c in most_shared],
            "most_downloaded": [{"content_id": str(c[0]), "content_type": c[1], "count": c[2]} for c in most_downloaded],
            "trending": []  # TODO: Calculate trending content
        }

    @staticmethod
    def get_time_analytics(db: Session) -> Dict[str, Any]:
        """Get time-based analytics"""
        # Peak hours
        peak_hours = db.query(
            extract("hour", PageView.created_at).label("hour"),
            func.count(PageView.id).label("count")
        ).group_by("hour").order_by(desc("count")).limit(24).all()
        
        # Peak days
        peak_days = db.query(
            func.date(PageView.created_at).label("day"),
            func.count(PageView.id).label("count")
        ).group_by("day").order_by(desc("count")).limit(30).all()
        
        # Average session duration
        avg_duration = db.query(func.avg(UserSession.duration_seconds)).filter(
            UserSession.duration_seconds.isnot(None)
        ).scalar() or 0
        
        return {
            "peak_hours": [{"hour": int(p[0]), "count": p[1]} for p in peak_hours],
            "peak_days": [{"day": str(p[0]), "count": p[1]} for p in peak_days],
            "peak_months": [],  # TODO: Calculate peak months
            "average_session_duration": float(avg_duration) if avg_duration else 0
        }

    @staticmethod
    def get_geographic_analytics(db: Session) -> Dict[str, Any]:
        """Get geographic analytics"""
        # Users by country
        users_by_country = db.query(
            UserSession.country,
            func.count(func.distinct(UserSession.user_id)).label("count")
        ).filter(
            UserSession.country.isnot(None)
        ).group_by(UserSession.country).all()
        
        country_dict = {str(c[0]): c[1] for c in users_by_country}
        
        # Top countries
        top_countries = sorted(
            [{"country": c[0], "users": c[1]} for c in users_by_country],
            key=lambda x: x["users"],
            reverse=True
        )[:10]
        
        return {
            "users_by_country": country_dict,
            "users_by_region": {},  # TODO: Group by region
            "top_countries": top_countries
        }

    @staticmethod
    def get_feature_usage_analytics(db: Session) -> Dict[str, Any]:
        """Get feature usage analytics"""
        # Feature usage stats
        feature_stats = db.query(
            FeatureUsage.feature_name,
            func.sum(FeatureUsage.usage_count).label("total_usage"),
            func.count(func.distinct(FeatureUsage.user_id)).label("unique_users")
        ).group_by(FeatureUsage.feature_name).all()
        
        feature_dict = {f[0]: {"total_usage": f[1], "unique_users": f[2]} for f in feature_stats}
        
        # Most used features
        most_used = sorted(
            [{"feature": f[0], "usage": f[1], "users": f[2]} for f in feature_stats],
            key=lambda x: x["usage"],
            reverse=True
        )[:10]
        
        return {
            "feature_adoption": {},  # TODO: Calculate adoption rate
            "feature_usage_stats": feature_dict,
            "most_used_features": most_used
        }

