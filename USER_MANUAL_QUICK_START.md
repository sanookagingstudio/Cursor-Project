# คู่มือ Quick Start: เริ่มใช้งาน Master V2

## 🚀 สำหรับผู้ใช้ใหม่

### CEO/Admin - เริ่มต้นใช้งาน

1. **Sign In**
   - ไปที่ `/admin/sign-in`
   - ใส่ Email และ Password
   - คลิก "Sign In"

2. **ดู Dashboard**
   - ไปที่ `/admin/dashboard`
   - ดูภาพรวมของระบบ

3. **ตั้งค่า Theme**
   - ไปที่ `/admin/theme-customization`
   - เลือก Preset หรือปรับแต่งเอง
   - คลิก "Save Theme"

4. **ตรวจสอบ Cost**
   - ไปที่ `/admin/cost-management`
   - เพิ่ม Infrastructure Items
   - เพิ่ม AI Providers
   - ดู Cost Summary

5. **ตั้งค่า Monetization**
   - ไปที่ `/admin/monetization`
   - ดู Subscription Plans
   - ตั้งค่า Credit Packages

---

### Staff - เริ่มต้นใช้งาน

1. **Sign In**
   - ไปที่ `/staff/sign-in`
   - ใส่ Email และ Password
   - คลิก "Sign In"

2. **สร้าง Content Idea**
   - ไปที่ `/admin/input-brain`
   - คลิก "Create New Idea"
   - รับ AI Suggestions

3. **สร้างภาพ**
   - ไปที่ `/admin/image-editor`
   - ไปที่ Generate Tab
   - ใส่ Prompt
   - คลิก "Generate"

4. **สร้างวิดีโอ**
   - ไปที่ `/admin/video-editor`
   - ไปที่ Generate Tab
   - ใส่ Prompt
   - คลิก "Generate"

5. **Publish Content**
   - ไปที่ `/admin/dashboard-publishing`
   - สร้าง Channel
   - สร้าง Publishing Plan
   - Schedule Publishing

---

### Member/ลูกค้า - เริ่มต้นใช้งาน

1. **Sign Up**
   - ไปที่ `/sign-up`
   - กรอกข้อมูล
   - คลิก "Sign Up"

2. **ดู Activities**
   - ไปที่ `/activities`
   - ดูรายการ Activities
   - คลิก "Book This Activity"

3. **ดู Trips**
   - ไปที่ `/trips`
   - ดูรายการ Trips
   - คลิก "View Trip Details"

4. **ดู Media**
   - ไปที่ `/media`
   - ดูรายการ Media
   - คลิกเพื่อดูรายละเอียด

5. **ซื้อ Credits (ถ้าต้องการ)**
   - ไปที่ Profile
   - คลิก "Purchase Credits"
   - เลือก Package
   - ชำระเงิน

---

## 📱 สำหรับ Mobile App Developer

1. **ขอ API Key จาก Admin**
   - ติดต่อ Admin เพื่อ Register App
   - รับ API Key

2. **Setup API Client**
   ```javascript
   const api = new MasterV2API('api-key', 'app-id');
   ```

3. **Register User**
   ```javascript
   await api.request('/auth/register', 'POST', {
     external_user_id: 'user-123'
   });
   ```

4. **Get Content**
   ```javascript
   const content = await api.request('/content/123');
   ```

5. **Handle Payment**
   ```javascript
   const balance = await api.request('/credits/balance');
   if (balance.data.balance < 10) {
     // Show purchase dialog
   }
   ```

---

## 💡 Tips สำหรับผู้ใช้ใหม่

1. **เริ่มจาก Dashboard** เพื่อดูภาพรวม
2. **ใช้ Presets** ใน Theme Customization เพื่อความเร็ว
3. **ทดสอบฟีเจอร์** ก่อนใช้งานจริง
4. **อ่านคู่มือ** เพื่อเข้าใจฟีเจอร์
5. **ติดต่อ Support** ถ้ามีปัญหา

---

**พร้อมใช้งานแล้ว!** 🎉

