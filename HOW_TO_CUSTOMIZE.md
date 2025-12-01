# วิธีปรับแต่งเว็บ: Banner, Font, ภาพประกอบ

## 🎯 วิธีเข้าถึงเมนูปรับแต่ง

### ขั้นตอนที่ 1: Login เป็น Admin

1. ไปที่: `https://funaging.studio/admin/sign-in`
   หรือ `http://localhost:8080/admin/sign-in`

2. Login ด้วย account ที่มี role **admin**

### ขั้นตอนที่ 2: เข้าเมนู Theme Customization

**วิธีที่ 1: ผ่าน Sidebar Menu**
1. หลังจาก login จะเห็น Admin Dashboard
2. ดูที่ **Sidebar ซ้าย**
3. คลิก **⚙️ System Management** (จะขยายเมนู)
4. คลิก **Theme Customization** (มี icon 🎨 Palette)

**วิธีที่ 2: ผ่าน URL โดยตรง**
- ไปที่: `https://funaging.studio/admin/theme-customization`
- หรือ: `http://localhost:8080/admin/theme-customization`

---

## 🎨 เมนูปรับแต่งที่มี

### 1. Colors (สี)
- Primary Color
- Secondary Color
- Accent Color
- Background Color
- และอื่นๆ

### 2. Typography (Font)
- Font Family (เลือกฟอนต์)
- Base Font Size
- Heading Sizes (H1-H6)
- Line Height
- Letter Spacing
- Font Weight

### 3. Banner (ภาพประกอบ/วิดีโอ)
- Enable/Disable Banner
- Banner Type (Image หรือ Video)
- Image URL (ใส่ URL ภาพ)
- Video URL (ใส่ URL วิดีโอ)
- Overlay Color (สีทับ)
- Overlay Opacity (ความโปร่งใส)
- Height (ความสูง)
- Position (ตำแหน่ง)

### 4. Layout (โครงสร้าง)
- Container Max Width
- Sidebar Width
- Header Height
- Footer Height
- Grid Gaps

### 5. Components (คอมโพเนนต์)
- Button Style
- Card Style
- Input Style
- Table Style

### 6. Effects (เอฟเฟกต์)
- Border Radius
- Shadow
- Transition
- Hover Effect

---

## 📝 วิธีปรับแต่ง Banner

1. **เข้า Theme Customization** (ตามขั้นตอนด้านบน)

2. **คลิก Tab "Banner"**

3. **ตั้งค่า:**
   - ✅ Enable Banner (เปิดใช้งาน)
   - เลือก Type: **Image** หรือ **Video**
   - ใส่ **Image URL** หรือ **Video URL**
   - ปรับ Overlay Color และ Opacity
   - ปรับ Height และ Position

4. **คลิก "Save Theme"** เพื่อบันทึก

---

## 📝 วิธีปรับแต่ง Font

1. **เข้า Theme Customization**

2. **คลิก Tab "Typography"**

3. **ตั้งค่า:**
   - เลือก **Font Family** (เช่น Noto Serif Thai, Prompt, Kanit)
   - ปรับ **Base Font Size**
   - ปรับ **Heading Sizes** (H1-H6)
   - ปรับ **Line Height**, **Letter Spacing**, **Font Weight**

4. **คลิก "Save Theme"** เพื่อบันทึก

---

## 📝 วิธีปรับแต่งภาพประกอบอื่นๆ

### ภาพใน Hero Section
- ใช้ **Banner Tab** ใน Theme Customization
- ใส่ Image URL

### ภาพในส่วนอื่นๆ
- ต้องแก้ไขในโค้ดโดยตรง
- หรือใช้ Media Center (`/admin/media`) เพื่ออัปโหลดภาพ

---

## 💾 การบันทึก

1. **Preview** - ดูตัวอย่างก่อน (ไม่บันทึก)
2. **Save Theme** - บันทึก theme ใหม่
3. **Apply Theme** - ใช้ theme ทันที
4. **Reset** - กลับค่าเริ่มต้น

---

## 🔗 URL ตรง

- **Theme Customization:** `/admin/theme-customization`
- **Media Center:** `/admin/media` (อัปโหลดภาพ)
- **Admin Dashboard:** `/admin/dashboard`

---

## 📌 สรุป

**ปรับแต่ง Banner/Font:**
1. Login เป็น Admin
2. ไปที่: **System Management** → **Theme Customization**
3. เลือก Tab: **Banner** หรือ **Typography**
4. ปรับแต่งตามต้องการ
5. คลิก **Save Theme**



