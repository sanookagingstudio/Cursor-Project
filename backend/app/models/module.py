"""Module (Plugin) Registry model"""
from sqlalchemy import Column, String, DateTime, JSON, Boolean
from datetime import datetime
from app.core.db import Base


class Module(Base):
    """Module model - plugin registry"""
    __tablename__ = "modules"
    
    id = Column(String(100), primary_key=True)  # "image.basic", "video.render", etc.
    name = Column(String(255), nullable=False)
    category = Column(String(50), nullable=False)  # "image", "video", "audio", "music", "generic"
    version = Column(String(50), nullable=False)
    active = Column(Boolean, default=True)
    capabilities = Column(JSON, nullable=False)  # operations, input_types, output_types, max_batch
    cost_profile = Column(JSON, nullable=True)  # cost estimation
    endpoint = Column(String(255), nullable=True)  # worker endpoint or external API
    endpoint_type = Column(String(50), default="internal")  # "internal", "external"
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<Module(id={self.id}, name={self.name}, category={self.category})>"

