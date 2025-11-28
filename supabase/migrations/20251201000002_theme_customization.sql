-- Phase 8: Theme Customization System (เทพช้อป)
-- Theme configurations, settings, and user preferences

-- Themes Table
CREATE TABLE IF NOT EXISTS themes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_preset BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT false,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Theme Settings Table
CREATE TABLE IF NOT EXISTS theme_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    theme_id UUID REFERENCES themes(id) ON DELETE CASCADE,
    settings JSONB NOT NULL,  -- All theme configs (colors, typography, spacing, layout, components, effects)
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Theme Preferences Table
CREATE TABLE IF NOT EXISTS user_theme_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    theme_id UUID REFERENCES themes(id) ON DELETE SET NULL,
    custom_settings JSONB,  -- Override specific settings
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_themes_is_active ON themes(is_active);
CREATE INDEX IF NOT EXISTS idx_themes_is_preset ON themes(is_preset);
CREATE INDEX IF NOT EXISTS idx_theme_settings_theme_id ON theme_settings(theme_id);
CREATE INDEX IF NOT EXISTS idx_user_theme_preferences_user_id ON user_theme_preferences(user_id);

-- Insert Default Presets
INSERT INTO themes (id, name, description, is_preset, is_active) VALUES
    (gen_random_uuid(), 'Default FUN Theme', 'Default theme with FUN brand colors', true, true),
    (gen_random_uuid(), 'High Contrast Theme', 'High contrast theme for elderly users', true, false),
    (gen_random_uuid(), 'Large Text Theme', 'Theme with larger fonts for better readability', true, false),
    (gen_random_uuid(), 'Compact Theme', 'Theme with reduced spacing', true, false),
    (gen_random_uuid(), 'Colorful Theme', 'Theme with more vibrant colors', true, false),
    (gen_random_uuid(), 'Minimal Theme', 'Minimal and clean theme', true, false)
ON CONFLICT DO NOTHING;

-- Comments
COMMENT ON TABLE themes IS 'Theme configurations';
COMMENT ON TABLE theme_settings IS 'Theme settings (colors, typography, spacing, layout, components, effects)';
COMMENT ON TABLE user_theme_preferences IS 'User-specific theme preferences and overrides';

