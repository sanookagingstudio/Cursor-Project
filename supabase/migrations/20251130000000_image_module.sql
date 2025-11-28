-- Phase 3: Image Module
-- Template Layouts for Image Templates

-- Template Layouts Table
CREATE TABLE IF NOT EXISTS template_layouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN (
        'poster', 'story', 'infographic', 'coloring_book', 
        'pattern', 'origami', 'card_game', 'playing_cards', 
        'board_game', 'emoji', 'sticker', 'quote_90s', 'caption'
    )),
    structure_json JSONB NOT NULL DEFAULT '{}',
    preview_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_template_layouts_category ON template_layouts(category);
CREATE INDEX IF NOT EXISTS idx_template_layouts_name ON template_layouts(name);

-- Updated_at trigger
CREATE TRIGGER update_template_layouts_updated_at BEFORE UPDATE ON template_layouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE template_layouts IS 'Stores template layouts for image generation (Canva-like templates)';

