-- Phase 12: External Application Integration System
-- Database migration for external applications, API keys, usage tracking, etc.

-- External Applications
CREATE TABLE IF NOT EXISTS external_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    app_type VARCHAR(50), -- "mobile", "desktop", "web", "api"
    app_url VARCHAR(500),
    app_identifier VARCHAR(255) UNIQUE, -- Bundle ID, Package Name, etc.
    status VARCHAR(50) DEFAULT 'pending', -- "active", "suspended", "pending"
    pricing_model VARCHAR(50), -- "free", "paid", "subscription", "credit"
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- API Keys
CREATE TABLE IF NOT EXISTS api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) UNIQUE NOT NULL, -- Hashed API key
    key_prefix VARCHAR(20) NOT NULL, -- First 8 chars for display
    name VARCHAR(255), -- Key name/description
    scopes TEXT[], -- ["read:content", "write:content", "payment:process"]
    rate_limit INTEGER DEFAULT 1000, -- Requests per hour
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'active', -- "active", "revoked", "expired"
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Users
CREATE TABLE IF NOT EXISTS external_app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    external_user_id VARCHAR(255), -- User ID in external app
    master_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Linked Master V2 user (optional)
    user_data JSONB DEFAULT '{}', -- User info from external app
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(app_id, external_user_id)
);

-- External App Usage
CREATE TABLE IF NOT EXISTS external_app_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    api_key_id UUID REFERENCES api_keys(id) ON DELETE SET NULL,
    user_id UUID REFERENCES external_app_users(id) ON DELETE SET NULL,
    endpoint VARCHAR(255),
    method VARCHAR(10), -- "GET", "POST", etc.
    request_data JSONB DEFAULT '{}',
    response_status INTEGER,
    response_data JSONB DEFAULT '{}',
    cost DECIMAL(10,4), -- Cost for this request
    credits_used INTEGER DEFAULT 0,
    duration_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Pricing
CREATE TABLE IF NOT EXISTS external_app_pricing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    feature_name VARCHAR(255), -- "image_generation", "video_processing", etc.
    pricing_type VARCHAR(50), -- "per_request", "subscription", "credit", "free"
    price_per_request DECIMAL(10,4),
    credit_cost INTEGER,
    free_tier_limit INTEGER, -- Free requests per day/month
    subscription_price DECIMAL(10,2),
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Subscriptions
CREATE TABLE IF NOT EXISTS external_app_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES external_app_users(id) ON DELETE CASCADE,
    plan_name VARCHAR(255),
    price DECIMAL(10,2),
    billing_cycle VARCHAR(20), -- "monthly", "yearly"
    status VARCHAR(50) DEFAULT 'active',
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Payments
CREATE TABLE IF NOT EXISTS external_app_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES external_app_users(id) ON DELETE CASCADE,
    amount DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'THB',
    payment_type VARCHAR(50), -- "credit_purchase", "subscription", "one_time"
    status VARCHAR(50) DEFAULT 'pending',
    provider_transaction_id VARCHAR(255),
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_external_applications_status ON external_applications(status);
CREATE INDEX IF NOT EXISTS idx_api_keys_app_id ON api_keys(app_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_status ON api_keys(status);
CREATE INDEX IF NOT EXISTS idx_external_app_users_app_id ON external_app_users(app_id);
CREATE INDEX IF NOT EXISTS idx_external_app_usage_app_id ON external_app_usage(app_id);
CREATE INDEX IF NOT EXISTS idx_external_app_usage_created_at ON external_app_usage(created_at);

