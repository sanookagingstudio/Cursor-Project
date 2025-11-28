-- Phase 9: Cost & Infrastructure Management System
-- Database migration for infrastructure items, AI providers, third-party integrations, cost records

-- Infrastructure Items
CREATE TABLE IF NOT EXISTS infrastructure_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- "domain", "hosting", "cdn", "storage"
    provider VARCHAR(255),
    cost_per_period DECIMAL(10,2),
    period VARCHAR(20), -- "monthly", "yearly"
    renewal_date DATE,
    status VARCHAR(50) DEFAULT 'active', -- "active", "expiring", "expired"
    auto_renewal BOOLEAN DEFAULT false,
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Provider Costs
CREATE TABLE IF NOT EXISTS ai_provider_costs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_name VARCHAR(255) NOT NULL,
    service_type VARCHAR(50), -- "image", "video", "audio", "text"
    pricing_model VARCHAR(50), -- "pay_per_use", "subscription", "free"
    cost_per_request DECIMAL(10,4),
    monthly_cost DECIMAL(10,2),
    free_tier_limit INTEGER,
    current_usage INTEGER DEFAULT 0,
    billing_cycle VARCHAR(20), -- "monthly", "yearly"
    api_key_status VARCHAR(50) DEFAULT 'active', -- "active", "expired", "invalid"
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Third-Party Integrations
CREATE TABLE IF NOT EXISTS third_party_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name VARCHAR(255) NOT NULL,
    integration_type VARCHAR(50), -- "auth", "payment", "database", etc.
    provider VARCHAR(255),
    pricing_model VARCHAR(50),
    monthly_cost DECIMAL(10,2),
    usage_limit INTEGER,
    current_usage INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active', -- "active", "suspended", "expired"
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cost Records (Historical)
CREATE TABLE IF NOT EXISTS cost_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_type VARCHAR(50) NOT NULL, -- "infrastructure", "ai_provider", "third_party"
    item_id UUID NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    period_start DATE,
    period_end DATE,
    usage_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_infrastructure_items_type ON infrastructure_items(type);
CREATE INDEX IF NOT EXISTS idx_infrastructure_items_status ON infrastructure_items(status);
CREATE INDEX IF NOT EXISTS idx_ai_provider_costs_provider ON ai_provider_costs(provider_name);
CREATE INDEX IF NOT EXISTS idx_ai_provider_costs_service_type ON ai_provider_costs(service_type);
CREATE INDEX IF NOT EXISTS idx_third_party_integrations_type ON third_party_integrations(integration_type);
CREATE INDEX IF NOT EXISTS idx_cost_records_item_type ON cost_records(item_type);
CREATE INDEX IF NOT EXISTS idx_cost_records_item_id ON cost_records(item_id);

