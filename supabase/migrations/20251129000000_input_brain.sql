-- Phase 2: Input Brain Module
-- Content Ideas, Idea Versions, and Workflow Drafts

-- Content Ideas Table
CREATE TABLE IF NOT EXISTS content_ideas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('image', 'video', 'music', 'mixed')),
    prompt TEXT NOT NULL,
    options JSONB DEFAULT '{}',
    ai_suggestions JSONB DEFAULT '{}',
    selected_version INTEGER,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'selected', 'converted_to_workflow')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Idea Versions Table
CREATE TABLE IF NOT EXISTS idea_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idea_id UUID REFERENCES content_ideas(id) ON DELETE CASCADE,
    version_index INTEGER NOT NULL,
    preview_asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(idea_id, version_index)
);

-- Workflow Drafts Table
CREATE TABLE IF NOT EXISTS workflow_drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idea_id UUID REFERENCES content_ideas(id) ON DELETE CASCADE,
    steps JSONB NOT NULL DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'ready', 'started')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_content_ideas_project_id ON content_ideas(project_id);
CREATE INDEX IF NOT EXISTS idx_content_ideas_status ON content_ideas(status);
CREATE INDEX IF NOT EXISTS idx_content_ideas_type ON content_ideas(type);
CREATE INDEX IF NOT EXISTS idx_idea_versions_idea_id ON idea_versions(idea_id);
CREATE INDEX IF NOT EXISTS idx_workflow_drafts_idea_id ON workflow_drafts(idea_id);
CREATE INDEX IF NOT EXISTS idx_workflow_drafts_status ON workflow_drafts(status);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_content_ideas_updated_at BEFORE UPDATE ON content_ideas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_drafts_updated_at BEFORE UPDATE ON workflow_drafts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE content_ideas IS 'Stores user content ideas and prompts';
COMMENT ON TABLE idea_versions IS 'Stores AI-generated versions of content ideas';
COMMENT ON TABLE workflow_drafts IS 'Stores workflow drafts generated from selected idea versions';

