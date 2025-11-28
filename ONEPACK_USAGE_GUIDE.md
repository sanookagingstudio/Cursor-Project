# 📦 OnePack - คู่มือการใช้งาน

## ❓ OnePack คืออะไร?

**OnePack = PowerShell Script** (ไม่มีปุ่ม UI)

- ✅ **Script ที่รันใน Terminal/PowerShell**
- ✅ **ทำหน้าที่ backup/restore ไป GitHub อัตโนมัติ**
- ✅ **ไม่มีปุ่มใน UI** - ต้องรันคำสั่ง

---

## 🚀 วิธีใช้งาน (3 ขั้นตอน)

### Step 1: เปิด PowerShell

**วิธีที่ 1: เปิด PowerShell ในโฟลเดอร์โปรเจกต์**
- คลิกขวาที่โฟลเดอร์โปรเจกต์
- เลือก "Open in Terminal" หรือ "Open PowerShell here"

**วิธีที่ 2: เปิด PowerShell แล้ว cd ไปที่โฟลเดอร์**
```powershell
cd "d:\SanookAgingStudio\shadow project\sanook-master-v2-main"
```

### Step 2: รันคำสั่ง OnePack

**Backup (เมื่อหยุดทำงาน):**
```powershell
.\onepack.ps1 -Action backup -Message "Work in progress"
```

**Restore (เมื่อกลับมาทำงาน):**
```powershell
.\onepack.ps1 -Action restore
```

**ดูสถานะ:**
```powershell
.\onepack.ps1 -Action status
```

### Step 3: เสร็จ!

Script จะทำงานอัตโนมัติ:
- ✅ Commit การเปลี่ยนแปลง
- ✅ Push ไป GitHub
- ✅ แสดงผลลัพธ์

---

## 📋 ตัวอย่างการใช้งานจริง

### เมื่อเริ่มทำงาน (เช้า)

```powershell
# 1. เปิด PowerShell
cd "d:\SanookAgingStudio\shadow project\sanook-master-v2-main"

# 2. Restore latest จาก GitHub
.\onepack.ps1 -Action restore

# 3. เริ่มทำงานใน Cursor
# ... ทำการพัฒนา ...
```

### เมื่อหยุดทำงาน (กลางวัน/เย็น)

```powershell
# Backup งานทั้งหมด
.\onepack.ps1 -Action backup -Message "Work in progress - Adding Image Module"
```

### เมื่อทำงานเสร็จ (Feature สำคัญ)

```powershell
# Backup พร้อม commit message ที่ชัดเจน
.\onepack.ps1 -Action backup -Message "Feature: Complete Image Module API endpoints"
```

---

## 🎯 คำสั่งที่ใช้บ่อย

### 1. Backup แบบเร็ว (ใช้ message อัตโนมัติ)
```powershell
.\onepack.ps1 -Action backup
```

### 2. Backup พร้อม message
```powershell
.\onepack.ps1 -Action backup -Message "Your custom message here"
```

### 3. Restore (ดึง latest จาก GitHub)
```powershell
.\onepack.ps1 -Action restore
```

### 4. ดูสถานะ
```powershell
.\onepack.ps1 -Action status
```

---

## 💡 Tips

### 1. สร้าง Shortcut (ทำให้ง่ายขึ้น)

**สร้างไฟล์ `backup.ps1`:**
```powershell
.\onepack.ps1 -Action backup -Message "Auto backup - $(Get-Date -Format 'HH:mm')"
```

**ใช้งาน:**
```powershell
.\backup.ps1
```

### 2. ใช้ Alias (ทำให้สั้นลง)

**เพิ่มใน PowerShell Profile:**
```powershell
# เปิด profile
notepad $PROFILE

# เพิ่มบรรทัดนี้
function backup { .\onepack.ps1 -Action backup -Message "Work in progress" }
function restore { .\onepack.ps1 -Action restore }
```

**ใช้งาน:**
```powershell
backup    # แทน .\onepack.ps1 -Action backup
restore   # แทน .\onepack.ps1 -Action restore
```

### 3. ใช้ใน Cursor Terminal

- กด `` Ctrl+` `` เพื่อเปิด Terminal ใน Cursor
- รันคำสั่ง OnePack ได้เลย

---

## 🔍 ตัวอย่าง Output

### เมื่อ Backup สำเร็จ:
```
🚀 OnePack - GitHub Backup & Update Automation
Project Root: D:\SanookAgingStudio\shadow project\sanook-master-v2-main
Action: backup
Repository: https://github.com/sanookagingstudio/Cursor-Project.git

=== OnePack Backup ===
Starting backup process...
Adding changes...
Committing changes...
Pushing to GitHub...
✅ Backup completed successfully!
📦 Changes pushed to: https://github.com/sanookagingstudio/Cursor-Project.git
```

### เมื่อ Restore สำเร็จ:
```
🚀 OnePack - GitHub Backup & Update Automation
=== OnePack Restore ===
Restoring from GitHub...
Pulling latest changes from GitHub...
✅ Restore completed successfully!
📦 Latest changes pulled from: https://github.com/sanookagingstudio/Cursor-Project.git
```

---

## ⚠️ สิ่งที่ต้องรู้

### 1. ต้องอยู่ในโฟลเดอร์โปรเจกต์
```powershell
# ตรวจสอบว่าอยู่ในโฟลเดอร์ที่ถูกต้อง
cd "d:\SanookAgingStudio\shadow project\sanook-master-v2-main"
```

### 2. ต้องมี Git credentials
- ถ้า push แล้วมี prompt ให้ใส่:
  - Username: `SanookAgingStudio`
  - Password: ใช้ **Personal Access Token** (ไม่ใช่ password)

### 3. ต้องมี Internet
- Backup/Restore ต้องเชื่อมต่อ GitHub

---

## 🎯 Workflow แนะนำ

### เช้า (เริ่มทำงาน):
```powershell
.\onepack.ps1 -Action restore
```

### กลางวัน (หยุดพัก):
```powershell
.\onepack.ps1 -Action backup -Message "Lunch break"
```

### เย็น (หยุดทำงาน):
```powershell
.\onepack.ps1 -Action backup -Message "End of day - Work in progress"
```

### เมื่อ Feature เสร็จ:
```powershell
.\onepack.ps1 -Action backup -Message "Feature: Add Video Module complete"
```

---

## ✅ สรุป

**OnePack = Script ที่รันใน PowerShell**

**วิธีใช้:**
1. เปิด PowerShell
2. รันคำสั่ง: `.\onepack.ps1 -Action backup`
3. เสร็จ!

**ไม่มีปุ่ม UI** - ต้องรันคำสั่งใน Terminal

---

*OnePack ทำให้การ backup/restore เป็นเรื่องง่าย!*

