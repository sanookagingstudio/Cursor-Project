# Phase 8: Video Banner Guide

## 🎬 Video Banner Feature

Phase 8 ตอนนี้รองรับ **Video Banner** แล้ว! Admin สามารถใส่ video เป็น background ของ Hero Section ได้

---

## ✨ ความสามารถ Video Banner

### 1. รองรับ Video Formats
- ✅ **MP4** - รองรับมากที่สุด
- ✅ **WebM** - สำหรับ browser ที่รองรับ
- ✅ **OGG** - สำหรับ browser ที่รองรับ

### 2. Video Settings
- ✅ **Autoplay** - เล่นอัตโนมัติเมื่อโหลดหน้า
- ✅ **Loop** - วนซ้ำวิดีโอ
- ✅ **Muted** - ปิดเสียง (จำเป็นสำหรับ Autoplay)

### 3. Overlay Settings
- ✅ **Overlay Color** - สีทับ video (เช่น #000000, rgba(0,0,0,0.5))
- ✅ **Overlay Opacity** - ความโปร่งใส (0-100%)
  - 0% = ไม่มี overlay
  - 50% = overlay กลางๆ
  - 100% = overlay เต็ม (video จะมืด)

### 4. Banner Height
- ✅ **Auto** - ความสูงอัตโนมัติ
- ✅ **400px** - ความสูง 400px
- ✅ **600px** - ความสูง 600px
- ✅ **800px** - ความสูง 800px
- ✅ **100vh** - เต็มหน้าจอ

### 5. Content Position
- ✅ **Top** - เนื้อหาอยู่ด้านบน
- ✅ **Center** - เนื้อหาอยู่กลาง (default)
- ✅ **Bottom** - เนื้อหาอยู่ด้านล่าง

---

## 🎯 วิธีใช้งาน Video Banner

### ขั้นตอนที่ 1: เตรียม Video
1. เตรียม video file (MP4, WebM, หรือ OGG)
2. Upload video ไปยัง:
   - Cloud Storage (AWS S3, Google Cloud Storage, etc.)
   - CDN (Cloudflare, etc.)
   - หรือใช้ URL จาก YouTube/Vimeo (embed)
3. เก็บ Video URL ไว้

### ขั้นตอนที่ 2: ตั้งค่าใน Theme Customization
1. ไปที่ `/admin/theme-customization`
2. ไปที่ Tab **"Banner"** (Tab ที่ 6)
3. เปิด **"Enable Banner"**
4. เลือก **"Video"** ใน Banner Type
5. ใส่ **Video URL** (เช่น `https://example.com/video.mp4`)
6. ตั้งค่า Video:
   - ✅ Autoplay (แนะนำ: เปิด)
   - ✅ Loop (แนะนำ: เปิด)
   - ✅ Muted (แนะนำ: เปิด - จำเป็นสำหรับ Autoplay)
7. ตั้งค่า Overlay:
   - เลือก **Overlay Color** (เช่น #000000)
   - ปรับ **Overlay Opacity** (แนะนำ: 30-50%)
8. เลือก **Banner Height** (เช่น 100vh สำหรับเต็มหน้าจอ)
9. เลือก **Content Position** (เช่น center)
10. **Save Theme** และ **Apply**

---

## 💡 Tips สำหรับ Video Banner

### 1. Video File Size
- **แนะนำ:** ใช้ video ที่ optimize แล้ว (ขนาดเล็ก แต่คุณภาพดี)
- **Format:** MP4 (H.264) รองรับดีที่สุด
- **Resolution:** 1920x1080 หรือ 1280x720
- **Duration:** สั้นๆ (10-30 วินาที) แล้ว Loop

### 2. Overlay Opacity
- **30-40%** - เหมาะสำหรับ video สว่าง
- **50-60%** - เหมาะสำหรับ video กลางๆ
- **70-80%** - เหมาะสำหรับ video มืด หรือต้องการให้ข้อความชัดเจน

### 3. Content Position
- **Center** - เหมาะสำหรับ Hero Section ทั่วไป
- **Bottom** - เหมาะสำหรับ video ที่มี action ด้านบน
- **Top** - เหมาะสำหรับ video ที่มี action ด้านล่าง

### 4. Banner Height
- **100vh** - สร้าง impact มากที่สุด (เต็มหน้าจอ)
- **600-800px** - เหมาะสำหรับ desktop
- **Auto** - เหมาะสำหรับ responsive

---

## 🎬 ตัวอย่างการใช้งาน

### ตัวอย่าง 1: Video Banner แบบเต็มหน้าจอ
```
Banner Type: Video
Video URL: https://cdn.example.com/hero-video.mp4
Autoplay: ✅
Loop: ✅
Muted: ✅
Overlay Color: #000000
Overlay Opacity: 40%
Banner Height: 100vh
Content Position: Center
```

### ตัวอย่าง 2: Video Banner แบบมีข้อความชัดเจน
```
Banner Type: Video
Video URL: https://cdn.example.com/hero-video.mp4
Autoplay: ✅
Loop: ✅
Muted: ✅
Overlay Color: #000000
Overlay Opacity: 60%
Banner Height: 600px
Content Position: Center
```

### ตัวอย่าง 3: Image Banner (ไม่มี video)
```
Banner Type: Image
Image URL: https://cdn.example.com/hero-image.jpg
Overlay Color: #000000
Overlay Opacity: 30%
Banner Height: 400px
Content Position: Center
```

---

## 🔧 Technical Details

### CSS Variables
Video Banner ใช้ CSS Variables เพื่อ apply ทันที:
- `--banner-enabled` - เปิด/ปิด banner
- `--banner-type` - ประเภท banner (image/video)
- `--banner-video` - Video URL
- `--banner-image` - Image URL
- `--banner-overlay-color` - สี overlay
- `--banner-overlay-opacity` - ความโปร่งใส overlay
- `--banner-height` - ความสูง banner
- `--banner-position` - ตำแหน่งเนื้อหา

### HeroSection Component
`HeroSection` component ถูกอัพเดทให้รองรับ:
- Video background
- Image background
- Overlay
- Dynamic height
- Content positioning

---

## ✅ สรุป

**Video Banner Feature** ให้ Admin สามารถ:
- ✅ ใส่ video เป็น background ของ Hero Section
- ✅ ตั้งค่า Autoplay, Loop, Muted
- ✅ ปรับ Overlay Color และ Opacity
- ✅ เลือก Banner Height
- ✅ เลือก Content Position
- ✅ ดูผลลัพธ์ทันที (Real-time Preview)

**ไม่ต้องแก้ไขโค้ด!** ทุกอย่างทำผ่าน UI เท่านั้น! 🎬

