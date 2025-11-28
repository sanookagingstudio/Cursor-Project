"""
Mock Platform Publisher Provider
For testing and development without actual platform API calls
"""

from typing import Dict, Any, Optional
from datetime import datetime
from app.providers.publisher_provider_base import (
    PlatformPublisherBase,
    PublishResult,
    MetricsResult,
    RevenueResult
)


class MockPlatformPublisher(PlatformPublisherBase):
    """Mock platform publisher for testing"""
    
    def __init__(self, api_key: Optional[str] = None, auth_config: Optional[Dict[str, Any]] = None):
        super().__init__(api_key, auth_config)
        self.name = "mock"
    
    def _get_platform_name(self) -> str:
        """Get platform name"""
        return self.auth_config.get("platform", "youtube")
    
    def upload(
        self,
        asset_path: str,
        title: str,
        description: str,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> PublishResult:
        """Mock upload"""
        external_post_id = f"mock_post_{datetime.now().timestamp()}"
        url = f"https://mock-platform.com/watch?v={external_post_id}"
        
        return PublishResult(
            external_post_id=external_post_id,
            url=url,
            published_time=datetime.now(),
            metadata={
                "asset_path": asset_path,
                "title": title,
                "description": description,
                **(metadata or {})
            }
        )
    
    def schedule(
        self,
        asset_path: str,
        title: str,
        description: str,
        scheduled_time: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Mock schedule"""
        return {
            "scheduled": True,
            "scheduled_time": scheduled_time.isoformat(),
            "job_id": f"mock_job_{datetime.now().timestamp()}",
            "asset_path": asset_path,
            "title": title
        }
    
    def fetch_metrics(
        self,
        external_post_id: str,
        **kwargs
    ) -> MetricsResult:
        """Mock fetch metrics"""
        # Generate mock metrics
        import random
        views = random.randint(100, 100000)
        likes = int(views * random.uniform(0.01, 0.05))
        comments = int(views * random.uniform(0.001, 0.01))
        shares = int(views * random.uniform(0.001, 0.005))
        
        return MetricsResult(
            views=views,
            likes=likes,
            comments=comments,
            shares=shares,
            watch_time_seconds=views * random.uniform(30, 180),
            ctr=random.uniform(0.02, 0.10),
            engagement_rate=random.uniform(0.03, 0.08),
            estimated_revenue=views * random.uniform(0.001, 0.01),
            metadata={
                "external_post_id": external_post_id,
                "fetched_at": datetime.now().isoformat()
            }
        )
    
    def fetch_revenue(
        self,
        external_post_id: str,
        period_start: Optional[datetime] = None,
        period_end: Optional[datetime] = None,
        **kwargs
    ) -> Optional[RevenueResult]:
        """Mock fetch revenue"""
        import random
        return RevenueResult(
            amount=random.uniform(10, 1000),
            currency="THB",
            period_start=period_start or datetime.now().replace(day=1),
            period_end=period_end or datetime.now(),
            source="adsense",
            metadata={
                "external_post_id": external_post_id,
                "fetched_at": datetime.now().isoformat()
            }
        )

