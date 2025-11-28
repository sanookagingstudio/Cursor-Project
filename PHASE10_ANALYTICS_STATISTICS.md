# Phase 10: Analytics & Statistics System

## 🎯 เป้าหมาย

สร้างระบบสถิติการใช้งานและ Analytics สำหรับ:
- ติดตามผู้ใช้งาน (สมาชิก, ขาประจำ, ขาจร, ต่างประเทศ)
- วิเคราะห์การใช้งานตามเวลา
- จัดอันดับ Content ที่ได้รับความนิยม
- ให้ Jarvis วิเคราะห์และทำแผนกลยุทธ์

---

## 📋 Features

### 1. User Analytics

#### User Types
- **สมาชิก (Members)** - ผู้ที่สมัครสมาชิก
- **ขาประจำ (Regular Users)** - ผู้ใช้บ่อย (3+ ครั้ง/สัปดาห์)
- **ขาจร (Casual Users)** - ผู้ใช้ไม่บ่อย (<3 ครั้ง/สัปดาห์)
- **ต่างประเทศ (International)** - ผู้ใช้จากต่างประเทศ
- **Guest** - ผู้ใช้ที่ไม่สมัครสมาชิก

#### User Metrics
- Total users
- Active users (DAU, WAU, MAU)
- New users
- Returning users
- User retention rate
- User growth rate

### 2. Time-Based Analytics

#### Time Patterns
- Peak hours (ชั่วโมงที่ใช้งานมากที่สุด)
- Peak days (วันที่ใช้งานมากที่สุด)
- Peak months (เดือนที่ใช้งานมากที่สุด)
- Session duration
- Time spent per page

### 3. Content Analytics

#### Content Popularity
- Most viewed content
- Most liked content
- Most shared content
- Most downloaded content
- Content engagement rate
- Content completion rate

#### Content Categories
- Most popular categories
- Content by type (Image, Video, Audio, Article)
- Trending content

### 4. Feature Usage Analytics

#### Feature Tracking
- Media Center usage
- Image Editor usage
- Video Editor usage
- Music Lab usage
- Dashboard usage
- Feature adoption rate

### 5. Geographic Analytics

#### Location Data
- Users by country
- Users by region
- Top countries
- International vs Local users

### 6. Jarvis Analytics & Strategy

#### AI Analysis
- User behavior patterns
- Content performance insights
- Optimization recommendations
- Strategy suggestions
- Predictive analytics

#### Strategy Planning
- Content production plan
- Publishing schedule optimization
- Target audience analysis
- Growth opportunities

---

## 🏗️ Architecture

### Database Schema

```sql
-- User Sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    session_start TIMESTAMPTZ DEFAULT NOW(),
    session_end TIMESTAMPTZ,
    duration_seconds INTEGER,
    page_views INTEGER DEFAULT 0,
    country VARCHAR(100),
    city VARCHAR(100),
    device_type VARCHAR(50), -- "desktop", "mobile", "tablet"
    browser VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Page Views
CREATE TABLE page_views (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    session_id UUID REFERENCES user_sessions(id),
    page_path VARCHAR(500),
    page_title VARCHAR(255),
    referrer VARCHAR(500),
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Interactions
CREATE TABLE content_interactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    content_id UUID, -- Asset ID or Episode ID
    content_type VARCHAR(50), -- "image", "video", "audio", "article"
    interaction_type VARCHAR(50), -- "view", "like", "share", "download", "comment"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feature Usage
CREATE TABLE feature_usage (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    feature_name VARCHAR(100), -- "image_editor", "video_editor", etc.
    usage_count INTEGER DEFAULT 1,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Analytics Snapshots (Daily Aggregates)
CREATE TABLE analytics_snapshots (
    id UUID PRIMARY KEY,
    snapshot_date DATE,
    total_users INTEGER,
    active_users INTEGER,
    new_users INTEGER,
    page_views INTEGER,
    content_views INTEGER,
    feature_usage JSONB,
    geographic_data JSONB,
    time_patterns JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(snapshot_date)
);
```

### API Endpoints

```
GET /api/analytics/users                    # User statistics
GET /api/analytics/users/active            # Active users (DAU, WAU, MAU)
GET /api/analytics/users/retention         # User retention
GET /api/analytics/users/geographic        # Geographic distribution

GET /api/analytics/content                 # Content statistics
GET /api/analytics/content/popular         # Popular content
GET /api/analytics/content/trending        # Trending content

GET /api/analytics/time                    # Time-based analytics
GET /api/analytics/time/peak-hours         # Peak hours
GET /api/analytics/time/peak-days          # Peak days

GET /api/analytics/features                # Feature usage
GET /api/analytics/features/adoption        # Feature adoption

GET /api/analytics/dashboard                # Analytics dashboard
GET /api/analytics/jarvis/analysis         # Jarvis analysis
GET /api/analytics/jarvis/strategy         # Jarvis strategy recommendations
```

---

## 🎨 UI Components

### Analytics Dashboard
- User statistics cards
- Time-based charts
- Content popularity charts
- Geographic map
- Feature usage charts

### User Analytics Page
- User types breakdown
- User growth chart
- Retention chart
- Geographic distribution

### Content Analytics Page
- Popular content table
- Content engagement metrics
- Trending content
- Content performance chart

### Jarvis Analytics Panel
- AI insights
- Strategy recommendations
- Predictive analytics
- Optimization suggestions

---

## 📊 Data Model

### User Analytics Summary
```json
{
  "total_users": 1000,
  "active_users": {
    "dau": 150,
    "wau": 400,
    "mau": 800
  },
  "user_types": {
    "members": 500,
    "regular": 300,
    "casual": 150,
    "international": 50
  },
  "retention_rate": 0.75,
  "growth_rate": 0.10
}
```

### Content Analytics Summary
```json
{
  "most_viewed": [
    {"content_id": "uuid", "title": "Video 1", "views": 1000}
  ],
  "most_liked": [...],
  "most_shared": [...],
  "trending": [...]
}
```

---

## ✅ Success Criteria

- [ ] Admin สามารถดูสถิติผู้ใช้งานได้
- [ ] Admin สามารถวิเคราะห์การใช้งานตามเวลาได้
- [ ] Admin สามารถดู Content ที่ได้รับความนิยมได้
- [ ] Jarvis วิเคราะห์และแนะนำกลยุทธ์ได้
- [ ] มี Predictive analytics

