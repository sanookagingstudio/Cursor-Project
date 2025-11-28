# External Application Integration Guide

## 📱 สำหรับ Developer ที่ต้องการเชื่อม Standalone App เข้ากับ Master V2

---

## 🎯 Overview

Master V2 รองรับการเชื่อมต่อจาก Standalone Applications (Mobile, Desktop, Web) ผ่าน REST API โดยใช้ JSON format

---

## 🔑 ขั้นตอนการเชื่อมต่อ

### 1. Register Application (Admin)

1. Admin เข้า `/admin/external-apps`
2. คลิก "Register New App"
3. กรอกข้อมูล:
   - App Name
   - App Type (Mobile, Desktop, Web, API)
   - App Identifier (Bundle ID, Package Name, etc.)
   - Description
4. ระบบจะสร้าง API Key ให้อัตโนมัติ
5. เก็บ API Key ไว้ใช้ใน app

### 2. Integration ใน Standalone App

#### 2.1 Setup API Client

```javascript
// JavaScript/TypeScript
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

    const data = await response.json();
    
    if (!data.success) {
      throw new Error(data.error.message);
    }
    
    return data;
  }
}
```

```python
# Python
import requests

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
        result = response.json()
        
        if not result.get('success'):
            raise Exception(result['error']['message'])
        
        return result
```

#### 2.2 Register External User

```javascript
// Register user from external app
const api = new MasterV2API('your-api-key', 'your-app-id');

async function registerUser(externalUserId, userData) {
  const response = await api.request('/auth/register', 'POST', {
    external_user_id: externalUserId,
    user_data: userData // { name, email, etc. }
  });
  
  return response.data;
}
```

#### 2.3 Access Content

```javascript
// Get content
async function getContent(contentId) {
  const response = await api.request(`/content/${contentId}`);
  return response.data;
}

// Record view (for analytics)
async function recordView(contentId) {
  const response = await api.request(`/content/${contentId}/view`, 'POST');
  return response.data;
}
```

#### 2.4 Handle Payment/Credits

```javascript
// Check credit balance
async function getCreditBalance() {
  const response = await api.request('/credits/balance');
  return response.data;
}

// Purchase credits
async function purchaseCredits(amount) {
  const response = await api.request('/credits/purchase', 'POST', {
    amount: amount // 100, 500, 1000
  });
  return response.data;
}

// Use paid feature
async function generateImage(prompt) {
  try {
    const response = await api.request('/media/generate/image', 'POST', {
      prompt: prompt
    });
    return response.data;
  } catch (error) {
    if (error.message.includes('INSUFFICIENT_CREDITS')) {
      // Redirect to purchase credits
      showPurchaseCreditsDialog();
    }
    throw error;
  }
}
```

---

## 📊 Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data here
  },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2024-12-01T10:00:00Z"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message",
    "details": {}
  },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2024-12-01T10:00:00Z"
  }
}
```

---

## 🔐 Authentication

### API Key Authentication
ทุก request ต้องมี headers:
```
Authorization: Bearer YOUR_API_KEY
X-App-Id: your-app-identifier
Content-Type: application/json
```

### Error Codes
- `INVALID_API_KEY` - API key ไม่ถูกต้องหรือหมดอายุ
- `RATE_LIMIT_EXCEEDED` - เกิน rate limit
- `INSUFFICIENT_CREDITS` - เครดิตไม่พอ
- `SUBSCRIPTION_REQUIRED` - ต้องสมัคร subscription
- `PERMISSION_DENIED` - ไม่มีสิทธิ์

---

## 💰 Pricing Models

### 1. Free Tier
- ใช้ฟรีได้ตาม limit ที่กำหนด
- Response จะบอก remaining free quota

### 2. Credit-Based
- ใช้ credits ต่อ request
- Response จะบอก credits used และ remaining

### 3. Subscription
- ต้องมี active subscription
- Response จะบอก subscription status

---

## 📝 Example: Complete Integration

```javascript
// Complete example
class MyApp {
  constructor() {
    this.api = new MasterV2API('your-api-key', 'your-app-id');
    this.userId = null;
  }

  async initialize(externalUserId) {
    // Register or get user
    try {
      const user = await this.api.request('/auth/register', 'POST', {
        external_user_id: externalUserId
      });
      this.userId = user.data.id;
    } catch (error) {
      // User might already exist
      const user = await this.api.request('/auth/login', 'POST', {
        external_user_id: externalUserId
      });
      this.userId = user.data.id;
    }
  }

  async showContent(contentId) {
    try {
      // Get content
      const content = await this.api.request(`/content/${contentId}`);
      
      // Check if free or paid
      if (content.data.pricing.type === 'free') {
        // Show content
        this.displayContent(content.data);
        
        // Record view
        await this.api.request(`/content/${contentId}/view`, 'POST');
      } else {
        // Check credits
        const balance = await this.api.request('/credits/balance');
        
        if (balance.data.balance >= content.data.pricing.credits_required) {
          // Show content
          this.displayContent(content.data);
          
          // Record view (credits will be deducted)
          await this.api.request(`/content/${contentId}/view`, 'POST');
        } else {
          // Show purchase credits dialog
          this.showPurchaseCreditsDialog();
        }
      }
    } catch (error) {
      console.error('Error:', error.message);
    }
  }

  async generateImage(prompt) {
    try {
      const result = await this.api.request('/media/generate/image', 'POST', {
        prompt: prompt
      });
      
      return result.data.image_url;
    } catch (error) {
      if (error.message.includes('INSUFFICIENT_CREDITS')) {
        this.showPurchaseCreditsDialog();
      }
      throw error;
    }
  }
}

// Usage
const app = new MyApp();
await app.initialize('user-123');
await app.showContent('content-456');
```

---

## ✅ Best Practices

1. **Store API Key Securely**
   - อย่า hardcode API key ใน code
   - ใช้ environment variables หรือ secure storage

2. **Handle Errors Gracefully**
   - Check error codes
   - Show user-friendly messages
   - Handle rate limiting

3. **Cache Responses**
   - Cache content data
   - Cache credit balance (with TTL)

4. **Track Usage**
   - Log API calls
   - Monitor error rates
   - Track user behavior

---

## 📚 API Documentation

ดู API documentation เพิ่มเติมที่:
- `/admin/external-apps/api-docs` (Admin only)
- หรือติดต่อ Admin เพื่อขอ API documentation

---

**Status:** 📋 Ready for Integration

