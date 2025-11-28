"""
Cost & Infrastructure Management Service
Business logic for Phase 9
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc
from datetime import date, timedelta
from typing import Optional, List, Dict, Any
from uuid import UUID
from decimal import Decimal

from app.models.cost import (
    InfrastructureItem,
    AIProviderCost,
    ThirdPartyIntegration,
    CostRecord
)
from app.schemas.cost import (
    InfrastructureItemCreate,
    InfrastructureItemUpdate,
    AIProviderCostCreate,
    AIProviderCostUpdate,
    ThirdPartyIntegrationCreate,
    ThirdPartyIntegrationUpdate
)


class CostService:
    """Service for cost and infrastructure management operations"""

    # Infrastructure Items
    @staticmethod
    def get_infrastructure_items(db: Session, item_type: Optional[str] = None) -> List[InfrastructureItem]:
        """Get all infrastructure items"""
        query = db.query(InfrastructureItem)
        if item_type:
            query = query.filter(InfrastructureItem.type == item_type)
        return query.all()

    @staticmethod
    def create_infrastructure_item(db: Session, item_data: InfrastructureItemCreate) -> InfrastructureItem:
        """Create a new infrastructure item"""
        item = InfrastructureItem(**item_data.model_dump())
        db.add(item)
        db.commit()
        db.refresh(item)
        return item

    @staticmethod
    def update_infrastructure_item(db: Session, item_id: UUID, item_data: InfrastructureItemUpdate) -> Optional[InfrastructureItem]:
        """Update infrastructure item"""
        item = db.query(InfrastructureItem).filter(InfrastructureItem.id == item_id).first()
        if not item:
            return None
        
        update_data = item_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(item, key, value)
        
        db.commit()
        db.refresh(item)
        return item

    # AI Provider Costs
    @staticmethod
    def get_ai_providers(db: Session, service_type: Optional[str] = None) -> List[AIProviderCost]:
        """Get all AI providers"""
        query = db.query(AIProviderCost)
        if service_type:
            query = query.filter(AIProviderCost.service_type == service_type)
        return query.all()

    @staticmethod
    def create_ai_provider(db: Session, provider_data: AIProviderCostCreate) -> AIProviderCost:
        """Create a new AI provider cost record"""
        provider = AIProviderCost(**provider_data.model_dump())
        db.add(provider)
        db.commit()
        db.refresh(provider)
        return provider

    @staticmethod
    def update_ai_provider(db: Session, provider_id: UUID, provider_data: AIProviderCostUpdate) -> Optional[AIProviderCost]:
        """Update AI provider cost"""
        provider = db.query(AIProviderCost).filter(AIProviderCost.id == provider_id).first()
        if not provider:
            return None
        
        update_data = provider_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(provider, key, value)
        
        db.commit()
        db.refresh(provider)
        return provider

    # Third-Party Integrations
    @staticmethod
    def get_third_party_integrations(db: Session, integration_type: Optional[str] = None) -> List[ThirdPartyIntegration]:
        """Get all third-party integrations"""
        query = db.query(ThirdPartyIntegration)
        if integration_type:
            query = query.filter(ThirdPartyIntegration.integration_type == integration_type)
        return query.all()

    @staticmethod
    def create_third_party_integration(db: Session, integration_data: ThirdPartyIntegrationCreate) -> ThirdPartyIntegration:
        """Create a new third-party integration"""
        integration = ThirdPartyIntegration(**integration_data.model_dump())
        db.add(integration)
        db.commit()
        db.refresh(integration)
        return integration

    @staticmethod
    def update_third_party_integration(db: Session, integration_id: UUID, integration_data: ThirdPartyIntegrationUpdate) -> Optional[ThirdPartyIntegration]:
        """Update third-party integration"""
        integration = db.query(ThirdPartyIntegration).filter(ThirdPartyIntegration.id == integration_id).first()
        if not integration:
            return None
        
        update_data = integration_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(integration, key, value)
        
        db.commit()
        db.refresh(integration)
        return integration

    # Cost Summary
    @staticmethod
    def get_cost_summary(db: Session) -> Dict[str, Any]:
        """Get cost summary"""
        # Infrastructure costs
        infrastructure_items = db.query(InfrastructureItem).filter(
            InfrastructureItem.status == "active"
        ).all()
        infrastructure_cost = sum(
            (item.cost_per_period or Decimal("0")) * (12 if item.period == "yearly" else 1) / 12
            for item in infrastructure_items
        )
        
        # AI provider costs
        ai_providers = db.query(AIProviderCost).filter(
            AIProviderCost.api_key_status == "active"
        ).all()
        ai_cost = sum(provider.monthly_cost or Decimal("0") for provider in ai_providers)
        
        # Third-party costs
        third_party = db.query(ThirdPartyIntegration).filter(
            ThirdPartyIntegration.status == "active"
        ).all()
        third_party_cost = sum(integration.monthly_cost or Decimal("0") for integration in third_party)
        
        total_cost = infrastructure_cost + ai_cost + third_party_cost
        
        # Upcoming renewals (next 30 days)
        upcoming_renewals = []
        for item in infrastructure_items:
            if item.renewal_date:
                days_until = (item.renewal_date - date.today()).days
                if 0 <= days_until <= 30:
                    upcoming_renewals.append({
                        "item": item.name,
                        "type": item.type,
                        "renewal_date": item.renewal_date.isoformat(),
                        "cost": float(item.cost_per_period or 0)
                    })
        
        return {
            "total_monthly_cost": float(total_cost),
            "cost_by_category": {
                "infrastructure": float(infrastructure_cost),
                "ai_services": float(ai_cost),
                "third_party": float(third_party_cost)
            },
            "cost_trends": [],  # TODO: Calculate trends from cost_records
            "upcoming_renewals": upcoming_renewals
        }

