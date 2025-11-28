"""
Audio Provider Base Interface
Base class for all audio/music processing providers
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional


class StemResult:
    """Stem separation result"""
    def __init__(
        self,
        stems: Dict[str, str],  # {"vocal": "/path/vocal.wav", "drums": "/path/drums.wav", ...}
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.stems = stems
        self.metadata = metadata or {}


class MusicAnalysisResult:
    """Music analysis result"""
    def __init__(
        self,
        bpm: Optional[float] = None,
        key: Optional[str] = None,
        time_signature: Optional[str] = None,
        sections: Optional[List[Dict[str, Any]]] = None,
        chord_progression: Optional[List[Dict[str, Any]]] = None,
        energy_curve: Optional[Dict[str, Any]] = None,
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.bpm = bpm
        self.key = key
        self.time_signature = time_signature
        self.sections = sections or []
        self.chord_progression = chord_progression or []
        self.energy_curve = energy_curve or {}
        self.metadata = metadata or {}


class AudioProviderBase(ABC):
    """Base class for audio/music processing providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.name = self.__class__.__name__
    
    @abstractmethod
    def separate_stems(
        self,
        audio_path: str,
        stems: List[str] = None,  # ["vocal", "drums", "bass", "other"]
        **kwargs
    ) -> StemResult:
        """
        Separate audio into stems
        
        Args:
            audio_path: Path to source audio file
            stems: List of stems to extract (default: all)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            StemResult object with stem paths
        """
        raise NotImplementedError
    
    @abstractmethod
    def analyze_music(
        self,
        audio_path: str,
        tasks: Optional[List[str]] = None,  # ["bpm", "key", "chords", "sections"]
        **kwargs
    ) -> MusicAnalysisResult:
        """
        Analyze music properties
        
        Args:
            audio_path: Path to audio file
            tasks: List of analysis tasks (default: all)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            MusicAnalysisResult object
        """
        raise NotImplementedError
    
    @abstractmethod
    def generate_music(
        self,
        prompt: str,
        duration_seconds: int = 30,
        tempo: Optional[int] = None,
        key: Optional[str] = None,
        mood: Optional[str] = None,
        instruments: Optional[List[str]] = None,
        **kwargs
    ) -> str:
        """
        Generate music from prompt
        
        Args:
            prompt: Text prompt for music generation
            duration_seconds: Duration in seconds
            tempo: BPM (optional)
            key: Musical key (optional)
            mood: Mood/style (optional)
            instruments: List of instruments (optional)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            Path to generated audio file
        """
        raise NotImplementedError
    
    @abstractmethod
    def remaster(
        self,
        audio_path: str,
        operations: List[Dict[str, Any]],
        **kwargs
    ) -> str:
        """
        Remaster audio
        
        Args:
            audio_path: Path to source audio
            operations: List of operations
                - {"type": "noise_reduction", "strength": 0.8}
                - {"type": "eq", "preset": "warm"}
                - {"type": "normalize", "target_lufs": -14}
                - {"type": "stereo_widen", "amount": 1.2}
            **kwargs: Additional provider-specific parameters
            
        Returns:
            Path to remastered audio file
        """
        raise NotImplementedError
    
    def generate_tab(
        self,
        audio_path: str,
        instrument: str = "guitar",
        difficulty: str = "original",
        **kwargs
    ) -> str:
        """
        Generate tab for instrument (default implementation)
        
        Args:
            audio_path: Path to audio file
            instrument: Instrument type (guitar, bass, ukulele)
            difficulty: Difficulty level (easy, original, advanced)
            **kwargs: Additional parameters
            
        Returns:
            Tab content as string
        """
        # Default implementation - can be overridden
        return f"Mock tab for {instrument} ({difficulty})"
    
    def get_cost_estimate(
        self,
        operation: str,
        duration_seconds: Optional[int] = None,
        **kwargs
    ) -> float:
        """
        Estimate cost for operation
        
        Args:
            operation: Operation type (stems, analyze, generate, remaster, tab)
            duration_seconds: Audio duration (for cost calculation)
            **kwargs: Operation parameters
            
        Returns:
            Estimated cost in USD
        """
        # Default cost estimates
        base_costs = {
            "stems": 0.01,  # per minute
            "analyze": 0.005,  # per minute
            "generate": 0.02,  # per second
            "remaster": 0.01,  # per minute
            "tab": 0.01  # per song
        }
        
        base_cost = base_costs.get(operation, 0.01)
        
        if duration_seconds and operation in ["stems", "analyze", "remaster"]:
            return base_cost * (duration_seconds / 60)
        
        if duration_seconds and operation == "generate":
            return base_cost * duration_seconds
        
        return base_cost
    
    def get_supported_formats(self) -> List[str]:
        """Get supported audio formats"""
        return ["wav", "mp3", "flac", "ogg"]
    
    def get_supported_stems(self) -> List[str]:
        """Get supported stem types"""
        return ["vocal", "drums", "bass", "other"]

