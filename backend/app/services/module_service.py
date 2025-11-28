"""Module service - plugin registry management"""
from sqlalchemy.orm import Session
from typing import Optional, List
from app.models.module import Module


class ModuleService:
    """Service for module operations"""
    
    @staticmethod
    def get_module(db: Session, module_id: str) -> Optional[Module]:
        """Get module by ID"""
        return db.query(Module).filter(Module.id == module_id).first()
    
    @staticmethod
    def list_modules(db: Session, category: Optional[str] = None) -> List[Module]:
        """List modules, optionally filtered by category"""
        query = db.query(Module).filter(Module.active == True)
        if category:
            query = query.filter(Module.category == category)
        return query.all()
    
    @staticmethod
    def register_module(db: Session, module_data: dict) -> Module:
        """Register a new module"""
        module = Module(**module_data)
        db.add(module)
        db.commit()
        db.refresh(module)
        return module

