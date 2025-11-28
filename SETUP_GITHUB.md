# 🔧 การตั้งค่า Git & GitHub สำหรับ Master V2

## 📊 สถานะปัจจุบัน

❌ **Git repository ยังไม่ได้ initialize**  
❌ **ยังไม่ได้เชื่อมกับ GitHub**  
❌ **Cursor ยังไม่สามารถบันทึกไป GitHub อัตโนมัติ**

---

## 🔍 Cursor ทำงานกับ Git/GitHub อย่างไร?

### ✅ สิ่งที่ Cursor ทำได้:
1. **แสดง Source Control Panel** - ดูการเปลี่ยนแปลงไฟล์
2. **แสดง Diff** - ดูความแตกต่างของโค้ด
3. **Commit ผ่าน UI** - แต่ต้องกด commit เอง
4. **Push/Pull ผ่าน Terminal** - ใช้คำสั่ง git ธรรมดา

### ❌ สิ่งที่ Cursor ไม่ทำ:
- ❌ **ไม่ commit อัตโนมัติ** - ต้อง commit เอง
- ❌ **ไม่ push อัตโนมัติ** - ต้อง push เอง
- ❌ **ไม่ sync อัตโนมัติ** - ต้อง pull เอง

---

## 🚀 วิธีตั้งค่า (Step by Step)

### Step 1: Initialize Git Repository

```powershell
# เปิด PowerShell ในโฟลเดอร์โปรเจกต์
cd "d:\SanookAgingStudio\shadow project\sanook-master-v2-main"

# Initialize Git
git init

# ตั้งค่า branch หลัก
git branch -M main

# ตั้งค่า user (ถ้ายังไม่ได้ตั้ง)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 2: สร้าง GitHub Repository

1. ไปที่ [GitHub.com](https://github.com)
2. คลิก **New Repository**
3. ตั้งชื่อ repository (เช่น `sanook-master-v2`)
4. เลือก **Private** หรือ **Public**
5. **อย่า** check "Initialize with README"
6. คลิก **Create repository**

### Step 3: เชื่อมกับ GitHub

```powershell
# เพิ่ม remote repository
git remote add origin https://github.com/your-username/sanook-master-v2.git

# ตรวจสอบว่าเชื่อมแล้ว
git remote -v
```

### Step 4: Commit ครั้งแรก

```powershell
# เพิ่มไฟล์ทั้งหมด
git add .

# Commit
git commit -m "Initial commit - Master V2"

# Push ไป GitHub
git push -u origin main
```

---

## 📦 ใช้ OnePack สำหรับ Backup อัตโนมัติ

### ตั้งค่า OnePack

1. แก้ไข `onepack.ps1`:
```powershell
$GitHubRepo = "https://github.com/your-username/sanook-master-v2.git"
```

2. ใช้ OnePack สำหรับ backup:
```powershell
# Backup (commit + push)
.\onepack.ps1 -Action backup -Message "Work in progress"

# Restore (pull latest)
.\onepack.ps1 -Action restore

# ดูสถานะ
.\onepack.ps1 -Action status
```

---

## 🎯 Workflow แนะนำ

### เมื่อเริ่มทำงาน:
```powershell
# 1. Restore latest จาก GitHub
.\onepack.ps1 -Action restore

# 2. เริ่มทำงาน
# ... ทำการพัฒนาใน Cursor ...
```

### เมื่อหยุดทำงาน:
```powershell
# Backup งานทั้งหมด
.\onepack.ps1 -Action backup -Message "Work in progress - [description]"
```

### เมื่อทำงานเสร็จ:
```powershell
# Backup พร้อม commit message ที่ชัดเจน
.\onepack.ps1 -Action backup -Message "Feature: Add Image Module API"
```

---

## 🔐 การตั้งค่า Git Credentials

### วิธีที่ 1: Personal Access Token (แนะนำ)

1. ไปที่ GitHub Settings > Developer settings > Personal access tokens
2. สร้าง token ใหม่ (เลือก scope: `repo`)
3. Copy token
4. เมื่อ push ครั้งแรก ใช้ token แทน password

### วิธีที่ 2: SSH Keys (ปลอดภัยที่สุด)

```powershell
# สร้าง SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# ไปที่ GitHub Settings > SSH and GPG keys > New SSH key
# Paste public key

# เปลี่ยน remote เป็น SSH
git remote set-url origin git@github.com:your-username/sanook-master-v2.git
```

---

## 💡 Tips

### 1. ใช้ Cursor Source Control Panel
- กด `Ctrl+Shift+G` เพื่อเปิด Source Control
- ดูไฟล์ที่เปลี่ยนแปลง
- Commit ผ่าน UI ได้

### 2. ใช้ OnePack Script
- **อัตโนมัติ** - ไม่ต้องจำคำสั่ง git
- **ปลอดภัย** - backup ก่อนหยุดทำงาน
- **สะดวก** - restore เมื่อกลับมาทำงานต่อ

### 3. Commit Message ที่ดี
```
Feature: Add Image Module API endpoints
Fix: Resolve authentication issue
Update: Improve UI components
Docs: Add API documentation
```

---

## ⚠️ สิ่งที่ต้องระวัง

1. **อย่า commit sensitive data**
   - `.env` files
   - API keys
   - Passwords
   - (ใช้ `.gitignore` แล้ว)

2. **Backup บ่อยๆ**
   - ก่อนหยุดทำงาน
   - หลังเสร็จ feature สำคัญ

3. **Pull ก่อน Push**
   - ถ้าทำงานหลายเครื่อง
   - Pull ก่อนเสมอ

---

## ✅ Checklist

- [ ] Initialize Git repository
- [ ] สร้าง GitHub repository
- [ ] เชื่อม remote repository
- [ ] ตั้งค่า Git credentials
- [ ] Commit ครั้งแรก
- [ ] Push ไป GitHub
- [ ] ตั้งค่า OnePack script
- [ ] ทดสอบ OnePack backup/restore

---

*เอกสารนี้ช่วยให้คุณตั้งค่า Git & GitHub สำหรับ Master V2*

