# 🎬 Media Creator System - Complete Architecture
## สถาปัตยกรรมระบบ Media Creator แบบสมบูรณ์

---

## 📊 สรุปภาพรวมระบบ

Media Creator System เป็น **AI Content Factory Automation** ที่ประกอบด้วย **6 Major Modules**:

1. **Core Foundation** - สมองกลางและระบบพื้นฐาน
2. **Input Brain** - จุดเริ่มต้นรับไอเดีย
3. **Image Module** - AI Photoshop + Canva
4. **Video Module** - AI Capcut + Runway
5. **Music & Audio Module** - AI Music Lab
6. **Dashboard & Publishing** - Control Center + Auto Posting

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    JARVIS (AI Orchestrator)                  │
│         Workflow Brain + Cost Control + Analytics             │
└───────────────────────────┬─────────────────────────────────┘
                             │
┌───────────────────────────┴─────────────────────────────────┐
│              DASHBOARD & PUBLISHING MODULE                   │
│     Revenue | Performance | Auto Upload | Scheduling         │
└───────────────────────────┬─────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────┴────────┐  ┌────────┴────────┐  ┌───────┴────────┐
│  INPUT BRAIN   │  │   IMAGE MODULE  │  │ VIDEO MODULE  │
│  (Content Idea)│  │ (AI PS/Canva)   │  │ (AI Capcut)   │
└───────┬────────┘  └────────┬────────┘  └───────┬────────┘
        │                     │                    │
        └─────────────────────┼────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │  MUSIC & AUDIO   │
                    │  (AI Music Lab)   │
                    └─────────┬─────────┘
                              │
                    ┌─────────┴─────────┐
                    │  CORE FOUNDATION │
                    │  (Base System)    │
                    └──────────────────┘
```

---

## 🟦 MODULE 1: CORE FOUNDATION

### หน้าที่หลัก
1. **AI Orchestrator** - ควบคุม workflow ระหว่างโมดูล
2. **Task Queue Manager** - จัดคิวงานหนัก (render, upscale, stem separation)
3. **Event Bus** - ส่ง event ระหว่างโมดูล
4. **Unified Storage** - เก็บไฟล์ทั้งหมด (ภาพ/วิดีโอ/เสียง)
5. **Plugin Architecture** - รองรับการเพิ่มโมดูลใหม่

### Tech Stack
- **Backend**: FastAPI (Python)
- **DB**: PostgreSQL (Supabase)
- **Queue**: Redis + Celery
- **Storage**: Unified Asset Registry

### Data Model
```sql
-- Core Entities
- Project (id, name, owner_id, metadata)
- Asset (id, project_id, type, path, metadata)
- Job (id, project_id, module_id, status, input_payload, output_payload)
- WorkflowRun (id, project_id, steps, status)
- Module (id, name, category, capabilities, cost_profile)
- CostRecord (id, job_id, provider, total_cost)
```

### API Endpoints
```
POST /projects
GET /projects/{id}
POST /jobs
GET /jobs/{id}
POST /workflows/run
GET /workflows/{id}
POST /modules/register
GET /modules
```

### Workers
```python
@celery.task(name="jobs.run_image_task")
@celery.task(name="jobs.run_video_task")
@celery.task(name="jobs.run_audio_task")
@celery.task(name="jobs.run_generic_task")
```

### Event Types
```
JOB_CREATED
JOB_COMPLETED
JOB_FAILED
ASSET_CREATED
WORKFLOW_STARTED
WORKFLOW_COMPLETED
```

---

## 🟢 MODULE 2: INPUT BRAIN (Content Idea Generator)

### หน้าที่หลัก
1. **Smart Prompt Intake** - รับ prompt แบบหลายรูปแบบ
2. **AI Idea Previews** - สร้างตัวอย่างคร่าว ๆ
3. **Trend-based Recommendation** - แนะนำไอเดียจาก Dashboard
4. **Project Setup** - สร้างโปรเจกต์อัตโนมัติ

### Data Model
```sql
-- ContentIdea
CREATE TABLE content_ideas (
    id UUID PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    type TEXT,  -- "image" | "video" | "music" | "mixed"
    prompt TEXT,
    options JSONB,
    ai_suggestions JSONB,
    selected_version INTEGER,
    status TEXT,  -- "draft" | "selected" | "converted_to_workflow"
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- IdeaVersion
CREATE TABLE idea_versions (
    id UUID PRIMARY KEY,
    idea_id UUID REFERENCES content_ideas(id),
    version_index INTEGER,
    preview_asset_id UUID REFERENCES assets(id),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- WorkflowDraft
CREATE TABLE workflow_drafts (
    id UUID PRIMARY KEY,
    idea_id UUID REFERENCES content_ideas(id),
    steps JSONB,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints
```
POST /input-brain/ideas
POST /input-brain/ideas/{idea_id}/select-version
POST /input-brain/ideas/{idea_id}/generate-workflow-draft
POST /input-brain/workflow-draft/{draft_id}/start
```

### Workflow
```
User Input → ContentIdea → AI Suggestions → 
→ Select Version → Workflow Draft → Start → Core Foundation
```

---

## 🟥 MODULE 3: IMAGE MODULE (AI Photoshop + Canva)

### หน้าที่หลัก
1. **AI Create Image** - จาก prompt/reference/template
2. **AI Edit** - ลบ/ใส่วัตถุ, เปลี่ยนฉาก, รีทัช, face swap
3. **Batch Processing** - 1 prompt → 20 รูป
4. **Template Design Engine** - Auto layout, font pairing, color scheme
5. **Character Lock** - ตัวละครคงที่หลายภาพ
6. **Export Engine** - PNG/JPG/WebP/SVG/PDF, หลายสัดส่วน

### Features เพิ่มเติม (ตามที่ขอ)
- ✅ สมุดวาดระบายสี (Coloring Book)
- ✅ Pattern (Seamless patterns)
- ✅ Origami templates
- ✅ Card game designs
- ✅ ไพ่ (Playing cards)
- ✅ Board game designs
- ✅ Emoji & Sticker (LINE style)
- ✅ คำคม 90s (พร้อมรูปประกอบ)
- ✅ Caption (พร้อมรูปประกอบ)
- ✅ TIFF format (สำหรับ LINE/Facebook ผู้สูงอายุ)

### Data Model
```sql
-- ImageJobInput (stored in Job.input_payload)
{
  "mode": "generate" | "edit" | "template" | "batch",
  "prompt": "...",
  "style": "cute",
  "reference_image_id": "uuid | null",
  "mask_image_id": "uuid | null",
  "width": 1024,
  "height": 1024,
  "provider": "flux",
  "batch_count": 4,
  "template_type": "coloring_book" | "pattern" | "origami" | "card_game" | "playing_cards" | "board_game" | "emoji" | "sticker" | "quote_90s" | "caption"
}

-- TemplateLayout
CREATE TABLE template_layouts (
    id UUID PRIMARY KEY,
    name TEXT,
    category TEXT,  -- "poster" | "story" | "infographic" | "coloring_book" | "pattern" | ...
    structure_json JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints
```
POST /image/generate
POST /image/edit
POST /image/template/apply
POST /image/batch
POST /image/upscale
GET /image/{asset_id}/details
```

### Workers
```python
@celery.task(name="image.generate")
@celery.task(name="image.edit")
@celery.task(name="image.template")
```

### Provider Interface
```python
class ImageProviderBase:
    def generate(self, prompt, width, height, **kw) -> List[ImageResult]:
        raise NotImplementedError
    
    def edit(self, image_path, mask_path, prompt, **kw):
        raise NotImplementedError
    
    def upscale(self, image_path, scale):
        raise NotImplementedError
```

---

## 🟧 MODULE 4: VIDEO MODULE (AI Capcut + Runway)

### หน้าที่หลัก
1. **Generate Video** - จาก prompt (Runway/Pika/Luma)
2. **AI Auto Editing** - ตัดช่วงเงียบ, auto-transition, auto-effects
3. **Multi Format Export** - 16:9, 9:16, 4:5, 1:1
4. **Subtitle Engine** - auto subtitle, translation, TikTok style
5. **Timeline Editor** - drag & drop, preview real-time
6. **Scene-based Generation** - ทำ MV, short version

### Data Model
```sql
-- VideoJobInput (stored in Job.input_payload)
{
  "mode": "generate" | "edit" | "multi_export",
  "provider": "runway",
  "prompt": "...",
  "duration_seconds": 15,
  "aspect_ratio": "9:16",
  "resolution": "1080x1920",
  "style": "cinematic",
  "source_assets": [],
  "operations": [
    {"type": "auto_cut_silence"},
    {"type": "auto_reframe", "target_aspect_ratio": "9:16"},
    {"type": "add_subtitle", "subtitle_mode": "auto"}
  ]
}

-- VideoMetadata (stored in Asset.metadata)
{
  "duration": 14.8,
  "width": 1080,
  "height": 1920,
  "fps": 30,
  "has_audio": true,
  "provider": "runway",
  "aspect_ratio": "9:16"
}
```

### API Endpoints
```
POST /video/generate
POST /video/edit
POST /video/multi-export
POST /video/subtitle
GET /video/{asset_id}/details
```

### Workers
```python
@celery.task(name="video.generate")
@celery.task(name="video.edit")
@celery.task(name="video.subtitle")
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

## 🟪 MODULE 5: MUSIC & AUDIO INTELLIGENCE

### หน้าที่หลัก
1. **Stem Separation** - แยก vocal, drums, bass, other
2. **Music Analysis** - BPM, Key, Chord, Structure
3. **Tab Generator** - Guitar, Bass, Ukulele tabs
4. **AI Music Generation** - สร้างเพลงจาก prompt
5. **Audio Remaster** - Noise reduction, EQ, Normalize
6. **Podcast Tools** - Cut/join/trim, clean, normalize

### Data Model
```sql
-- AudioAnalysis
CREATE TABLE audio_analysis (
    id UUID PRIMARY KEY,
    asset_id UUID REFERENCES assets(id),
    bpm FLOAT,
    key TEXT,  -- "C:maj", "A:min"
    time_signature TEXT,  -- "4/4", "6/8"
    sections JSONB,
    chord_progression JSONB,
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
```
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
@celery.task(name="music.analyze")
@celery.task(name="music.tab")
@celery.task(name="music.generate")
@celery.task(name="audio.remaster")
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

## 🟨 MODULE 6: DASHBOARD & PUBLISHING

### หน้าที่หลัก
1. **Content Management** - Channel/Account/Series/Episode
2. **Publishing Engine** - Upload หลาย platform, Schedule
3. **Business Dashboard** - Revenue, Cost, Profit, ROI
4. **AI Advisor Interface** - JARVIS recommendations

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
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ContentChannel
CREATE TABLE content_channels (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id),
    name TEXT,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Series
CREATE TABLE series (
    id UUID PRIMARY KEY,
    content_channel_id UUID REFERENCES content_channels(id),
    name TEXT,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
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
    created_at TIMESTAMPTZ DEFAULT NOW()
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
    created_at TIMESTAMPTZ DEFAULT NOW()
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

-- RevenueRecord
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
```
# Channel & Structure
POST /dashboard/channels
GET /dashboard/channels
POST /dashboard/channels/{channel_id}/series
POST /dashboard/episodes
GET /dashboard/episodes/{id}

# Publishing
POST /publishing/plan
GET /publishing/episode/{episode_id}
GET /publishing/publication/{id}

# Performance & Analytics
GET /dashboard/overview?channel_id=...&range=last_30d
GET /dashboard/episodes/{id}/performance
GET /dashboard/channels/{id}/finance
GET /dashboard/series/{id}/finance
```

### Workers
```python
@celery.task(name="publishing.upload")
@celery.task(name="publishing.sync_metrics")
@celery.task(name="publishing.sync_revenue")
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

## 🚀 Build Order (Perfect Sequence)

### Phase 1: Core Foundation (Week 1-2)
**สำคัญที่สุด - ต้องทำก่อนทุกอย่าง**

- [ ] สร้างโครงสร้างโปรเจกต์ (FastAPI + PostgreSQL + Redis + Celery)
- [ ] สร้าง Data Models (Project, Asset, Job, WorkflowRun, Module, CostRecord)
- [ ] สร้าง API Endpoints (/projects, /assets, /jobs, /workflows, /modules)
- [ ] สร้าง Event Bus (Redis pub/sub)
- [ ] สร้าง Plugin Architecture (Module Registry)
- [ ] สร้าง Workers (mock workers ก่อน)
- [ ] สร้าง Unified Storage Layer

### Phase 2: Input Brain (Week 3)
**จุดเริ่มต้นของผู้ใช้**

- [ ] สร้าง Data Models (ContentIdea, IdeaVersion, WorkflowDraft)
- [ ] สร้าง API Endpoints (/input-brain/ideas, /select-version, /generate-workflow-draft)
- [ ] สร้าง AI Suggestion Engine (mock ก่อน)
- [ ] สร้าง Frontend UI (Prompt input, Preview, Version selection)

### Phase 3: Image Module (Week 4-5)
**พื้นฐานของทุกอย่าง**

- [ ] สร้าง Data Models (TemplateLayout)
- [ ] สร้าง API Endpoints (/image/generate, /edit, /template, /batch, /upscale)
- [ ] สร้าง Provider Interface (ImageProviderBase)
- [ ] สร้าง Mock Provider (image.mock)
- [ ] สร้าง Workers (image.generate, image.edit, image.template)
- [ ] สร้าง Frontend UI (Canvas, Tools, Preview)
- [ ] เพิ่ม Features: Coloring Book, Pattern, Origami, Card Game, etc.

### Phase 4: Video Module (Week 6-7)
**ต่อยอดจาก Image**

- [ ] สร้าง API Endpoints (/video/generate, /edit, /multi-export, /subtitle)
- [ ] สร้าง Provider Interface (VideoProviderBase)
- [ ] สร้าง Mock Provider (video.mock)
- [ ] สร้าง Workers (video.generate, video.edit, video.subtitle)
- [ ] สร้าง Frontend UI (Timeline, Preview, Tools)

### Phase 5: Music & Audio Module (Week 8-9)
**เพิ่มเสียงและดนตรี**

- [ ] สร้าง Data Models (AudioAnalysis, StemGroup, TabRecord)
- [ ] สร้าง API Endpoints (/audio/stems, /music/analyze, /music/tab, /music/generate)
- [ ] สร้าง Provider Interface (AudioProviderBase)
- [ ] สร้าง Mock Provider (audio.mock)
- [ ] สร้าง Workers (audio.stems, music.analyze, music.tab, music.generate)
- [ ] สร้าง Frontend UI (Waveform, Stems, Tab viewer)

### Phase 6: Dashboard & Publishing (Week 10-11)
**หัวใจธุรกิจ**

- [ ] สร้าง Data Models (PlatformAccount, ContentChannel, Series, Episode, PublicationRecord, PerformanceSnapshot, RevenueRecord)
- [ ] สร้าง API Endpoints (/dashboard/*, /publishing/*)
- [ ] สร้าง Provider Interface (PlatformPublisherBase)
- [ ] สร้าง Mock Provider (publishing.mock)
- [ ] สร้าง Workers (publishing.upload, publishing.sync_metrics)
- [ ] สร้าง Frontend UI (Dashboard, Analytics, Publishing Queue)

### Phase 7: Integration & Testing (Week 12)
**เชื่อมทุกโมดูลเข้าด้วยกัน**

- [ ] เชื่อม Input Brain → Image/Video/Music
- [ ] เชื่อม Image/Video/Music → Dashboard
- [ ] เชื่อม Dashboard → Publishing
- [ ] ทดสอบ Workflow ทั้งหมด
- [ ] Optimize Performance

---

## 🔗 Integration Points

### 1. Input Brain → Modules
```
Input Brain → Generate Workflow Draft → 
→ Core Foundation → Create Jobs → 
→ Image/Video/Music Workers
```

### 2. Modules → Dashboard
```
Image/Video/Music → Create Asset → 
→ Create Episode → 
→ Dashboard Track
```

### 3. Dashboard → Publishing
```
Episode Ready → Create Publication Record → 
→ Publishing Worker → Upload to Platform → 
→ Sync Metrics
```

### 4. Event Flow
```
JOB_COMPLETED → ASSET_CREATED → 
→ EPISODE_READY → PUBLICATION_SCHEDULED → 
→ PUBLICATION_PUBLISHED → METRICS_UPDATED
```

---

## 📋 Current System Status

### ✅ What We Have
- Frontend structure (React + TypeScript)
- Database foundation (profiles, user_roles)
- Basic routing and layouts
- Authentication system (Supabase)
- UI components (shadcn/ui)

### ❌ What We Need
- **Backend API** (FastAPI)
- **Database tables** สำหรับ Media Creator
- **Workers** (Celery tasks)
- **Provider adapters**
- **Event Bus**
- **Unified Storage**
- **Module Registry**

---

## 🎯 Next Steps (Immediate Actions)

### 1. Setup Backend Infrastructure
```bash
# Create backend directory structure
mkdir -p backend/app/{core,models,schemas,routers,services,workers,utils}
mkdir -p backend/tests
```

### 2. Create Database Migrations
- Core Foundation tables
- Input Brain tables
- Image Module tables
- Video Module tables
- Music Module tables
- Dashboard tables

### 3. Create API Endpoints
- Start with Core Foundation APIs
- Then add module-specific APIs

### 4. Create Mock Providers
- image.mock
- video.mock
- audio.mock
- publishing.mock

### 5. Create Frontend Pages
- Input Brain page
- Image Editor page
- Video Editor page
- Music Lab page
- Dashboard page

---

## 📊 Summary

### System Architecture
- **6 Major Modules** working together
- **Plugin-based** architecture for extensibility
- **Event-driven** communication
- **Unified storage** for all assets
- **Workflow automation** from idea to publishing

### Technology Stack
- **Frontend**: React + TypeScript + Vite
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL (Supabase)
- **Queue**: Redis + Celery
- **Storage**: Unified Asset Registry

### Development Timeline
- **12 weeks** for complete system
- **Phased approach** - build foundation first
- **Mock providers** initially, real providers later
- **Incremental integration** - test as we build

---

*เอกสารนี้สรุปสถาปัตยกรรม Media Creator System แบบสมบูรณ์*

