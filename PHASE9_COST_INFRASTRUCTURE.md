# Phase 9: Cost & Infrastructure Management System

## 🎯 เป้าหมาย

สร้างระบบจัดการค่าใช้จ่ายและ Infrastructure สำหรับ Admin เพื่อ:
- ดูค่าใช้จ่ายทั้งหมด (Domain, AI Providers, Third-party)
- ติดตาม Package/Provider ที่ใช้
- วิเคราะห์สุขภาพเว็บไซต์
- ให้ Jarvis วิเคราะห์และแนะนำ

---

## 📋 Features

### 1. Infrastructure Tracking

#### Domain Management
- Domain name
- Registrar
- Renewal date
- Cost per year/month
- Status (Active, Expiring, Expired)
- Auto-renewal setting

#### Hosting & Server
- Server provider (AWS, Google Cloud, etc.)
- Server type/specs
- Monthly cost
- Usage statistics
- Status

#### CDN & Storage
- CDN provider (Cloudflare, etc.)
- Storage provider (S3, etc.)
- Monthly cost
- Bandwidth usage
- Storage usage

### 2. AI Provider Management

#### Provider Tracking
- Provider name (OpenAI, Anthropic, Stability AI, etc.)
- Service type (Image, Video, Audio, Text)
- Pricing model (Pay-per-use, Subscription, Free tier)
- Current usage
- Monthly cost
- Free tier limits
- Billing cycle
- API key status

#### Cost Analysis
- Cost per request
- Monthly total cost
- Cost by service type
- Cost trends
- Projected costs

### 3. Third-Party Integrations

#### Integration Tracking
- Service name (Supabase, Stripe, etc.)
- Integration type (Auth, Payment, Database, etc.)
- Pricing model
- Monthly cost
- Usage limits
- Status

### 4. Package & Subscription Management

#### Package Tracking
- Package name
- Provider
- Features included
- Monthly/Yearly cost
- Renewal date
- Status

### 5. Cost Dashboard

#### Overview
- Total monthly cost
- Cost breakdown by category
- Cost trends (chart)
- Upcoming renewals
- Alerts (expiring soon, over budget)

#### Cost Categories
- Infrastructure (Domain, Hosting, CDN)
- AI Services
- Third-party Services
- Packages/Subscriptions
- Other

### 6. Jarvis Analysis

#### Health Analysis
- Overall system health score
- Cost efficiency analysis
- Provider recommendations
- Optimization suggestions
- Risk alerts

---

## 🏗️ Architecture

### Database Schema

```sql
-- Infrastructure Items
CREATE TABLE infrastructure_items (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- "domain", "hosting", "cdn", "storage"
    provider VARCHAR(255),
    cost_per_period DECIMAL(10,2),
    period VARCHAR(20), -- "monthly", "yearly"
    renewal_date DATE,
    status VARCHAR(50), -- "active", "expiring", "expired"
    auto_renewal BOOLEAN DEFAULT false,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Provider Costs
CREATE TABLE ai_provider_costs (
    id UUID PRIMARY KEY,
    provider_name VARCHAR(255) NOT NULL,
    service_type VARCHAR(50), -- "image", "video", "audio", "text"
    pricing_model VARCHAR(50), -- "pay_per_use", "subscription", "free"
    cost_per_request DECIMAL(10,4),
    monthly_cost DECIMAL(10,2),
    free_tier_limit INTEGER,
    current_usage INTEGER DEFAULT 0,
    billing_cycle VARCHAR(20), -- "monthly", "yearly"
    api_key_status VARCHAR(50), -- "active", "expired", "invalid"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Third-Party Integrations
CREATE TABLE third_party_integrations (
    id UUID PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    integration_type VARCHAR(50), -- "auth", "payment", "database", etc.
    provider VARCHAR(255),
    pricing_model VARCHAR(50),
    monthly_cost DECIMAL(10,2),
    usage_limit INTEGER,
    current_usage INTEGER DEFAULT 0,
    status VARCHAR(50), -- "active", "suspended", "expired"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cost Records (Historical)
CREATE TABLE cost_records (
    id UUID PRIMARY KEY,
    item_type VARCHAR(50), -- "infrastructure", "ai_provider", "third_party"
    item_id UUID,
    cost DECIMAL(10,2),
    period_start DATE,
    period_end DATE,
    usage_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints

```
GET    /api/cost/infrastructure          # List infrastructure items
POST   /api/cost/infrastructure          # Add infrastructure item
PUT    /api/cost/infrastructure/:id      # Update infrastructure item
DELETE /api/cost/infrastructure/:id     # Delete infrastructure item

GET    /api/cost/ai-providers            # List AI providers
POST   /api/cost/ai-providers            # Add AI provider
PUT    /api/cost/ai-providers/:id        # Update AI provider

GET    /api/cost/third-party             # List third-party integrations
POST   /api/cost/third-party             # Add integration
PUT    /api/cost/third-party/:id         # Update integration

GET    /api/cost/dashboard                # Cost dashboard overview
GET    /api/cost/analysis                # Jarvis cost analysis
GET    /api/cost/trends                  # Cost trends
GET    /api/cost/alerts                   # Cost alerts
```

---

## 🎨 UI Components

### Cost Dashboard Page
- Total cost card
- Cost breakdown chart
- Upcoming renewals list
- Alerts panel
- Provider status grid

### Infrastructure Management
- Infrastructure items table
- Add/Edit infrastructure form
- Renewal calendar

### AI Provider Management
- Provider cards with usage
- Cost per provider
- Free tier indicators
- API key status

### Jarvis Analysis Panel
- Health score
- Recommendations
- Optimization suggestions

---

## 📊 Data Model

### Cost Summary
```json
{
  "total_monthly_cost": 5000.00,
  "by_category": {
    "infrastructure": 2000.00,
    "ai_services": 2500.00,
    "third_party": 400.00,
    "packages": 100.00
  },
  "trends": [
    {"month": "2024-01", "cost": 4500.00},
    {"month": "2024-02", "cost": 4800.00},
    {"month": "2024-03", "cost": 5000.00}
  ],
  "upcoming_renewals": [
    {"item": "Domain", "date": "2024-12-15", "cost": 500.00}
  ]
}
```

---

## ✅ Success Criteria

- [ ] Admin สามารถดูค่าใช้จ่ายทั้งหมดได้
- [ ] Admin สามารถจัดการ Infrastructure items ได้
- [ ] Admin สามารถติดตาม AI Provider costs ได้
- [ ] Jarvis วิเคราะห์และแนะนำได้
- [ ] มี Alerts สำหรับ renewals และ over budget

