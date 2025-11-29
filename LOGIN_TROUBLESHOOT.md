# แก้ไขปัญหา Vercel Login

## ปัญหา: Code ไม่ผ่านทั้งแบบมีและไม่มี hyphen

### สาเหตุ
1. **Code หมดอายุ** - Code หมดอายุใน 15 นาที
2. **Code ถูกใช้ไปแล้ว** - Code ใช้ได้ครั้งเดียว
3. **Format ไม่ถูกต้อง** - ต้องใส่แยกด้วย hyphen

### วิธีแก้

**1. หยุด vercel login**
- ไปที่ terminal ที่รัน `vercel login`
- กด **Ctrl+C** เพื่อหยุด

**2. รันใหม่ทันที**
```powershell
vercel login
```

**3. ใช้ Code ใหม่ทันที**
- Code ใหม่จะแสดงใน terminal
- **ใช้ทันที** (อย่ารอ)
- Code หมดอายุใน 15 นาที

**4. ใส่ Code ใน Browser**
- ใส่: `K-M-W-L-X-J-R-S` (แยกด้วย hyphen)
- **ไม่ใช่:** `KMWLXJRS` (ติดกัน)
- **ไม่ใช่:** `KMWL-XJRS` (มี hyphen แค่กลาง)

**5. กด Allow**
- หลังจากใส่ code ถูกต้อง
- กดปุ่ม "Allow"

### วิธีใส่ Code ที่ถูกต้อง

**ตัวอย่าง Code: `KMWL-XJRS`**
1. แยกเป็นตัวอักษร: `K M W L X J R S`
2. ใส่ใน browser: `K-M-W-L-X-J-R-S`
3. แต่ละตัวแยกด้วย hyphen

### Tips
- ใช้ code ทันทีหลังจากได้มา
- อย่ารอเกิน 15 นาที
- ถ้า code ไม่ผ่าน ให้รัน `vercel login` ใหม่

