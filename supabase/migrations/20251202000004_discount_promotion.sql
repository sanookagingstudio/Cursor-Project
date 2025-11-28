-- Phase 13: Discount & Promotion System
-- Database migration for discount codes, usage tracking, and analytics

-- Discount Codes
CREATE TABLE IF NOT EXISTS discount_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type VARCHAR(50) NOT NULL, -- "percentage", "fixed_amount", "free_item", "buy_x_get_y"
    discount_value DECIMAL(10,2) NOT NULL, -- Percentage or amount
    min_purchase_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2), -- For percentage discounts
    applicable_to VARCHAR(50) NOT NULL, -- "trip", "activity", "media_service", "digital_download", "subscription", "credit", "content", "all"
    applicable_item_ids UUID[], -- Specific items (optional)
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    usage_limit INTEGER, -- Total usage limit
    usage_count INTEGER DEFAULT 0,
    user_limit INTEGER DEFAULT 1, -- Per user limit
    first_time_only BOOLEAN DEFAULT false,
    user_group VARCHAR(50) DEFAULT 'all', -- "all", "member", "premium", "staff"
    status VARCHAR(50) DEFAULT 'active', -- "active", "inactive", "expired"
    auto_apply BOOLEAN DEFAULT false,
    stackable BOOLEAN DEFAULT false,
    meta_data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Discount Usage
CREATE TABLE IF NOT EXISTS discount_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discount_code_id UUID REFERENCES discount_codes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    order_id UUID, -- Reference to order/transaction
    item_type VARCHAR(50) NOT NULL, -- "trip", "activity", "media_service", "digital_download", "subscription", "credit", "content"
    item_id UUID,
    original_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    final_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMPTZ DEFAULT NOW()
);

-- Discount Analytics
CREATE TABLE IF NOT EXISTS discount_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discount_code_id UUID REFERENCES discount_codes(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    usage_count INTEGER DEFAULT 0,
    total_discount_amount DECIMAL(10,2) DEFAULT 0,
    total_revenue DECIMAL(10,2) DEFAULT 0,
    new_users_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(discount_code_id, date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_discount_codes_code ON discount_codes(code);
CREATE INDEX IF NOT EXISTS idx_discount_codes_status ON discount_codes(status);
CREATE INDEX IF NOT EXISTS idx_discount_codes_applicable_to ON discount_codes(applicable_to);
CREATE INDEX IF NOT EXISTS idx_discount_codes_valid_from ON discount_codes(valid_from);
CREATE INDEX IF NOT EXISTS idx_discount_codes_valid_until ON discount_codes(valid_until);
CREATE INDEX IF NOT EXISTS idx_discount_usage_discount_code_id ON discount_usage(discount_code_id);
CREATE INDEX IF NOT EXISTS idx_discount_usage_user_id ON discount_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_discount_usage_item_type ON discount_usage(item_type);
CREATE INDEX IF NOT EXISTS idx_discount_analytics_discount_code_id ON discount_analytics(discount_code_id);
CREATE INDEX IF NOT EXISTS idx_discount_analytics_date ON discount_analytics(date);

-- Insert default discount codes for first-time users
INSERT INTO discount_codes (code, name, description, discount_type, discount_value, applicable_to, valid_from, valid_until, first_time_only, auto_apply, status) VALUES
('WELCOME10', 'Welcome 10% Off', '10% off for first-time users', 'percentage', 10, 'all', NOW(), NOW() + INTERVAL '1 year', true, true, 'active'),
('FIRST100', 'First Time ฿100 Off', '฿100 off for first purchase', 'fixed_amount', 100, 'all', NOW(), NOW() + INTERVAL '1 year', true, true, 'active')
ON CONFLICT (code) DO NOTHING;

