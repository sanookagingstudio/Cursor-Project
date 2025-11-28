"""
Platform Publisher Provider Base Interface
Base class for all platform publishing providers (YouTube, TikTok, Facebook, etc.)
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from datetime import datetime


class PublishResult:
    """Publishing result"""
    def __init__(
        self,
        external_post_id: str,
        url: str,
        published_time: Optional[datetime] = None,
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.external_post_id = external_post_id
        self.url = url
        self.published_time = published_time or datetime.now()
        self.metadata = metadata or {}


class MetricsResult:
    """Metrics result"""
    def __init__(
        self,
        views: int = 0,
        likes: int = 0,
        comments: int = 0,
        shares: int = 0,
        watch_time_seconds: float = 0,
        ctr: float = 0,
        engagement_rate: float = 0,
        estimated_revenue: float = 0,
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.views = views
        self.likes = likes
        self.comments = comments
        self.shares = shares
        self.watch_time_seconds = watch_time_seconds
        self.ctr = ctr
        self.engagement_rate = engagement_rate
        self.estimated_revenue = estimated_revenue
        self.metadata = metadata or {}


class RevenueResult:
    """Revenue result"""
    def __init__(
        self,
        amount: float,
        currency: str = "THB",
        period_start: Optional[datetime] = None,
        period_end: Optional[datetime] = None,
        source: str = "adsense",
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.amount = amount
        self.currency = currency
        self.period_start = period_start
        self.period_end = period_end
        self.source = source
        self.metadata = metadata or {}


class PlatformPublisherBase(ABC):
    """Base class for platform publishing providers"""
    
    def __init__(self, api_key: Optional[str] = None, auth_config: Optional[Dict[str, Any]] = None):
        self.api_key = api_key
        self.auth_config = auth_config or {}
        self.name = self.__class__.__name__
        self.platform = self._get_platform_name()
    
    @abstractmethod
    def _get_platform_name(self) -> str:
        """Get platform name (youtube, tiktok, facebook, etc.)"""
        raise NotImplementedError
    
    @abstractmethod
    def upload(
        self,
        asset_path: str,
        title: str,
        description: str,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> PublishResult:
        """
        Upload content to platform
        
        Args:
            asset_path: Path to asset file
            title: Content title
            description: Content description
            metadata: Additional metadata
            **kwargs: Platform-specific parameters
            
        Returns:
            PublishResult object
        """
        raise NotImplementedError
    
    @abstractmethod
    def schedule(
        self,
        asset_path: str,
        title: str,
        description: str,
        scheduled_time: datetime,
        metadata: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """
        Schedule content for publishing
        
        Args:
            asset_path: Path to asset file
            title: Content title
            description: Content description
            scheduled_time: When to publish
            metadata: Additional metadata
            **kwargs: Platform-specific parameters
            
        Returns:
            Dict with job/schedule info
        """
        raise NotImplementedError
    
    @abstractmethod
    def fetch_metrics(
        self,
        external_post_id: str,
        **kwargs
    ) -> MetricsResult:
        """
        Fetch metrics for published content
        
        Args:
            external_post_id: External post ID from platform
            **kwargs: Additional parameters
            
        Returns:
            MetricsResult object
        """
        raise NotImplementedError
    
    def fetch_revenue(
        self,
        external_post_id: str,
        period_start: Optional[datetime] = None,
        period_end: Optional[datetime] = None,
        **kwargs
    ) -> Optional[RevenueResult]:
        """
        Fetch revenue data (optional, not all platforms support)
        
        Args:
            external_post_id: External post ID from platform
            period_start: Revenue period start
            period_end: Revenue period end
            **kwargs: Additional parameters
            
        Returns:
            RevenueResult object or None if not supported
        """
        # Default implementation - return None
        return None
    
    def get_supported_formats(self) -> list:
        """Get supported file formats"""
        return ["mp4", "mov", "avi"]  # Default video formats
    
    def get_max_file_size(self) -> int:
        """Get maximum file size in bytes"""
        return 2 * 1024 * 1024 * 1024  # Default 2GB
    
    def get_cost_estimate(self, operation: str, **kwargs) -> float:
        """
        Estimate cost for operation
        
        Args:
            operation: Operation type (upload, schedule, fetch_metrics)
            **kwargs: Operation parameters
            
        Returns:
            Estimated cost in USD
        """
        # Default cost estimates
        base_costs = {
            "upload": 0.0,  # Usually free
            "schedule": 0.0,  # Usually free
            "fetch_metrics": 0.0  # Usually free
        }
        return base_costs.get(operation, 0.0)

