# แก้ไขปัญหา Vercel Login

## ปัญหา: Code ไม่ผ่าน

### สาเหตุ
- Code หมดอายุ (หมดอายุใน 15 นาที)
- Format ไม่ถูกต้อง
- Code ถูกใช้ไปแล้ว

### วิธีแก้

**1. หยุด vercel login**
- ไปที่ terminal ที่รัน `vercel login`
- กด **Ctrl+C** เพื่อหยุด

**2. รันใหม่**
```powershell
vercel login
```

**3. ใช้ Code ใหม่**
- ดู code ใหม่ใน terminal
- ใส่ใน browser (ใส่ทีละตัว แยกด้วย hyphen)
- ตัวอย่าง: `L-B-G-J-S-X-Q-K`

**4. ตรวจสอบ Format**
- Code ต้องมี 8 ตัวอักษร
- แยกด้วย hyphen: `X-X-X-X-X-X-X-X`
- ตัวพิมพ์ใหญ่ทั้งหมด

### วิธีใส่ Code ที่ถูกต้อง

**ตัวอย่าง Code: `LBGJ-SXQK`**
- ใส่เป็น: `L-B-G-J-S-X-Q-K`
- **ไม่ใส่** space
- **ไม่ใส่** code เดิมที่หมดอายุ

### ถ้ายังไม่ผ่าน

**ลองวิธีอื่น:**
1. ใช้ URL โดยตรง: `https://vercel.com/oauth/device?user_code=XXXX-XXXX`
2. ตรวจสอบว่า code ยังไม่หมดอายุ
3. รัน `vercel login` ใหม่เพื่อได้ code ใหม่

