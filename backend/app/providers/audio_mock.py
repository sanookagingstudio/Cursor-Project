"""
Mock Audio Provider
For testing and development without actual AI API calls
"""

from typing import List, Dict, Any, Optional
from app.providers.audio_provider_base import (
    AudioProviderBase,
    StemResult,
    MusicAnalysisResult
)


class MockAudioProvider(AudioProviderBase):
    """Mock audio provider for testing"""
    
    def __init__(self, api_key: Optional[str] = None):
        super().__init__(api_key)
        self.name = "mock"
    
    def separate_stems(
        self,
        audio_path: str,
        stems: List[str] = None,
        **kwargs
    ) -> StemResult:
        """Separate mock stems"""
        if stems is None:
            stems = ["vocal", "drums", "bass", "other"]
        
        stem_paths = {}
        for stem in stems:
            stem_paths[stem] = f"https://via.placeholder.com/{stem}.wav?text={stem}"
        
        return StemResult(
            stems=stem_paths,
            metadata={
                "source_path": audio_path,
                "provider": "mock",
                "separated": True
            }
        )
    
    def analyze_music(
        self,
        audio_path: str,
        tasks: Optional[List[str]] = None,
        **kwargs
    ) -> MusicAnalysisResult:
        """Analyze mock music"""
        if tasks is None:
            tasks = ["bpm", "key", "chords", "sections"]
        
        # Mock analysis results
        sections = [
            {"name": "intro", "start": 0.0, "end": 8.0},
            {"name": "verse", "start": 8.0, "end": 24.0},
            {"name": "chorus", "start": 24.0, "end": 40.0},
            {"name": "verse", "start": 40.0, "end": 56.0},
            {"name": "chorus", "start": 56.0, "end": 72.0},
            {"name": "outro", "start": 72.0, "end": 80.0}
        ]
        
        chord_progression = [
            {"time": 0.0, "chord": "Cmaj7"},
            {"time": 2.0, "chord": "Am"},
            {"time": 4.0, "chord": "Fmaj7"},
            {"time": 6.0, "chord": "G"}
        ]
        
        return MusicAnalysisResult(
            bpm=120.0 if "bpm" in tasks else None,
            key="C:maj" if "key" in tasks else None,
            time_signature="4/4" if "time_signature" in tasks else None,
            sections=sections if "sections" in tasks else [],
            chord_progression=chord_progression if "chords" in tasks else [],
            energy_curve={"peak": 0.8, "average": 0.6} if "energy" in tasks else {},
            metadata={
                "source_path": audio_path,
                "provider": "mock",
                "analyzed": True
            }
        )
    
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
        """Generate mock music"""
        audio_url = f"https://via.placeholder.com/music.mp3?text={prompt[:30]}"
        return audio_url
    
    def remaster(
        self,
        audio_path: str,
        operations: List[Dict[str, Any]],
        **kwargs
    ) -> str:
        """Remaster mock audio"""
        audio_url = f"https://via.placeholder.com/remastered.wav?text=Remastered"
        return audio_url
    
    def generate_tab(
        self,
        audio_path: str,
        instrument: str = "guitar",
        difficulty: str = "original",
        **kwargs
    ) -> str:
        """Generate mock tab"""
        tab_content = f"""
Mock Tab for {instrument} ({difficulty})

e|-----------------|
B|-----------------|
G|-----------------|
D|-----------------|
A|-----------------|
E|-----------------|

Generated from: {audio_path}
"""
        return tab_content.strip()
    
    def get_cost_estimate(self, operation: str, duration_seconds: Optional[int] = None, **kwargs) -> float:
        """Mock cost estimates - very cheap for testing"""
        return 0.01

