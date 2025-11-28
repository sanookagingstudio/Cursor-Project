"""Cost record model"""
from sqlalchemy import Column, String, DateTime, JSON, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from app.core.db import Base


class CostRecord(Base):
    """CostRecord model - tracks costs for jobs"""
    __tablename__ = "cost_records"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    job_id = Column(UUID(as_uuid=True), ForeignKey("jobs.id"), nullable=False)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    module_id = Column(String(100), nullable=False)
    provider = Column(String(100), nullable=True)  # "openai", "runway", etc.
    input_tokens = Column(Float, nullable=True)
    output_tokens = Column(Float, nullable=True)
    api_cost = Column(Float, default=0.0)  # API call cost
    compute_cost = Column(Float, default=0.0)  # GPU/compute cost
    total_cost = Column(Float, nullable=False)
    meta_data = Column("metadata", JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f"<CostRecord(id={self.id}, total_cost={self.total_cost})>"

