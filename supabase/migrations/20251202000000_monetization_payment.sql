-- Phase 11: Monetization & Payment System
-- Database migration for subscription plans, credits, payments, etc.

-- Subscription Plans
CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    features JSONB DEFAULT '{}',
    credit_included INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Subscriptions
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'active',
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Credits
CREATE TABLE IF NOT EXISTS user_credits (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    balance DECIMAL(10,2) DEFAULT 0,
    total_earned DECIMAL(10,2) DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit Transactions
CREATE TABLE IF NOT EXISTS credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    related_item_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payment Transactions
CREATE TABLE IF NOT EXISTS payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'THB',
    payment_method VARCHAR(50),
    payment_provider VARCHAR(100),
    provider_transaction_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Pricing
CREATE TABLE IF NOT EXISTS content_pricing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    pricing_model VARCHAR(50) NOT NULL,
    price DECIMAL(10,2),
    credit_cost INTEGER DEFAULT 0,
    free_tier_limit INTEGER DEFAULT 0,
    trial_days INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Downloads
CREATE TABLE IF NOT EXISTS downloads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content_id UUID NOT NULL,
    download_type VARCHAR(50) DEFAULT 'free',
    payment_transaction_id UUID REFERENCES payment_transactions(id) ON DELETE SET NULL,
    download_url TEXT,
    expires_at TIMESTAMPTZ,
    download_count INTEGER DEFAULT 0,
    max_downloads INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_type ON credit_transactions(type);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_user_id ON payment_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_status ON payment_transactions(status);
CREATE INDEX IF NOT EXISTS idx_content_pricing_content_id ON content_pricing(content_id);
CREATE INDEX IF NOT EXISTS idx_downloads_user_id ON downloads(user_id);
CREATE INDEX IF NOT EXISTS idx_downloads_content_id ON downloads(content_id);

-- Insert default subscription plans
INSERT INTO subscription_plans (name, description, price_monthly, price_yearly, features, credit_included, status) VALUES
('Free Plan', 'Free tier with limited access', 0, 0, '{"content_access": "limited", "downloads": 5, "tools": "with_watermark"}'::jsonb, 100, 'active'),
('Basic Plan', 'Basic features for casual users', 299, 2990, '{"content_access": "unlimited", "downloads": 50, "tools": "no_watermark"}'::jsonb, 500, 'active'),
('Premium Plan', 'Premium features for power users', 599, 5990, '{"content_access": "unlimited", "downloads": "unlimited", "tools": "premium", "priority_support": true}'::jsonb, 1000, 'active'),
('Enterprise Plan', 'Enterprise features for businesses', NULL, NULL, '{"content_access": "unlimited", "downloads": "unlimited", "tools": "enterprise", "priority_support": true, "custom_features": true}'::jsonb, 5000, 'active')
ON CONFLICT DO NOTHING;

-- RLS Policies (if using Supabase)
-- ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE content_pricing ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;

