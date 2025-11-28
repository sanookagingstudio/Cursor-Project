# Phase 13: Discount & Promotion System

## 🎯 เป้าหมาย

สร้างระบบส่วนลดและ Promotion ที่ครอบคลุมทุกมิติ:
- ส่วนลดทริปท่องเที่ยว
- ส่วนลดลูกค้าใหม่ (First-time discount)
- ส่วนลดบริการสื่อ (Media services)
- ส่วนลดสินค้า Digital Download
- ส่วนลด Subscription
- ส่วนลด Credit Purchase
- และอื่นๆ

---

## 📋 Features

### 1. Discount Types
- **Percentage Discount** - ลดเป็นเปอร์เซ็นต์ (เช่น 10%, 20%)
- **Fixed Amount Discount** - ลดเป็นจำนวนเงินคงที่ (เช่น ฿100, ฿500)
- **Free Item** - ให้ของฟรี (เช่น ฟรี 1 ครั้ง)
- **Buy X Get Y** - ซื้อ X ได้ Y (เช่น ซื้อ 2 แถม 1)

### 2. Discount Scopes
- **Trip Discounts** - ส่วนลดทริปท่องเที่ยว
- **Activity Discounts** - ส่วนลดกิจกรรม
- **Media Service Discounts** - ส่วนลดบริการสื่อ (Image, Video, Music generation)
- **Digital Download Discounts** - ส่วนลดสินค้า Digital Download
- **Subscription Discounts** - ส่วนลด Subscription Plans
- **Credit Purchase Discounts** - ส่วนลดการซื้อ Credits
- **Content Access Discounts** - ส่วนลดการเข้าถึงเนื้อหา

### 3. Discount Rules
- **First-Time User** - ลูกค้าใหม่เท่านั้น
- **Minimum Purchase** - ซื้อขั้นต่ำ (เช่น ซื้อขั้นต่ำ ฿1000)
- **User Group** - เฉพาะกลุ่มผู้ใช้ (เช่น Member, Premium)
- **Time-Based** - ตามเวลา (เช่น วันหยุด, ช่วงโปรโมชัน)
- **Quantity-Based** - ตามจำนวน (เช่น ซื้อ 3 ขึ้นไป)
- **Combination** - รวมหลายเงื่อนไข

### 4. Discount Management
- **Create Discount Codes** - สร้างโค้ดส่วนลด
- **Set Validity Period** - กำหนดระยะเวลาใช้งาน
- **Usage Limits** - จำกัดจำนวนครั้งที่ใช้ได้
- **User Limits** - จำกัดจำนวนผู้ใช้
- **Track Usage** - ติดตามการใช้งาน
- **Analytics** - วิเคราะห์ผล

### 5. Auto-Apply Discounts
- **Automatic Application** - ใช้ส่วนลดอัตโนมัติ (เช่น ลูกค้าใหม่)
- **Best Discount Selection** - เลือกส่วนลดที่ดีที่สุดให้อัตโนมัติ
- **Stack Discounts** - รวมส่วนลดหลายตัว (ถ้าอนุญาต)

---

## 🏗️ Architecture

### Database Schema

```sql
-- Discount Codes
CREATE TABLE discount_codes (
    id UUID PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type VARCHAR(50) NOT NULL, -- "percentage", "fixed_amount", "free_item", "buy_x_get_y"
    discount_value DECIMAL(10,2), -- Percentage or amount
    min_purchase_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2), -- For percentage discounts
    applicable_to VARCHAR(50), -- "trip", "activity", "media_service", "digital_download", "subscription", "credit", "content", "all"
    applicable_item_ids UUID[], -- Specific items (optional)
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    usage_limit INTEGER, -- Total usage limit
    usage_count INTEGER DEFAULT 0,
    user_limit INTEGER, -- Per user limit
    first_time_only BOOLEAN DEFAULT false,
    user_group VARCHAR(50), -- "all", "member", "premium", "staff"
    status VARCHAR(50) DEFAULT "active", -- "active", "inactive", "expired"
    auto_apply BOOLEAN DEFAULT false,
    stackable BOOLEAN DEFAULT false,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Discount Usage
CREATE TABLE discount_usage (
    id UUID PRIMARY KEY,
    discount_code_id UUID REFERENCES discount_codes(id),
    user_id UUID REFERENCES auth.users(id),
    order_id UUID, -- Reference to order/transaction
    item_type VARCHAR(50), -- "trip", "activity", "media_service", etc.
    item_id UUID,
    original_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    final_amount DECIMAL(10,2),
    used_at TIMESTAMPTZ DEFAULT NOW()
);

-- Discount Analytics
CREATE TABLE discount_analytics (
    id UUID PRIMARY KEY,
    discount_code_id UUID REFERENCES discount_codes(id),
    date DATE,
    usage_count INTEGER DEFAULT 0,
    total_discount_amount DECIMAL(10,2) DEFAULT 0,
    total_revenue DECIMAL(10,2) DEFAULT 0,
    new_users_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(discount_code_id, date)
);
```

---

## ✅ Success Criteria

- [ ] Admin สามารถสร้าง Discount Codes ได้
- [ ] ระบบรองรับทุกประเภทส่วนลด
- [ ] ระบบรองรับทุก Scope (Trip, Activity, Media, etc.)
- [ ] ระบบ Auto-apply สำหรับลูกค้าใหม่
- [ ] ติดตาม Usage และ Analytics
- [ ] Frontend UI สำหรับจัดการส่วนลด
- [ ] Integration กับ Monetization System

---

**Status:** 📋 Ready for Implementation

