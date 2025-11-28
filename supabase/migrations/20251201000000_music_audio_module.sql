-- Phase 5: Music & Audio Module
-- Audio Analysis, Stem Groups, and Tab Records

-- Audio Analysis Table
CREATE TABLE IF NOT EXISTS audio_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    bpm FLOAT,
    key TEXT,  -- "C:maj", "A:min"
    time_signature TEXT,  -- "4/4", "6/8"
    sections JSONB DEFAULT '[]',
    chord_progression JSONB DEFAULT '[]',
    energy_curve JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stem Groups Table
CREATE TABLE IF NOT EXISTS stem_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    stem_assets JSONB NOT NULL DEFAULT '{}',  -- {"vocal": "uuid", "drums": "uuid", "bass": "uuid", "other": "uuid"}
    provider TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tab Records Table
CREATE TABLE IF NOT EXISTS tab_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    audio_asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    instrument TEXT NOT NULL CHECK (instrument IN ('guitar', 'bass', 'ukulele')),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'original', 'advanced')),
    format TEXT NOT NULL CHECK (format IN ('text', 'gp5', 'musicxml')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_audio_analysis_asset_id ON audio_analysis(asset_id);
CREATE INDEX IF NOT EXISTS idx_stem_groups_source_asset_id ON stem_groups(source_asset_id);
CREATE INDEX IF NOT EXISTS idx_tab_records_audio_asset_id ON tab_records(audio_asset_id);
CREATE INDEX IF NOT EXISTS idx_tab_records_instrument ON tab_records(instrument);

-- Comments
COMMENT ON TABLE audio_analysis IS 'Stores music analysis results (BPM, key, chords, structure)';
COMMENT ON TABLE stem_groups IS 'Stores stem separation results (vocal, drums, bass, other)';
COMMENT ON TABLE tab_records IS 'Stores generated tabs for instruments (guitar, bass, ukulele)';

