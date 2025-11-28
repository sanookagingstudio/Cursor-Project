"""Storage service - unified asset storage"""
import os
from pathlib import Path
from typing import Optional
from app.core.config import settings


class StorageService:
    """Service for asset storage operations"""
    
    def __init__(self):
        self.storage_path = Path(settings.STORAGE_PATH)
        self.storage_path.mkdir(parents=True, exist_ok=True)
    
    def save_asset(self, file_data: bytes, filename: str, subfolder: str = "") -> str:
        """Save asset to storage"""
        folder = self.storage_path / subfolder
        folder.mkdir(parents=True, exist_ok=True)
        
        file_path = folder / filename
        with open(file_path, "wb") as f:
            f.write(file_data)
        
        return str(file_path.relative_to(self.storage_path))
    
    def get_asset_path(self, relative_path: str) -> Path:
        """Get full path to asset"""
        return self.storage_path / relative_path
    
    def asset_exists(self, relative_path: str) -> bool:
        """Check if asset exists"""
        return (self.storage_path / relative_path).exists()
    
    def delete_asset(self, relative_path: str) -> bool:
        """Delete asset"""
        try:
            file_path = self.storage_path / relative_path
            if file_path.exists():
                file_path.unlink()
                return True
            return False
        except Exception:
            return False


storage_service = StorageService()

