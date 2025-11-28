"""
Image Provider Base Interface
Base class for all image generation providers
"""

from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from uuid import UUID


class ImageResult:
    """Image generation result"""
    def __init__(
        self,
        image_url: str,
        width: int,
        height: int,
        format: str = "png",
        metadata: Optional[Dict[str, Any]] = None
    ):
        self.image_url = image_url
        self.width = width
        self.height = height
        self.format = format
        self.metadata = metadata or {}


class ImageProviderBase(ABC):
    """Base class for image generation providers"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.name = self.__class__.__name__
    
    @abstractmethod
    def generate(
        self,
        prompt: str,
        width: int = 1024,
        height: int = 1024,
        style: Optional[str] = None,
        negative_prompt: Optional[str] = None,
        **kwargs
    ) -> List[ImageResult]:
        """
        Generate image from prompt
        
        Args:
            prompt: Text prompt for image generation
            width: Image width in pixels
            height: Image height in pixels
            style: Image style (optional)
            negative_prompt: Negative prompt (optional)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            List of ImageResult objects
        """
        raise NotImplementedError
    
    @abstractmethod
    def edit(
        self,
        image_path: str,
        prompt: str,
        mask_path: Optional[str] = None,
        edit_type: str = "inpaint",
        **kwargs
    ) -> ImageResult:
        """
        Edit existing image
        
        Args:
            image_path: Path to source image
            prompt: Edit instruction
            mask_path: Path to mask image (optional)
            edit_type: Type of edit (inpaint, outpainting, remove, add)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            ImageResult object
        """
        raise NotImplementedError
    
    @abstractmethod
    def upscale(
        self,
        image_path: str,
        scale: int = 2,
        **kwargs
    ) -> ImageResult:
        """
        Upscale image
        
        Args:
            image_path: Path to source image
            scale: Upscale factor (2, 3, or 4)
            **kwargs: Additional provider-specific parameters
            
        Returns:
            ImageResult object
        """
        raise NotImplementedError
    
    def get_cost_estimate(
        self,
        operation: str,
        **kwargs
    ) -> float:
        """
        Estimate cost for operation
        
        Args:
            operation: Operation type (generate, edit, upscale)
            **kwargs: Operation parameters
            
        Returns:
            Estimated cost in USD
        """
        # Default cost estimates (can be overridden)
        costs = {
            "generate": 0.04,
            "edit": 0.06,
            "upscale": 0.02
        }
        return costs.get(operation, 0.05)
    
    def get_supported_formats(self) -> List[str]:
        """Get supported output formats"""
        return ["png", "jpg", "webp"]
    
    def get_max_resolution(self) -> tuple:
        """Get maximum supported resolution (width, height)"""
        return (4096, 4096)

