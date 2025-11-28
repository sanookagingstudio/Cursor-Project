"""
Video Provider Base Interface
Base class for all video generation providers
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional


class VideoResult:
    """Video generation result"""
    def __init__(
        self,
        video_url: str,
        duration: float,
        width: int,
        height: int,
        fps: int = 30,
        format: str = "mp4",
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.video_url = video_url
        self.duration = duration
        self.width = width
        self.height = height
        self.fps = fps
        self.format = format
        self.metadata = metadata or {}


class SubtitleResult:
    """Subtitle generation result"""
    def __init__(
        self,
        transcript: str,
        subtitle_file_url: Optional[str] = None,
        subtitle_format: str = "srt",
        segments: Optional[List[Dict[str, Any]]] = None,
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.transcript = transcript
        self.subtitle_file_url = subtitle_file_url
        self.subtitle_format = subtitle_format
        self.segments = segments or []
        self.metadata = metadata or {}


class VideoProviderBase(ABC):
    """Base class for video generation providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.name = self.__class__.__name__
    
    @abstractmethod
    def generate_video(
        self,
        prompt: str,
        duration_seconds: int = 15,
        aspect_ratio: str = "16:9",
        resolution: Optional[str] = None,
        style: Optional[str] = None,
        **kwargs
    ) -> VideoResult:
        """
        Generate video from prompt
        
        Args:
            prompt: Text prompt for video generation
            duration_seconds: Video duration in seconds
            aspect_ratio: Aspect ratio (16:9, 9:16, 4:5, 1:1)
            resolution: Resolution string (e.g., "1080x1920")
            style: Video style (cinematic, documentary, etc.)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            VideoResult object
        """
        raise NotImplementedError
    
    @abstractmethod
    def edit_video(
        self,
        source_path: str,
        operations: List[Dict[str, Any]],
        output_config: Optional[Dict[str, Any]] = None,
        **kwargs
    ) -> VideoResult:
        """
        Edit existing video
        
        Args:
            source_path: Path to source video
            operations: List of edit operations
                - {"type": "auto_cut_silence", "threshold_db": -35}
                - {"type": "auto_reframe", "target_aspect_ratio": "9:16"}
                - {"type": "auto_transition", "transition_type": "fade"}
                - {"type": "speed_adjust", "speed": 1.5}
            output_config: Output configuration
            **kwargs: Additional provider-specific parameters
            
        Returns:
            VideoResult object
        """
        raise NotImplementedError
    
    @abstractmethod
    def subtitle_video(
        self,
        source_path: str,
        source_language: str = "auto",
        target_languages: Optional[List[str]] = None,
        style: str = "default",
        **kwargs
    ) -> SubtitleResult:
        """
        Generate subtitles for video
        
        Args:
            source_path: Path to source video
            source_language: Source language code or "auto"
            target_languages: List of target language codes for translation
            style: Subtitle style (default, tiktok, youtube)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            SubtitleResult object
        """
        raise NotImplementedError
    
    def multi_export(
        self,
        source_path: str,
        aspect_ratios: List[str],
        **kwargs
    ) -> List[VideoResult]:
        """
        Export video in multiple aspect ratios
        
        Args:
            source_path: Path to source video
            aspect_ratios: List of aspect ratios (16:9, 9:16, 4:5, 1:1)
            **kwargs: Additional parameters
            
        Returns:
            List of VideoResult objects
        """
        results = []
        for aspect_ratio in aspect_ratios:
            # Default implementation: reframe for each aspect ratio
            result = self.edit_video(
                source_path,
                operations=[{"type": "auto_reframe", "target_aspect_ratio": aspect_ratio}],
                output_config={"aspect_ratio": aspect_ratio},
                **kwargs
            )
            results.append(result)
        return results
    
    def get_cost_estimate(
        self,
        operation: str,
        duration_seconds: Optional[int] = None,
        **kwargs
    ) -> float:
        """
        Estimate cost for operation
        
        Args:
            operation: Operation type (generate, edit, subtitle, multi_export)
            duration_seconds: Video duration (for cost calculation)
            **kwargs: Operation parameters
            
        Returns:
            Estimated cost in USD
        """
        # Default cost estimates (can be overridden)
        base_costs = {
            "generate": 0.05,  # per second
            "edit": 0.03,  # per second
            "subtitle": 0.01,  # per minute
            "multi_export": 0.02  # per aspect ratio
        }
        
        base_cost = base_costs.get(operation, 0.05)
        
        if duration_seconds and operation in ["generate", "edit"]:
            return base_cost * duration_seconds
        
        return base_cost
    
    def get_supported_formats(self) -> List[str]:
        """Get supported output formats"""
        return ["mp4", "mov", "webm"]
    
    def get_supported_aspect_ratios(self) -> List[str]:
        """Get supported aspect ratios"""
        return ["16:9", "9:16", "4:5", "1:1"]
    
    def get_max_duration(self) -> int:
        """Get maximum supported duration in seconds"""
        return 300  # 5 minutes default

