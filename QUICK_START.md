# 🚀 Quick Start - GitHub Setup & OnePack

## ⚡ เริ่มต้นใช้งาน (3 ขั้นตอน)

### Step 1: ตั้งค่า GitHub Repository

```powershell
# รัน script สำหรับ setup
.\setup-github.ps1
```

Script จะถาม:
- GitHub username ของคุณ
- Repository name (default: `sanook-master-v2`)
- ต้องการสร้าง initial commit หรือไม่

### Step 2: สร้าง Repository บน GitHub

1. ไปที่: https://github.com/new
2. Repository name: `sanook-master-v2` (หรือชื่อที่คุณตั้ง)
3. เลือก **Private** (แนะนำ)
4. **อย่า** check "Initialize with README"
5. คลิก **Create repository**

### Step 3: Push ครั้งแรก

```powershell
git push -u origin main
```

---

## 📦 ใช้ OnePack สำหรับ Backup

### Backup (เมื่อหยุดทำงาน)

```powershell
# Backup อัตโนมัติ
.\onepack.ps1 -Action backup

# หรือใส่ message
.\onepack.ps1 -Action backup -Message "Feature: Add Image Module"
```

### Restore (เมื่อกลับมาทำงาน)

```powershell
.\onepack.ps1 -Action restore
```

### ดูสถานะ

```powershell
.\onepack.ps1 -Action status
```

---

## 🎯 Workflow แนะนำ

### เมื่อเริ่มทำงาน:
```powershell
.\onepack.ps1 -Action restore  # ดึง latest จาก GitHub
# ... ทำงานใน Cursor ...
```

### เมื่อหยุดทำงาน:
```powershell
.\onepack.ps1 -Action backup -Message "Work in progress"
```

### เมื่อทำงานเสร็จ:
```powershell
.\onepack.ps1 -Action backup -Message "Feature: Add Video Module API"
```

---

## ✅ Checklist

- [ ] รัน `.\setup-github.ps1`
- [ ] สร้าง repository บน GitHub
- [ ] Push ครั้งแรก: `git push -u origin main`
- [ ] ทดสอบ OnePack: `.\onepack.ps1 -Action status`
- [ ] Backup ครั้งแรก: `.\onepack.ps1 -Action backup`

---

## 🔧 Troubleshooting

### ปัญหา: "GitHub repository not detected"

**แก้ไข:**
```powershell
# รัน setup script อีกครั้ง
.\setup-github.ps1
```

### ปัญหา: "Failed to push"

**แก้ไข:**
1. ตรวจสอบว่า repository สร้างบน GitHub แล้ว
2. ตั้งค่า Git credentials:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

---

*Quick Start Guide - เริ่มต้นใช้งานได้ใน 3 ขั้นตอน*

