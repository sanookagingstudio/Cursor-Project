# วิธี Login Vercel

## Code มาจากไหน?

**Code มาจาก Terminal ที่รัน `vercel login`**

## ขั้นตอน:

### 1. ดู Code ใน Terminal
ใน PowerShell ที่รัน `vercel login` จะเห็น:
```
Visit https://vercel.com/oauth/device?user_code=LBGJ-SXQK
```

**Code คือ:** `LBGJ-SXQK` (ส่วนหลัง `user_code=`)

### 2. ใส่ Code ใน Browser
- ใส่ code: **L-B-G-J-S-X-Q-K** (ใส่ทีละตัว แยกด้วย hyphen)
- หรือ copy code `LBGJ-SXQK` แล้วใส่ในช่อง

### 3. กด Allow
- หลังจากใส่ code ถูกต้อง
- กดปุ่ม "Allow" เพื่อ authorize

### 4. ตรวจสอบว่าเสร็จ
ใน Terminal จะเห็น:
```
Successfully authenticated!
```

### 5. Deploy
```powershell
.\wait-and-deploy.ps1
```

## หมายเหตุ
- Code จะหมดอายุใน 15 นาที
- ถ้า code หมดอายุ ให้รัน `vercel login` ใหม่

