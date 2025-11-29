# วิธี Deploy ไป Production

## วิธีที่ 1: Auto-Wait (แนะนำ)

รันใน **Cursor Terminal**:

```powershell
.\wait-and-deploy.ps1
```

สคริปต์จะ:
- รอให้ vercel login เสร็จ (ตรวจสอบทุก 2 วินาที)
- Deploy อัตโนมัติเมื่อ login สำเร็จ

## วิธีที่ 2: Manual

### Step 1: Login Vercel
รันใน **Cursor Terminal**:

```powershell
vercel login
```

### Step 2: ตรวจสอบว่า Login เสร็จ
รันใน **Cursor Terminal**:

```powershell
.\check-vercel-login.ps1
```

ถ้าเห็น `✅ Logged in as: [your-email]` แสดงว่าเสร็จแล้ว

### Step 3: Deploy
รันใน **Cursor Terminal**:

```powershell
.\DEPLOY_NOW.ps1
```

## วิธีตรวจสอบว่า Vercel Login เสร็จ

### วิธีที่ 1: ใช้สคริปต์
```powershell
.\check-vercel-login.ps1
```

### วิธีที่ 2: ตรวจสอบเอง
```powershell
vercel whoami
```

ถ้าเห็น email ของคุณ = login เสร็จแล้ว
ถ้าเห็น error = ยังไม่ได้ login

## สรุป

**รันใน Cursor Terminal:**
1. `vercel login` → รอ authenticate ใน browser
2. `.\check-vercel-login.ps1` → ตรวจสอบว่าเสร็จ
3. `.\DEPLOY_NOW.ps1` → Deploy

**หรือใช้วิธีง่าย:**
- `.\wait-and-deploy.ps1` → ทำทุกอย่างอัตโนมัติ

