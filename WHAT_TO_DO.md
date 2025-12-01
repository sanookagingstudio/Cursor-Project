# สิ่งที่ต้องทำ

## สรุป

### ✅ `funaging.club` - ไม่ต้องทำอะไร
- DNS ตั้งค่าแล้ว (76.76.21.21)
- Vercel จะ verify อัตโนมัติ
- รอ 5-30 นาที
- Vercel จะส่ง email เมื่อพร้อมใช้งาน

### ❌ `funaging.studio` - ต้องลบออก
- ยังไม่มี DNS records
- ทำให้เกิด "Invalid Configuration" error
- ต้องลบออกจาก Vercel

---

## ขั้นตอน

### 1. ลบ `funaging.studio` ออกจาก Vercel

รันคำสั่งนี้:

```powershell
vercel domains remove funaging.studio
```

### 2. รอ Vercel verify `funaging.club`

- ไม่ต้องทำอะไร
- Vercel จะ verify อัตโนมัติ
- ใช้เวลา 5-30 นาที
- Vercel จะส่ง email เมื่อพร้อมใช้งาน

### 3. ตรวจสอบ (Optional)

```powershell
# ตรวจสอบ funaging.club
vercel domains inspect funaging.club

# ดู domains ทั้งหมด
vercel domains ls
```

---

## สรุป

**ต้องทำ:** ลบ `funaging.studio` ออกจาก Vercel (1 คำสั่ง)

**ไม่ต้องทำ:** รอ Vercel verify `funaging.club` อัตโนมัติ



