# Phase 12: External Application Integration System

## 🎯 เป้าหมาย

สร้างระบบเชื่อมต่อ Standalone Applications เข้ากับ Master V2:
- Standalone apps (Mobile, Desktop, Web) เชื่อมต่อผ่าน API
- บางตัวเก็บเงิน บางตัวฟรี (เชื่อม Phase 11)
- ใช้ JSON + REST API
- Admin จัดการ external apps ได้

---

## 📋 Features

### 1. External Application Management

#### Application Registration
- Application name
- Application type (Mobile, Desktop, Web, API)
- Application description
- Application URL/Identifier
- Status (Active, Suspended, Pending)

#### API Key Management
- Generate API keys
- API key permissions (scopes)
- API key expiration
- API key rotation
- Rate limiting per API key

### 2. Authentication & Authorization

#### API Authentication
- API Key authentication
- OAuth 2.0 (optional)
- JWT tokens
- Scope-based permissions

#### User Linking
- Link external app users to Master V2 users
- Anonymous users support
- User identification methods

### 3. Payment & Credit Integration

#### Payment Methods
- Direct payment (ผ่าน Master V2)
- Credit-based payment
- Subscription-based access
- Free tier access

#### Pricing Models
- Per-request pricing
- Per-feature pricing
- Subscription pricing
- Credit-based pricing
- Free tier limits

### 4. Usage Tracking

#### Usage Metrics
- API calls per app
- Feature usage per app
- User activity per app
- Cost per app
- Revenue per app

### 5. Data Exchange (JSON)

#### Request/Response Format
- Standard JSON format
- Error handling
- Rate limiting responses
- Usage quota responses

---

## 🏗️ Architecture

### Database Schema

```sql
-- External Applications
CREATE TABLE external_applications (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    app_type VARCHAR(50), -- "mobile", "desktop", "web", "api"
    app_url VARCHAR(500),
    app_identifier VARCHAR(255) UNIQUE, -- Bundle ID, Package Name, etc.
    status VARCHAR(50) DEFAULT "pending", -- "active", "suspended", "pending"
    pricing_model VARCHAR(50), -- "free", "paid", "subscription", "credit"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- API Keys
CREATE TABLE api_keys (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) UNIQUE NOT NULL, -- Hashed API key
    key_prefix VARCHAR(20) NOT NULL, -- First 8 chars for display
    name VARCHAR(255), -- Key name/description
    scopes TEXT[], -- ["read:content", "write:content", "payment:process"]
    rate_limit INTEGER DEFAULT 1000, -- Requests per hour
    expires_at TIMESTAMPTZ,
    last_used_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT "active", -- "active", "revoked", "expired"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Users
CREATE TABLE external_app_users (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id),
    external_user_id VARCHAR(255), -- User ID in external app
    master_user_id UUID REFERENCES auth.users(id), -- Linked Master V2 user (optional)
    user_data JSONB, -- User info from external app
    status VARCHAR(50) DEFAULT "active",
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(app_id, external_user_id)
);

-- External App Usage
CREATE TABLE external_app_usage (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id),
    api_key_id UUID REFERENCES api_keys(id),
    user_id UUID REFERENCES external_app_users(id),
    endpoint VARCHAR(255),
    method VARCHAR(10), -- "GET", "POST", etc.
    request_data JSONB,
    response_status INTEGER,
    response_data JSONB,
    cost DECIMAL(10,4), -- Cost for this request
    credits_used INTEGER DEFAULT 0,
    duration_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Pricing
CREATE TABLE external_app_pricing (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id),
    feature_name VARCHAR(255), -- "image_generation", "video_processing", etc.
    pricing_type VARCHAR(50), -- "per_request", "subscription", "credit", "free"
    price_per_request DECIMAL(10,4),
    credit_cost INTEGER,
    free_tier_limit INTEGER, -- Free requests per day/month
    subscription_price DECIMAL(10,2),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Subscriptions
CREATE TABLE external_app_subscriptions (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id),
    user_id UUID REFERENCES external_app_users(id),
    plan_name VARCHAR(255),
    price DECIMAL(10,2),
    billing_cycle VARCHAR(20), -- "monthly", "yearly"
    status VARCHAR(50) DEFAULT "active",
    start_date DATE,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- External App Payments
CREATE TABLE external_app_payments (
    id UUID PRIMARY KEY,
    app_id UUID REFERENCES external_applications(id),
    user_id UUID REFERENCES external_app_users(id),
    amount DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT "THB",
    payment_type VARCHAR(50), -- "credit_purchase", "subscription", "one_time"
    status VARCHAR(50) DEFAULT "pending",
    provider_transaction_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints

#### External App Management (Admin)
```
GET    /api/external-apps                    # List external apps
POST   /api/external-apps                    # Register new app
GET    /api/external-apps/:id                # Get app details
PUT    /api/external-apps/:id                # Update app
DELETE /api/external-apps/:id                # Delete app

GET    /api/external-apps/:id/api-keys       # List API keys
POST   /api/external-apps/:id/api-keys       # Generate API key
PUT    /api/external-apps/:id/api-keys/:key_id # Update API key
DELETE /api/external-apps/:id/api-keys/:key_id # Revoke API key

GET    /api/external-apps/:id/usage          # App usage statistics
GET    /api/external-apps/:id/revenue        # App revenue
GET    /api/external-apps/:id/users          # App users
```

#### External App API (For Standalone Apps)
```
# Authentication
POST   /api/v1/auth/register                 # Register external user
POST   /api/v1/auth/login                    # Login external user
GET    /api/v1/auth/me                       # Get current user

# Content Access
GET    /api/v1/content                       # List content
GET    /api/v1/content/:id                   # Get content
POST   /api/v1/content/:id/view              # Record view
POST   /api/v1/content/:id/download         # Request download

# Media Generation (if applicable)
POST   /api/v1/media/generate/image          # Generate image
POST   /api/v1/media/generate/video         # Generate video
POST   /api/v1/media/generate/audio          # Generate audio

# Payment & Credits
GET    /api/v1/credits/balance               # Get credit balance
POST   /api/v1/credits/purchase              # Purchase credits
GET    /api/v1/payments/status/:id           # Check payment status

# Subscriptions
GET    /api/v1/subscriptions                 # Get user subscriptions
POST   /api/v1/subscriptions                 # Subscribe to plan
DELETE /api/v1/subscriptions/:id             # Cancel subscription
```

---

## 🔐 Authentication Flow

### API Key Authentication
```json
// Request Headers
{
  "Authorization": "Bearer YOUR_API_KEY",
  "X-App-Id": "your-app-identifier",
  "Content-Type": "application/json"
}
```

### Response Format
```json
// Success Response
{
  "success": true,
  "data": { ... },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2024-12-01T10:00:00Z"
  }
}

// Error Response
{
  "success": false,
  "error": {
    "code": "INVALID_API_KEY",
    "message": "API key is invalid or expired",
    "details": { ... }
  },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2024-12-01T10:00:00Z"
  }
}
```

---

## 💰 Pricing Integration Examples

### Example 1: Free Tier
```json
// Request
POST /api/v1/content/123/view
Headers: { "Authorization": "Bearer API_KEY" }

// Response
{
  "success": true,
  "data": {
    "content": { ... },
    "usage": {
      "free_tier_used": 5,
      "free_tier_limit": 10,
      "remaining_free": 5
    }
  }
}
```

### Example 2: Credit-Based
```json
// Request
POST /api/v1/media/generate/image
Body: {
  "prompt": "A beautiful sunset",
  "style": "realistic"
}

// Response
{
  "success": true,
  "data": {
    "image_url": "https://...",
    "credits_used": 10,
    "credits_remaining": 90
  }
}
```

### Example 3: Subscription
```json
// Request
GET /api/v1/content

// Response
{
  "success": true,
  "data": {
    "content": [ ... ],
    "subscription": {
      "plan": "premium",
      "status": "active",
      "expires_at": "2024-12-31"
    }
  }
}
```

---

## 🎨 UI Components

### Admin: External Apps Management
- External apps list table
- Register new app form
- API key management
- Usage statistics dashboard
- Revenue tracking
- User management per app

### Admin: API Documentation
- API endpoint documentation
- Authentication guide
- Request/Response examples
- SDK/Code examples

---

## 📱 Standalone App Integration Example

### Mobile App (React Native / Flutter)
```javascript
// API Client
class MasterV2API {
  constructor(apiKey, appId) {
    this.apiKey = apiKey;
    this.appId = appId;
    this.baseURL = 'https://api.masterv2.com/v1';
  }

  async request(endpoint, method = 'GET', body = null) {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      method,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'X-App-Id': this.appId,
        'Content-Type': 'application/json'
      },
      body: body ? JSON.stringify(body) : null
    });

    return await response.json();
  }

  async getContent(contentId) {
    return this.request(`/content/${contentId}`);
  }

  async generateImage(prompt) {
    return this.request('/media/generate/image', 'POST', { prompt });
  }

  async purchaseCredits(amount) {
    return this.request('/credits/purchase', 'POST', { amount });
  }
}

// Usage
const api = new MasterV2API('your-api-key', 'your-app-id');
const content = await api.getContent('123');
```

### Desktop App (Electron / Python)
```python
import requests
import json

class MasterV2API:
    def __init__(self, api_key, app_id):
        self.api_key = api_key
        self.app_id = app_id
        self.base_url = 'https://api.masterv2.com/v1'
        self.headers = {
            'Authorization': f'Bearer {api_key}',
            'X-App-Id': app_id,
            'Content-Type': 'application/json'
        }
    
    def request(self, endpoint, method='GET', data=None):
        url = f'{self.base_url}{endpoint}'
        response = requests.request(
            method=method,
            url=url,
            headers=self.headers,
            json=data
        )
        return response.json()
    
    def get_content(self, content_id):
        return self.request(f'/content/{content_id}')
    
    def generate_image(self, prompt):
        return self.request('/media/generate/image', 'POST', {'prompt': prompt})

# Usage
api = MasterV2API('your-api-key', 'your-app-id')
content = api.get_content('123')
```

---

## 🔄 Integration Flow

### 1. App Registration
1. Admin สร้าง External App ใน Master V2
2. ระบบสร้าง API Key
3. Admin แจ้ง API Key ให้ Developer

### 2. App Integration
1. Developer ใช้ API Key เชื่อมต่อ
2. App ส่ง requests ผ่าน API
3. Master V2 ตรวจสอบ API Key และ permissions
4. Master V2 ตรวจสอบ pricing (free/paid)
5. Master V2 ติดตาม usage และ cost

### 3. Payment Flow
1. User ใน standalone app ต้องการใช้ paid feature
2. App ส่ง request ไป Master V2
3. Master V2 ตรวจสอบ credits/subscription
4. ถ้าไม่มี → redirect ไป payment
5. หลังจ่ายเงิน → ใช้ feature ได้

---

## ✅ Success Criteria

- [ ] Admin สามารถ register external apps ได้
- [ ] Admin สามารถจัดการ API keys ได้
- [ ] Standalone apps เชื่อมต่อผ่าน API ได้
- [ ] Payment/Credit integration ทำงานได้
- [ ] Usage tracking ทำงานได้
- [ ] Admin ดู usage และ revenue ได้

---

## 📝 JSON Schema Examples

### Content Response
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Content Title",
    "type": "video",
    "url": "https://...",
    "thumbnail": "https://...",
    "pricing": {
      "type": "free",
      "credits_required": 0
    }
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_CREDITS",
    "message": "Not enough credits",
    "required": 10,
    "available": 5
  }
}
```

---

**Status:** 📋 Ready for Implementation

