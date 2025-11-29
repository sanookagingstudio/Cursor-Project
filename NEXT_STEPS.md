# ขั้นตอนถัดไป - Vercel Login

## สถานะปัจจุบัน
คุณเห็น `vercel login` กำลังรอ authentication

## ทำตามนี้:

### Step 1: Authenticate
**ใน PowerShell ที่แสดง `Waiting for authentication...`:**
- กด **Enter** เพื่อเปิด browser
- หรือไปที่ URL ที่แสดง: `https://vercel.com/oauth/device?user_code=LBGJ-SXQK`
- Login ใน browser
- รอจนเห็น "Successfully authenticated" หรือ "Login successful"

### Step 2: ตรวจสอบว่า Login เสร็จ
**ใน Cursor Terminal (terminal อื่น):**
```powershell
.\check-vercel-login.ps1
```

ถ้าเห็น `✅ Logged in as: [email]` = เสร็จแล้ว

### Step 3: Deploy
**ใน Cursor Terminal:**
```powershell
.\AUTO_DEPLOY.ps1
```

## หรือใช้ Auto-Wait (แนะนำ)
**ใน Cursor Terminal:**
```powershell
.\wait-and-deploy.ps1
```

สคริปต์จะรอให้ login เสร็จแล้ว deploy อัตโนมัติ

