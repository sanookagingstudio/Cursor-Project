"""
Dashboard Service
Business logic for content channels, series, and episodes management
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from app.models.publishing import (
    ContentChannel, Series, Episode, PublicationRecord, PerformanceSnapshot, RevenueRecord
)
from app.models.asset import Asset
from app.schemas.publishing import (
    ContentChannelCreate, SeriesCreate, EpisodeCreate,
    DashboardOverviewResponse, EpisodePerformanceResponse, FinanceResponse,
    EpisodeResponse, PublicationRecordResponse, PerformanceSnapshotResponse
)
from app.core.events import publish_event


class DashboardService:
    """Service for dashboard operations"""
    
    def create_channel(
        self,
        db: Session,
        channel_data: ContentChannelCreate,
        user_id: UUID
    ) -> ContentChannel:
        """Create content channel"""
        channel = ContentChannel(
            owner_id=user_id,
            name=channel_data.name,
            description=channel_data.description,
            meta_data=channel_data.metadata or {}
        )
        db.add(channel)
        db.commit()
        db.refresh(channel)
        
        publish_event("CHANNEL_CREATED", {
            "channel_id": str(channel.id),
            "owner_id": str(user_id)
        })
        
        return channel
    
    def get_channels(self, db: Session, user_id: UUID) -> List[ContentChannel]:
        """Get all channels for user"""
        return db.query(ContentChannel).filter(ContentChannel.owner_id == user_id).all()
    
    def get_channel(self, db: Session, channel_id: UUID) -> Optional[ContentChannel]:
        """Get channel by ID"""
        return db.query(ContentChannel).filter(ContentChannel.id == channel_id).first()
    
    def create_series(
        self,
        db: Session,
        channel_id: UUID,
        series_data: SeriesCreate
    ) -> Series:
        """Create series"""
        series = Series(
            content_channel_id=channel_id,
            name=series_data.name,
            description=series_data.description,
            metadata=series_data.metadata or {}
        )
        db.add(series)
        db.commit()
        db.refresh(series)
        
        publish_event("SERIES_CREATED", {
            "series_id": str(series.id),
            "channel_id": str(channel_id)
        })
        
        return series
    
    def get_series(self, db: Session, channel_id: UUID) -> List[Series]:
        """Get all series for channel"""
        return db.query(Series).filter(Series.content_channel_id == channel_id).all()
    
    def create_episode(
        self,
        db: Session,
        episode_data: EpisodeCreate
    ) -> Episode:
        """Create episode"""
        episode = Episode(
            series_id=episode_data.series_id,
            project_id=episode_data.project_id,
            primary_asset_id=episode_data.primary_asset_id,
            title=episode_data.title,
            description=episode_data.description,
            status="draft",
            metadata=episode_data.metadata or {}
        )
        db.add(episode)
        db.commit()
        db.refresh(episode)
        
        publish_event("EPISODE_CREATED", {
            "episode_id": str(episode.id),
            "series_id": str(episode_data.series_id)
        })
        
        return episode
    
    def get_episode(self, db: Session, episode_id: UUID) -> Optional[Episode]:
        """Get episode by ID"""
        return db.query(Episode).filter(Episode.id == episode_id).first()
    
    def get_episodes(self, db: Session, series_id: UUID) -> List[Episode]:
        """Get all episodes for series"""
        return db.query(Episode).filter(Episode.series_id == series_id).all()
    
    def get_overview(
        self,
        db: Session,
        user_id: UUID,
        channel_id: Optional[UUID] = None
    ) -> DashboardOverviewResponse:
        """Get dashboard overview"""
        # Get channels
        if channel_id:
            channels = [db.query(ContentChannel).filter(
                and_(ContentChannel.id == channel_id, ContentChannel.owner_id == user_id)
            ).first()]
        else:
            channels = db.query(ContentChannel).filter(ContentChannel.owner_id == user_id).all()
        
        channel_ids = [c.id for c in channels if c]
        
        # Get series
        series = db.query(Series).filter(Series.content_channel_id.in_(channel_ids)).all() if channel_ids else []
        series_ids = [s.id for s in series]
        
        # Get episodes
        episodes = db.query(Episode).filter(Episode.series_id.in_(series_ids)).all() if series_ids else []
        
        # Get publications
        episode_ids = [e.id for e in episodes]
        publications = db.query(PublicationRecord).filter(
            PublicationRecord.episode_id.in_(episode_ids)
        ).all() if episode_ids else []
        
        # Get performance metrics
        publication_ids = [p.id for p in publications]
        snapshots = db.query(PerformanceSnapshot).filter(
            PerformanceSnapshot.publication_id.in_(publication_ids)
        ).all() if publication_ids else []
        
        # Calculate totals
        total_views = sum(s.views for s in snapshots)
        total_revenue = sum(r.amount for r in (db.query(RevenueRecord).filter(
            RevenueRecord.publication_id.in_(publication_ids)
        ).all() if publication_ids else []))
        
        # Get recent episodes
        recent_episodes = db.query(Episode).filter(
            Episode.series_id.in_(series_ids)
        ).order_by(Episode.created_at.desc()).limit(5).all() if series_ids else []
        
        # Get top performers (simplified)
        top_performers = []
        for pub in publications[:5]:
            pub_snapshots = [s for s in snapshots if s.publication_id == pub.id]
            if pub_snapshots:
                latest = max(pub_snapshots, key=lambda x: x.timestamp)
                top_performers.append({
                    "publication_id": str(pub.id),
                    "views": latest.views,
                    "engagement_rate": latest.engagement_rate
                })
        
        return DashboardOverviewResponse(
            total_channels=len(channels),
            total_episodes=len(episodes),
            total_publications=len(publications),
            total_views=total_views,
            total_revenue=total_revenue,
            revenue_currency="THB",
            recent_episodes=[EpisodeResponse.model_validate(e) for e in recent_episodes],
            top_performers=top_performers
        )
    
    def get_episode_performance(
        self,
        db: Session,
        episode_id: UUID
    ) -> Optional[EpisodePerformanceResponse]:
        """Get episode performance"""
        episode = self.get_episode(db, episode_id)
        if not episode:
            return None
        
        # Get publications
        publications = db.query(PublicationRecord).filter(
            PublicationRecord.episode_id == episode_id
        ).all()
        
        publication_ids = [p.id for p in publications]
        
        # Get snapshots
        snapshots = db.query(PerformanceSnapshot).filter(
            PerformanceSnapshot.publication_id.in_(publication_ids)
        ).all() if publication_ids else []
        
        # Calculate totals
        total_views = sum(s.views for s in snapshots)
        total_likes = sum(s.likes for s in snapshots)
        total_comments = sum(s.comments for s in snapshots)
        total_shares = sum(s.shares for s in snapshots)
        total_watch_time = sum(s.watch_time_seconds for s in snapshots)
        
        avg_ctr = sum(s.ctr for s in snapshots) / len(snapshots) if snapshots else 0
        avg_engagement = sum(s.engagement_rate for s in snapshots) / len(snapshots) if snapshots else 0
        estimated_revenue = sum(s.estimated_revenue for s in snapshots)
        
        return EpisodePerformanceResponse(
            episode_id=episode_id,
            episode_title=episode.title,
            total_views=total_views,
            total_likes=total_likes,
            total_comments=total_comments,
            total_shares=total_shares,
            total_watch_time=total_watch_time,
            average_ctr=avg_ctr,
            average_engagement_rate=avg_engagement,
            estimated_revenue=estimated_revenue,
            publications=[PublicationRecordResponse.model_validate(p) for p in publications],
            snapshots=[PerformanceSnapshotResponse.model_validate(s) for s in snapshots]
        )
    
    def get_finance(
        self,
        db: Session,
        entity_type: str,  # "channel", "series", "episode"
        entity_id: UUID
    ) -> Optional[FinanceResponse]:
        """Get finance data for entity"""
        # Get relevant publications
        if entity_type == "episode":
            publications = db.query(PublicationRecord).filter(
                PublicationRecord.episode_id == entity_id
            ).all()
        elif entity_type == "series":
            episodes = db.query(Episode).filter(Episode.series_id == entity_id).all()
            episode_ids = [e.id for e in episodes]
            publications = db.query(PublicationRecord).filter(
                PublicationRecord.episode_id.in_(episode_ids)
            ).all() if episode_ids else []
        elif entity_type == "channel":
            channels = [db.query(ContentChannel).filter(ContentChannel.id == entity_id).first()]
            channel_ids = [c.id for c in channels if c]
            series = db.query(Series).filter(Series.content_channel_id.in_(channel_ids)).all() if channel_ids else []
            series_ids = [s.id for s in series]
            episodes = db.query(Episode).filter(Episode.series_id.in_(series_ids)).all() if series_ids else []
            episode_ids = [e.id for e in episodes]
            publications = db.query(PublicationRecord).filter(
                PublicationRecord.episode_id.in_(episode_ids)
            ).all() if episode_ids else []
        else:
            return None
        
        publication_ids = [p.id for p in publications]
        
        # Get revenue records
        revenue_records = db.query(RevenueRecord).filter(
            RevenueRecord.publication_id.in_(publication_ids)
        ).all() if publication_ids else []
        
        # Calculate totals
        total_revenue = sum(r.amount for r in revenue_records)
        total_cost = 0  # TODO: Calculate from cost_records
        profit = total_revenue - total_cost
        roi = (profit / total_cost * 100) if total_cost > 0 else 0
        
        # Revenue by source
        revenue_by_source = {}
        for r in revenue_records:
            revenue_by_source[r.source] = revenue_by_source.get(r.source, 0) + r.amount
        
        return FinanceResponse(
            total_revenue=total_revenue,
            total_cost=total_cost,
            profit=profit,
            roi=roi,
            revenue_by_source=revenue_by_source,
            revenue_by_period=[],  # TODO: Group by period
            currency="THB"
        )

