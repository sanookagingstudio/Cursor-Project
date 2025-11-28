# 📦 OnePack - GitHub Backup & Update Automation

## 🎯 วัตถุประสงค์

OnePack เป็น automation script สำหรับ backup และ update โปรเจกต์ไปยัง GitHub อัตโนมัติ เพื่อ:
- ✅ Backup งานเมื่อหยุดกลางคัน
- ✅ ไม่ต้องเริ่มต้นใหม่เมื่อกลับมาทำงานต่อ
- ✅ Version control และ history tracking
- ✅ Sync งานระหว่างเครื่อง/ทีม

---

## 🚀 การใช้งาน

### Windows (PowerShell)

```powershell
# Backup (commit และ push ไป GitHub)
.\onepack.ps1 -Action backup -Message "Your commit message"

# Restore (pull latest จาก GitHub)
.\onepack.ps1 -Action restore

# ดูสถานะ
.\onepack.ps1 -Action status
```

### Linux/Mac (Bash)

```bash
# ให้สิทธิ์ execute
chmod +x onepack.sh

# Backup
./onepack.sh backup "Your commit message"

# Restore
./onepack.sh restore

# ดูสถานะ
./onepack.sh status
```

---

## ⚙️ การตั้งค่า

### 1. ตั้งค่า GitHub Repository URL

แก้ไขไฟล์ `onepack.ps1` หรือ `onepack.sh`:

```powershell
# onepack.ps1
$GitHubRepo = "https://github.com/your-username/your-repo.git"
```

```bash
# onepack.sh
GITHUB_REPO="https://github.com/your-username/your-repo.git"
```

### 2. ตั้งค่า Git Credentials

#### วิธีที่ 1: ใช้ Personal Access Token (แนะนำ)

```bash
# Windows
git config --global credential.helper wincred

# Linux/Mac
git config --global credential.helper store
```

#### วิธีที่ 2: ใช้ SSH Keys (ปลอดภัยที่สุด)

```bash
# สร้าง SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# เพิ่ม SSH key ไป GitHub
# Copy public key: ~/.ssh/id_ed25519.pub
# ไปที่ GitHub Settings > SSH and GPG keys > New SSH key
```

---

## 📋 Workflow แนะนำ

### เมื่อเริ่มทำงาน

```bash
# 1. Restore latest จาก GitHub
./onepack.sh restore

# 2. เริ่มทำงาน
# ... ทำการพัฒนา ...
```

### เมื่อหยุดทำงาน (กลางคัน)

```bash
# Backup งานทั้งหมด
./onepack.sh backup "Work in progress - [description]"
```

### เมื่อทำงานเสร็จ

```bash
# Backup พร้อม commit message ที่ชัดเจน
./onepack.sh backup "Feature: Add Image Module API endpoints"
```

---

## 🔧 Troubleshooting

### ปัญหา: "Failed to push to GitHub"

**สาเหตุ:** ยังไม่ได้ตั้งค่า Git credentials

**แก้ไข:**
```bash
# ตั้งค่า username และ email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# ตั้งค่า credential helper
git config --global credential.helper store
```

### ปัญหา: "Git remote not set"

**แก้ไข:** Script จะตั้งค่าให้อัตโนมัติ หรือตั้งค่าด้วยตนเอง:
```bash
git remote add origin https://github.com/your-username/your-repo.git
```

### ปัญหา: "Git repository not initialized"

**แก้ไข:** Script จะ initialize ให้อัตโนมัติ หรือทำด้วยตนเอง:
```bash
git init
git branch -M main
```

---

## 📝 Best Practices

1. **Commit Message ที่ชัดเจน**
   ```bash
   ./onepack.sh backup "Feature: Add Video Module - Phase 4"
   ```

2. **Backup บ่อยๆ**
   - ก่อนหยุดทำงาน
   - หลังเสร็จ feature สำคัญ
   - ทุก 1-2 ชั่วโมง

3. **Restore ก่อนเริ่มทำงาน**
   ```bash
   ./onepack.sh restore
   ```

4. **ตรวจสอบ Status ก่อน Backup**
   ```bash
   ./onepack.sh status
   ```

---

## 🔐 Security Notes

- ⚠️ **อย่า commit sensitive data** (passwords, API keys, .env files)
- ✅ ใช้ `.gitignore` เพื่อ exclude ไฟล์ที่ sensitive
- ✅ ใช้ environment variables สำหรับ credentials
- ✅ ใช้ GitHub Secrets สำหรับ CI/CD

---

## 📚 Related Documents

- `MASTER_V2_RULES.md` - กฎกติกา Master V2
- `MEDIA_CREATOR_COMPLETE_ARCHITECTURE.md` - สถาปัตยกรรมระบบ

---

*OnePack - ทำให้การ backup และ sync งานเป็นเรื่องง่าย*

