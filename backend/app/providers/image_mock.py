"""
Mock Image Provider
For testing and development without actual AI API calls
"""

import base64
from typing import List, Optional, Dict, Any
from app.providers.image_provider_base import ImageProviderBase, ImageResult


class MockImageProvider(ImageProviderBase):
    """Mock image provider for testing"""
    
    def __init__(self, api_key: Optional[str] = None):
        super().__init__(api_key)
        self.name = "mock"
    
    def generate(
        self,
        prompt: str,
        width: int = 1024,
        height: int = 1024,
        style: Optional[str] = None,
        negative_prompt: Optional[str] = None,
        **kwargs
    ) -> List[ImageResult]:
        """Generate mock image"""
        # Create a simple placeholder image URL
        # In real implementation, this would call actual AI service
        image_url = f"https://via.placeholder.com/{width}x{height}.png?text={prompt[:20]}"
        
        return [ImageResult(
            image_url=image_url,
            width=width,
            height=height,
            format="png",
            metadata={
                "prompt": prompt,
                "style": style,
                "provider": "mock",
                "generated": True
            }
        )]
    
    def edit(
        self,
        image_path: str,
        prompt: str,
        mask_path: Optional[str] = None,
        edit_type: str = "inpaint",
        **kwargs
    ) -> ImageResult:
        """Edit mock image"""
        # In real implementation, this would process the image
        image_url = f"https://via.placeholder.com/1024x1024.png?text=Edited+{prompt[:15]}"
        
        return ImageResult(
            image_url=image_url,
            width=1024,
            height=1024,
            format="png",
            metadata={
                "original_path": image_path,
                "edit_prompt": prompt,
                "edit_type": edit_type,
                "provider": "mock",
                "edited": True
            }
        )
    
    def upscale(
        self,
        image_path: str,
        scale: int = 2,
        **kwargs
    ) -> ImageResult:
        """Upscale mock image"""
        # In real implementation, this would upscale the image
        new_width = 1024 * scale
        new_height = 1024 * scale
        image_url = f"https://via.placeholder.com/{new_width}x{new_height}.png?text=Upscaled"
        
        return ImageResult(
            image_url=image_url,
            width=new_width,
            height=new_height,
            format="png",
            metadata={
                "original_path": image_path,
                "scale": scale,
                "provider": "mock",
                "upscaled": True
            }
        )
    
    def get_cost_estimate(self, operation: str, **kwargs) -> float:
        """Mock cost estimates"""
        return 0.01  # Very cheap for testing

