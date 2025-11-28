# Phase 11: Monetization & Payment System

## 🎯 เป้าหมาย

สร้างระบบเก็บเงินและ Monetization สำหรับ:
- จัดการ Free vs Paid content
- Digital downloads
- Payment processing
- Credit system
- UI สำหรับจัดการ (เหมือน app ธนาคาร)
- **External Application Integration** (เชื่อม standalone apps)

---

## 📋 Features

### 1. Content Monetization

#### Free vs Paid Content
- **Free Content** - เนื้อหาฟรี (เพื่อดึงดูดผู้ใช้)
- **Paid Content** - เนื้อหาเสียเงิน
- **Freemium** - ใช้ฟรีบางส่วน แล้วต้องจ่ายต่อ
- **Trial** - ทดลองใช้ฟรีแล้วจ่ายต่อ

#### Content Pricing
- One-time purchase
- Subscription (รายเดือน/รายปี)
- Pay-per-view
- Credit-based

### 2. Credit System

#### Credit Management
- Credit balance
- Credit purchase
- Credit usage tracking
- Credit expiration
- Credit packages

#### Credit Rules
- Free credits for new users
- Credits per action (view, download, etc.)
- Credit limits
- Credit tiers

### 3. Payment Processing

#### Payment Methods
- Credit/Debit Card
- Bank Transfer
- E-Wallet (PromptPay, TrueMoney, etc.)
- Cryptocurrency (optional)

#### Payment Providers
- Stripe
- PayPal
- Local payment gateways (Omise, 2C2P, etc.)

### 4. Digital Downloads

#### Download Management
- Download tracking
- Download limits (free vs paid)
- Download expiration
- DRM protection (optional)

### 5. Subscription Plans

#### Plan Types
- Free Plan
- Basic Plan
- Premium Plan
- Enterprise Plan

#### Plan Features
- Content access limits
- Feature access
- Download limits
- Support level

### 6. Revenue Management

#### Revenue Tracking
- Total revenue
- Revenue by source
- Revenue trends
- Payment status
- Refund management

### 7. Admin UI (Bank-like Interface)

#### Dashboard
- Revenue overview
- Transaction list
- Payment status
- Credit management
- Subscription management

#### Settings
- Payment provider configuration
- Pricing rules
- Credit rules
- Free tier limits
- Subscription plans

---

## 🏗️ Architecture

### Database Schema

```sql
-- Subscription Plans
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    features JSONB, -- {"content_access": "unlimited", "downloads": 100}
    credit_included INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT "active",
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Subscriptions
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    plan_id UUID REFERENCES subscription_plans(id),
    status VARCHAR(50), -- "active", "cancelled", "expired"
    start_date DATE,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Credits
CREATE TABLE user_credits (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id),
    balance DECIMAL(10,2) DEFAULT 0,
    total_earned DECIMAL(10,2) DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Credit Transactions
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    type VARCHAR(50), -- "earned", "purchased", "spent", "expired", "refunded"
    amount DECIMAL(10,2),
    description TEXT,
    related_item_id UUID, -- Content ID, Subscription ID, etc.
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payment Transactions
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    type VARCHAR(50), -- "subscription", "credit_purchase", "content_purchase", "download"
    amount DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT "THB",
    payment_method VARCHAR(50),
    payment_provider VARCHAR(100),
    provider_transaction_id VARCHAR(255),
    status VARCHAR(50), -- "pending", "completed", "failed", "refunded"
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Pricing
CREATE TABLE content_pricing (
    id UUID PRIMARY KEY,
    content_id UUID, -- Asset ID or Episode ID
    content_type VARCHAR(50),
    pricing_model VARCHAR(50), -- "free", "one_time", "subscription", "credit", "pay_per_view"
    price DECIMAL(10,2),
    credit_cost INTEGER,
    free_tier_limit INTEGER, -- Free views/downloads
    trial_days INTEGER,
    status VARCHAR(50) DEFAULT "active",
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Downloads
CREATE TABLE downloads (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    content_id UUID,
    download_type VARCHAR(50), -- "free", "paid", "subscription"
    payment_transaction_id UUID REFERENCES payment_transactions(id),
    download_url TEXT,
    expires_at TIMESTAMPTZ,
    download_count INTEGER DEFAULT 0,
    max_downloads INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT "active",
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### API Endpoints

```
# Subscription Plans
GET    /api/monetization/plans              # List plans
POST   /api/monetization/plans              # Create plan
PUT    /api/monetization/plans/:id          # Update plan

# User Subscriptions
GET    /api/monetization/subscriptions     # User subscriptions
POST   /api/monetization/subscriptions     # Subscribe
PUT    /api/monetization/subscriptions/:id  # Update subscription
DELETE /api/monetization/subscriptions/:id  # Cancel subscription

# Credits
GET    /api/monetization/credits            # User credit balance
POST   /api/monetization/credits/purchase   # Purchase credits
GET    /api/monetization/credits/transactions # Credit transactions

# Payments
POST   /api/monetization/payments           # Create payment
GET    /api/monetization/payments/:id       # Get payment status
POST   /api/monetization/payments/:id/refund # Refund payment

# Content Pricing
GET    /api/monetization/pricing/:content_id # Get content pricing
POST   /api/monetization/pricing            # Set content pricing
PUT    /api/monetization/pricing/:id         # Update pricing

# Downloads
POST   /api/monetization/downloads          # Request download
GET    /api/monetization/downloads/:id       # Get download link

# Revenue
GET    /api/monetization/revenue            # Revenue overview
GET    /api/monetization/revenue/transactions # Transaction list
```

---

## 🎨 UI Components

### Monetization Dashboard (Bank-like)
- Revenue overview cards
- Transaction list (like bank statement)
- Payment status indicators
- Credit management
- Subscription management

### Pricing Management
- Content pricing table
- Set pricing form
- Free tier configuration
- Credit cost configuration

### Payment Configuration
- Payment provider settings
- Payment method configuration
- Pricing rules
- Credit rules

### User Payment Interface
- Credit balance display
- Purchase credits
- Subscription management
- Payment history
- Download management

---

## 💡 Monetization Strategies

### 1. Freemium Model
- **Free Tier:**
  - ดูเนื้อหาฟรี 10 ครั้ง/เดือน
  - Download ฟรี 5 ครั้ง/เดือน
  - ใช้ Tools ฟรี (มี watermark)

- **Premium Tier:**
  - ดูเนื้อหาไม่จำกัด
  - Download ไม่จำกัด
  - ใช้ Tools ไม่มี watermark
  - Priority support

### 2. Credit System
- **Free Credits:**
  - 100 credits สำหรับ new users
  - 10 credits/วัน สำหรับ active users

- **Credit Costs:**
  - ดู video: 5 credits
  - Download: 20 credits
  - Generate image: 10 credits
  - Generate video: 50 credits

- **Credit Purchase:**
  - 100 credits = ฿50
  - 500 credits = ฿200 (20% off)
  - 1000 credits = ฿350 (30% off)

### 3. Subscription Plans
- **Free Plan:** ฟรี (จำกัด)
- **Basic Plan:** ฿299/เดือน
- **Premium Plan:** ฿599/เดือน
- **Enterprise Plan:** Custom pricing

### 4. Pay-per-View
- ดู premium content: ฿10/ครั้ง
- Download premium content: ฿50/ครั้ง

### 5. Digital Downloads
- Single purchase: ฿99-499
- Bundle purchase: ฿299-999
- Lifetime access: ฿1,999

---

## 🔧 Technical Implementation

### Payment Integration
- Stripe integration
- Local payment gateways
- Webhook handlers
- Payment verification

### Credit System Logic
- Credit calculation
- Credit validation
- Credit expiration
- Credit refund

### Download Management
- Secure download links
- Download tracking
- Download limits
- DRM (optional)

---

## ✅ Success Criteria

- [ ] Admin สามารถจัดการ Pricing ได้
- [ ] Admin สามารถดู Revenue ได้
- [ ] User สามารถซื้อ Credits/Subscription ได้
- [ ] Payment processing ทำงานได้
- [ ] Download system ทำงานได้
- [ ] UI ง่ายเหมือน app ธนาคาร

