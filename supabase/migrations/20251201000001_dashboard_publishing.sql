-- Phase 6: Dashboard & Publishing Module
-- Platform Accounts, Content Channels, Series, Episodes, Publications, Performance, Revenue

-- Platform Accounts Table
CREATE TABLE IF NOT EXISTS platform_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('youtube', 'tiktok', 'facebook', 'instagram', 'twitter')),
    external_id TEXT,
    name TEXT,
    handle TEXT,
    metadata JSONB DEFAULT '{}',
    auth_config JSONB DEFAULT '{}',  -- encrypted tokens
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Channels Table
CREATE TABLE IF NOT EXISTS content_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Channel Platform Links Table
CREATE TABLE IF NOT EXISTS content_channel_platform_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_channel_id UUID REFERENCES content_channels(id) ON DELETE CASCADE,
    platform_account_id UUID REFERENCES platform_accounts(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('primary', 'secondary')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(content_channel_id, platform_account_id)
);

-- Series Table
CREATE TABLE IF NOT EXISTS series (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_channel_id UUID REFERENCES content_channels(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Episodes Table
CREATE TABLE IF NOT EXISTS episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    series_id UUID REFERENCES series(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    primary_asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL CHECK (status IN ('draft', 'ready', 'publishing', 'published')) DEFAULT 'draft',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Publication Records Table
CREATE TABLE IF NOT EXISTS publication_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    episode_id UUID REFERENCES episodes(id) ON DELETE CASCADE,
    platform_account_id UUID REFERENCES platform_accounts(id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    external_post_id TEXT,
    status TEXT NOT NULL CHECK (status IN ('scheduled', 'published', 'failed')) DEFAULT 'scheduled',
    scheduled_time TIMESTAMPTZ,
    published_time TIMESTAMPTZ,
    fail_reason TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance Snapshots Table
CREATE TABLE IF NOT EXISTS performance_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_id UUID REFERENCES publication_records(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    shares INTEGER DEFAULT 0,
    watch_time_seconds FLOAT DEFAULT 0,
    ctr FLOAT DEFAULT 0,
    engagement_rate FLOAT DEFAULT 0,
    estimated_revenue FLOAT DEFAULT 0,
    metadata JSONB DEFAULT '{}'
);

-- Revenue Records Table
CREATE TABLE IF NOT EXISTS revenue_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_id UUID REFERENCES publication_records(id) ON DELETE CASCADE,
    source TEXT NOT NULL CHECK (source IN ('adsense', 'creator_fund', 'product_sale', 'sponsorship')),
    amount FLOAT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'THB',
    period_start DATE,
    period_end DATE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_platform_accounts_user_id ON platform_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_platform_accounts_platform ON platform_accounts(platform);
CREATE INDEX IF NOT EXISTS idx_content_channels_owner_id ON content_channels(owner_id);
CREATE INDEX IF NOT EXISTS idx_channel_platform_links_channel_id ON content_channel_platform_links(content_channel_id);
CREATE INDEX IF NOT EXISTS idx_series_channel_id ON series(content_channel_id);
CREATE INDEX IF NOT EXISTS idx_episodes_series_id ON episodes(series_id);
CREATE INDEX IF NOT EXISTS idx_episodes_project_id ON episodes(project_id);
CREATE INDEX IF NOT EXISTS idx_episodes_status ON episodes(status);
CREATE INDEX IF NOT EXISTS idx_publication_records_episode_id ON publication_records(episode_id);
CREATE INDEX IF NOT EXISTS idx_publication_records_platform_account_id ON publication_records(platform_account_id);
CREATE INDEX IF NOT EXISTS idx_publication_records_status ON publication_records(status);
CREATE INDEX IF NOT EXISTS idx_performance_snapshots_publication_id ON performance_snapshots(publication_id);
CREATE INDEX IF NOT EXISTS idx_revenue_records_publication_id ON revenue_records(publication_id);

-- Comments
COMMENT ON TABLE platform_accounts IS 'Platform accounts (YouTube, TikTok, Facebook, etc.)';
COMMENT ON TABLE content_channels IS 'Content channels that organize series and episodes';
COMMENT ON TABLE content_channel_platform_links IS 'Links between content channels and platform accounts';
COMMENT ON TABLE series IS 'Series within a content channel';
COMMENT ON TABLE episodes IS 'Episodes within a series, linked to projects and assets';
COMMENT ON TABLE publication_records IS 'Records of publications to platforms';
COMMENT ON TABLE performance_snapshots IS 'Performance metrics snapshots for publications';
COMMENT ON TABLE revenue_records IS 'Revenue records from publications';

