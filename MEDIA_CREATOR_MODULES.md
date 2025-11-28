# 🎬 Media Creator Modules Integration Plan
## Video Module | Music Module | Dashboard & Publishing Module

---

## 📊 สรุปภาพรวม 3 โมดูล

### 🎥 Video Module (โมดูล 4)
**เป้าหมาย:** AI Capcut + Runway Layer - สร้างและตัดต่อวิดีโออัตโนมัติ

### 🎵 Music & Audio Module (โมดูล 5)
**เป้าหมาย:** AI Music Lab - วิเคราะห์/แยก stem/สร้างเพลง/ทำ Tab

### 📊 Dashboard & Publishing Module (โมดูล 6)
**เป้าหมาย:** Control Center + Auto Posting - จัดการ content และโพสต์อัตโนมัติ

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface                         │
│  (Frontend: React + TypeScript)                          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│              API Layer (FastAPI)                         │
│  /video/*  |  /audio/*  |  /music/*  |  /dashboard/*     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         Logic Layer (Business Logic)                     │
│  Video Logic | Music Logic | Publishing Logic            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         Provider Adapters (Plugin System)                 │
│  Video: Runway, Pika, FFmpeg                             │
│  Music: Demucs, MusicGen, TTS                            │
│  Publishing: YouTube, TikTok, Facebook APIs              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         Core Foundation                                  │
│  Jobs | Assets | Events | Workers (Celery)               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│         Database (PostgreSQL)                            │
│  + Redis (Queue)                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎥 MODULE 4: VIDEO MODULE

### Functional Requirements

#### ✅ 2.1 Video Generation
- [x] สร้าง VDO จาก prompt
- [x] สร้างจาก Storyboard
- [x] สร้างจากภาพชุด (slide show)
- [x] สร้างจาก script text
- [x] รองรับหลาย provider (Runway, Pika, Luma, FFmpeg)

#### ✅ 2.2 Video Editing / Auto Editing
- [x] Auto-cut ช่วงเงียบ/ผิด/ซ้ำ
- [x] Auto transition
- [x] Auto crop/reframe (16:9 → 9:16)
- [x] Auto speed adjust
- [x] Cut by beat
- [x] สร้างหลายเวอร์ชันจาก source เดียว

#### ✅ 2.3 Subtitle & Caption
- [x] ถอดเสียง → text
- [x] Auto subtitle
- [x] แปลหลายภาษา
- [x] Style แบบ TikTok
- [x] Export SRT/VTT หรือ burn-in

#### ✅ 2.4 Audio & Music Integration
- [x] ผูกกับ Music Module
- [x] Auto sync beat
- [x] Audio ducking
- [x] Noise reduction, normalize

#### ✅ 2.5 Multi-Format Output
- [x] YouTube (16:9)
- [x] TikTok/Reels (9:16)
- [x] Facebook Feed (4:5)
- [x] Square (1:1)

#### ✅ 2.6 Batch Processing
- [x] ตัดคลิปย่อยจาก livestream
- [x] สร้าง short 10-20 คลิป
- [x] ทำชุดโฆษณาหลายเวอร์ชัน

### Data Model

```sql
-- Video-specific metadata (stored in Asset.metadata)
-- No separate table needed, use Asset.metadata JSON

-- VideoJobInput (stored in Job.input_payload)
{
  "mode": "generate" | "edit" | "multi_export",
  "provider": "runway" | "pika" | "internal_ffmpeg",
  "prompt": "...",
  "duration_seconds": 15,
  "aspect_ratio": "9:16",
  "resolution": "1080x1920",
  "style": "cinematic",
  "source_assets": [],
  "audio_preset": "lofi",
  "language": "th"
}

-- VideoEditJobInput
{
  "mode": "edit",
  "provider": "internal_ffmpeg",
  "source_video_id": "uuid",
  "operations": [
    {"type": "auto_cut_silence", "threshold_db": -35},
    {"type": "auto_reframe", "target_aspect_ratio": "9:16"},
    {"type": "add_subtitle", "subtitle_mode": "auto"}
  ],
  "target_outputs": [...]
}

-- SubtitleJobInput
{
  "video_asset_id": "uuid",
  "source_language": "auto",
  "target_languages": ["th", "en"],
  "style": "tiktok"
}
```

### API Endpoints

```python
POST /video/generate
POST /video/edit
POST /video/multi-export
POST /video/subtitle
GET /video/{asset_id}/details
```

### Workers

```python
@celery.task(name="video.generate")
def video_generate(job_id: str):
    # Generate video from prompt
    
@celery.task(name="video.edit")
def video_edit(job_id: str):
    # Edit existing video
    
@celery.task(name="video.subtitle")
def video_subtitle(job_id: str):
    # Generate subtitles
```

### Provider Interface

```python
class VideoProviderBase:
    def generate_video(self, params: dict) -> str:
        """return path of generated video"""
        
    def edit_video(self, source_path: str, operations: list, output_config: dict) -> str:
        """apply operations and return new path"""
        
    def subtitle_video(self, source_path: str, options: dict) -> dict:
        """return transcript, subtitle files"""
```

---

## 🎵 MODULE 5: MUSIC & AUDIO INTELLIGENCE

### Functional Requirements

#### ✅ 2.1 Audio Source & Import
- [x] Upload audio files
- [x] Import from existing Assets
- [x] Convert to internal format (WAV, 48kHz)

#### ✅ 2.2 Stem Separation
- [x] แยก vocal, drums, bass, other
- [x] รองรับหลาย provider (Demucs, Spleeter, LALAL)
- [x] เก็บแต่ละ stem เป็น Asset ใหม่

#### ✅ 2.3 Music Analysis
- [x] BPM detection
- [x] Key detection (A minor, C major)
- [x] Scale type
- [x] Chord progression
- [x] Song structure (intro/verse/chorus/bridge)

#### ✅ 2.4 Tab & Chord Generator
- [x] สร้าง Tab สำหรับ Guitar, Bass, Ukulele
- [x] ระดับ: easy, original, advanced
- [x] Export: text, Guitar Pro, MusicXML

#### ✅ 2.5 Audio Remaster / Enhancement
- [x] Noise reduction
- [x] EQ (warm/bright/vocal boost)
- [x] Stereo widen/mono
- [x] Normalization
- [x] De-reverb

#### ✅ 2.6 AI Music Generation
- [x] สร้างเพลงจาก prompt
- [x] ระบุ duration, mood, instrument, tempo, key
- [x] รองรับ MusicGen, external APIs

#### ✅ 2.7 Podcast & Voice Tools
- [x] Cut/join/trim
- [x] Noise reduction
- [x] Normalization
- [x] Export podcast episode

### Data Model

```sql
-- AudioAnalysis
CREATE TABLE audio_analysis (
    id UUID PRIMARY KEY,
    asset_id UUID REFERENCES assets(id),
    bpm FLOAT,
    key TEXT,  -- "C:maj", "A:min"
    time_signature TEXT,  -- "4/4", "6/8"
    sections JSONB,  -- [{"name": "intro", "start": 0.0, "end": 10.5}]
    chord_progression JSONB,  -- [{"time": 0.0, "chord": "Cmaj7"}]
    energy_curve JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- StemGroup
CREATE TABLE stem_groups (
    id UUID PRIMARY KEY,
    source_asset_id UUID REFERENCES assets(id),
    stem_assets JSONB,  -- {"vocal": "uuid", "drums": "uuid", ...}
    provider TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TabRecord
CREATE TABLE tab_records (
    id UUID PRIMARY KEY,
    audio_asset_id UUID REFERENCES assets(id),
    instrument TEXT,  -- "guitar" | "bass" | "ukulele"
    difficulty TEXT,  -- "easy" | "original" | "advanced"
    format TEXT,  -- "text" | "gp5" | "musicxml"
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints

```python
POST /audio/stems
POST /music/analyze
POST /music/tab
POST /music/generate
POST /audio/remaster
GET /music/analysis/{audio_asset_id}
GET /music/tab/{audio_asset_id}
```

### Workers

```python
@celery.task(name="audio.stems")
def run_stem_separation(job_id: str):
    # Separate stems
    
@celery.task(name="music.analyze")
def analyze_music(job_id: str):
    # Analyze BPM, key, chords
    
@celery.task(name="music.tab")
def generate_tab(job_id: str):
    # Generate tab
    
@celery.task(name="music.generate")
def generate_music(job_id: str):
    # Generate new music
    
@celery.task(name="audio.remaster")
def remaster_audio(job_id: str):
    # Remaster audio
```

### Provider Interface

```python
class AudioProviderBase:
    def separate_stems(self, audio_path: str, stems: list[str]) -> dict:
        """return {"vocal": "/path/vocal.wav", ...}"""
        
    def analyze_music(self, audio_path: str, tasks: list[str]) -> dict:
        """return {"bpm": ..., "key": ..., "chords": [...], "sections": [...]}"""
        
    def generate_music(self, params: dict) -> str:
        """return path to generated audio file"""
        
    def remaster(self, audio_path: str, operations: list[dict]) -> str:
        """return path to new audio"""
```

---

## 📊 MODULE 6: DASHBOARD & PUBLISHING

### Functional Requirements

#### ✅ 1. Content Management
- [x] จัดการ Channel/Account/Series/Episode
- [x] Mapping หลาย platform ต่อ 1 channel
- [x] Track content ที่สร้างแล้ว

#### ✅ 2. Publishing Engine
- [x] Upload ไปหลาย platform
- [x] Schedule posting
- [x] จัดการหลาย platform/channel/series/episode
- [x] Auto-posting pipeline

#### ✅ 3. Business Dashboard
- [x] ดูรายได้, ต้นทุน, กำไร
- [x] ROI ต่อ content/channel/series
- [x] Performance metrics

#### ✅ 4. AI Advisor Interface
- [x] JARVIS ใช้ข้อมูลจาก Dashboard
- [x] ให้คำแนะนำจาก performance data

### Data Model

```sql
-- PlatformAccount
CREATE TABLE platform_accounts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    platform TEXT,  -- "youtube" | "tiktok" | "facebook"
    external_id TEXT,
    name TEXT,
    handle TEXT,
    metadata JSONB,
    auth_config JSONB,  -- encrypted tokens
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ContentChannel
CREATE TABLE content_channels (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id),
    name TEXT,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- content_channel_platform_link
CREATE TABLE content_channel_platform_links (
    id UUID PRIMARY KEY,
    content_channel_id UUID REFERENCES content_channels(id),
    platform_account_id UUID REFERENCES platform_accounts(id),
    role TEXT,  -- "primary" | "secondary"
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Series
CREATE TABLE series (
    id UUID PRIMARY KEY,
    content_channel_id UUID REFERENCES content_channels(id),
    name TEXT,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Episode
CREATE TABLE episodes (
    id UUID PRIMARY KEY,
    series_id UUID REFERENCES series(id),
    project_id UUID REFERENCES projects(id),
    primary_asset_id UUID REFERENCES assets(id),
    title TEXT,
    description TEXT,
    status TEXT,  -- "draft" | "ready" | "publishing" | "published"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PublicationRecord
CREATE TABLE publication_records (
    id UUID PRIMARY KEY,
    episode_id UUID REFERENCES episodes(id),
    platform_account_id UUID REFERENCES platform_accounts(id),
    platform TEXT,
    external_post_id TEXT,
    status TEXT,  -- "scheduled" | "published" | "failed"
    scheduled_time TIMESTAMPTZ,
    published_time TIMESTAMPTZ,
    fail_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PerformanceSnapshot
CREATE TABLE performance_snapshots (
    id UUID PRIMARY KEY,
    publication_id UUID REFERENCES publication_records(id),
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    views INTEGER,
    likes INTEGER,
    comments INTEGER,
    shares INTEGER,
    watch_time_seconds FLOAT,
    ctr FLOAT,
    engagement_rate FLOAT,
    estimated_revenue FLOAT,
    metadata JSONB
);

-- RevenueRecord (optional)
CREATE TABLE revenue_records (
    id UUID PRIMARY KEY,
    publication_id UUID REFERENCES publication_records(id),
    source TEXT,  -- "adsense" | "creator_fund" | "product_sale"
    amount FLOAT,
    currency TEXT,  -- "THB" | "USD"
    period_start DATE,
    period_end DATE,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints

```python
# Channel & Structure
POST /dashboard/channels
GET /dashboard/channels
GET /dashboard/channels/{id}
POST /dashboard/channels/{channel_id}/series
GET /dashboard/channels/{channel_id}/series
POST /dashboard/episodes
GET /dashboard/episodes/{id}
GET /dashboard/series/{series_id}/episodes

# Publishing
POST /publishing/plan
GET /publishing/episode/{episode_id}
GET /publishing/publication/{id}
POST /publishing/webhook/{platform}

# Performance & Analytics
GET /dashboard/overview?channel_id=...&range=last_30d
GET /dashboard/episodes/{id}/performance
GET /dashboard/channels/{id}/finance
GET /dashboard/series/{id}/finance
GET /dashboard/episodes/{id}/finance
```

### Workers

```python
@celery.task(name="publishing.upload")
def publish_upload(job_id: str):
    # Upload to platform
    
@celery.task(name="publishing.sync_metrics")
def sync_metrics(job_id: str):
    # Fetch metrics from platform
    
@celery.task(name="publishing.sync_revenue")
def sync_revenue(job_id: str):
    # Fetch revenue data
```

### Provider Interface

```python
class PlatformPublisherBase:
    def upload(self, asset_path: str, metadata: dict) -> dict:
        """return {external_post_id, url, published_time}"""
        
    def schedule(self, asset_path: str, metadata: dict, scheduled_time) -> dict:
        """return job info"""
        
    def fetch_metrics(self, external_post_id: str) -> dict:
        """return views, likes, comments, etc."""
        
    def fetch_revenue(self, external_post_id: str) -> dict:
        """return revenue info if available"""
```

---

## 🔗 Integration Points

### 1. Video ↔ Music Integration
- Video Module เรียก Music Module เพื่อ:
  - เลือกเพลงประกอบ
  - Auto sync beat
  - Audio ducking

### 2. Video/Music ↔ Dashboard Integration
- เมื่อสร้าง Video/Music เสร็จ → สร้าง Episode
- Episode → PublicationRecord → Publish ไป platform

### 3. Event Bus Integration
```
VIDEO_GENERATED → Dashboard รู้ว่ามี content ใหม่
AUDIO_STEMS_CREATED → Dashboard track stem assets
MUSIC_ANALYZED → Dashboard update metadata
CONTENT_PUBLISHED → Update performance tracking
```

---

## 📋 Implementation Priority

### Phase 1: Foundation (Week 1-2)
1. ✅ สร้าง database migrations
2. ✅ สร้าง API endpoints (mock responses)
3. ✅ สร้าง provider interfaces
4. ✅ สร้าง mock providers

### Phase 2: Core Features (Week 3-4)
1. ✅ Video: Basic generation (FFmpeg mock)
2. ✅ Music: Basic analysis (mock)
3. ✅ Dashboard: Basic structure

### Phase 3: Integration (Week 5-6)
1. ✅ เชื่อม Video ↔ Music
2. ✅ เชื่อม Video/Music ↔ Dashboard
3. ✅ Event bus integration

### Phase 4: Real Providers (Week 7-8)
1. ✅ Integrate real providers (Runway, Demucs, etc.)
2. ✅ Platform APIs (YouTube, TikTok, etc.)
3. ✅ Performance optimization

---

## 🎯 Current System Status

### ✅ What We Have
- Core Foundation structure (Jobs, Assets, Events concept)
- Frontend structure (React + TypeScript)
- Database foundation (profiles, user_roles)
- Basic routing and layouts

### ❌ What We Need
- Database tables สำหรับ 3 modules
- API endpoints
- Workers (Celery tasks)
- Provider adapters
- Frontend pages สำหรับ modules

---

## 📝 Next Steps

1. **Create Database Migrations**
   - Video metadata (use Asset.metadata)
   - AudioAnalysis, StemGroup, TabRecord
   - PlatformAccount, ContentChannel, Series, Episode
   - PublicationRecord, PerformanceSnapshot, RevenueRecord

2. **Create API Endpoints**
   - Video API routes
   - Music/Audio API routes
   - Dashboard/Publishing API routes

3. **Create Workers**
   - Video workers
   - Music workers
   - Publishing workers

4. **Create Provider Adapters**
   - Mock providers first
   - Real providers later

5. **Create Frontend Pages**
   - Video Editor page
   - Music Lab page
   - Dashboard page

---

*เอกสารนี้สรุปการบูรณาการ 3 โมดูลหลักของ Media Creator System*

