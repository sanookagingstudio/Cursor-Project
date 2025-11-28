"""Modules (Plugin Registry) router"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.db import get_db
from app.core.events import publish_event, EventTypes
from app.models.module import Module
from app.schemas.module import ModuleRegister, ModuleResponse

router = APIRouter()


@router.post("/register", response_model=ModuleResponse)
async def register_module(module_data: ModuleRegister, db: Session = Depends(get_db)):
    """Register a new module"""
    module = Module(**module_data.dict())
    db.add(module)
    db.commit()
    db.refresh(module)
    
    # Publish event
    publish_event(
        EventTypes.MODULE_REGISTERED,
        {
            "module_id": module.id,
            "name": module.name,
            "category": module.category
        }
    )
    
    return module


@router.get("/", response_model=List[ModuleResponse])
async def list_modules(db: Session = Depends(get_db)):
    """List all registered modules"""
    modules = db.query(Module).filter(Module.active == True).all()
    return modules


@router.get("/{module_id}", response_model=ModuleResponse)
async def get_module(module_id: str, db: Session = Depends(get_db)):
    """Get module by ID"""
    module = db.query(Module).filter(Module.id == module_id).first()
    if not module:
        raise HTTPException(status_code=404, detail="Module not found")
    return module

