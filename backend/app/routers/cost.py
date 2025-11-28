"""
Cost & Infrastructure Management API Router
FastAPI endpoints for Phase 9
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.core.db import get_db
from app.services.cost_service import CostService
from app.schemas.cost import (
    InfrastructureItemCreate,
    InfrastructureItemUpdate,
    InfrastructureItemResponse,
    AIProviderCostCreate,
    AIProviderCostUpdate,
    AIProviderCostResponse,
    ThirdPartyIntegrationCreate,
    ThirdPartyIntegrationUpdate,
    ThirdPartyIntegrationResponse,
    CostSummary
)

router = APIRouter()


# Infrastructure Items
@router.get("/infrastructure", response_model=List[InfrastructureItemResponse])
def get_infrastructure_items(
    item_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all infrastructure items"""
    return CostService.get_infrastructure_items(db, item_type)


@router.post("/infrastructure", response_model=InfrastructureItemResponse, status_code=status.HTTP_201_CREATED)
def create_infrastructure_item(
    item_data: InfrastructureItemCreate,
    db: Session = Depends(get_db)
):
    """Create a new infrastructure item"""
    return CostService.create_infrastructure_item(db, item_data)


@router.put("/infrastructure/{item_id}", response_model=InfrastructureItemResponse)
def update_infrastructure_item(
    item_id: UUID,
    item_data: InfrastructureItemUpdate,
    db: Session = Depends(get_db)
):
    """Update infrastructure item"""
    item = CostService.update_infrastructure_item(db, item_id, item_data)
    if not item:
        raise HTTPException(status_code=404, detail="Infrastructure item not found")
    return item


# AI Provider Costs
@router.get("/ai-providers", response_model=List[AIProviderCostResponse])
def get_ai_providers(
    service_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all AI providers"""
    return CostService.get_ai_providers(db, service_type)


@router.post("/ai-providers", response_model=AIProviderCostResponse, status_code=status.HTTP_201_CREATED)
def create_ai_provider(
    provider_data: AIProviderCostCreate,
    db: Session = Depends(get_db)
):
    """Create a new AI provider cost record"""
    return CostService.create_ai_provider(db, provider_data)


@router.put("/ai-providers/{provider_id}", response_model=AIProviderCostResponse)
def update_ai_provider(
    provider_id: UUID,
    provider_data: AIProviderCostUpdate,
    db: Session = Depends(get_db)
):
    """Update AI provider cost"""
    provider = CostService.update_ai_provider(db, provider_id, provider_data)
    if not provider:
        raise HTTPException(status_code=404, detail="AI provider not found")
    return provider


# Third-Party Integrations
@router.get("/third-party", response_model=List[ThirdPartyIntegrationResponse])
def get_third_party_integrations(
    integration_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all third-party integrations"""
    return CostService.get_third_party_integrations(db, integration_type)


@router.post("/third-party", response_model=ThirdPartyIntegrationResponse, status_code=status.HTTP_201_CREATED)
def create_third_party_integration(
    integration_data: ThirdPartyIntegrationCreate,
    db: Session = Depends(get_db)
):
    """Create a new third-party integration"""
    return CostService.create_third_party_integration(db, integration_data)


@router.put("/third-party/{integration_id}", response_model=ThirdPartyIntegrationResponse)
def update_third_party_integration(
    integration_id: UUID,
    integration_data: ThirdPartyIntegrationUpdate,
    db: Session = Depends(get_db)
):
    """Update third-party integration"""
    integration = CostService.update_third_party_integration(db, integration_id, integration_data)
    if not integration:
        raise HTTPException(status_code=404, detail="Third-party integration not found")
    return integration


# Cost Summary
@router.get("/summary", response_model=CostSummary)
def get_cost_summary(
    db: Session = Depends(get_db)
):
    """Get cost summary"""
    return CostService.get_cost_summary(db)

