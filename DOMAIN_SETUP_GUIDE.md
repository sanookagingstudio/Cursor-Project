# คู่มือตั้งค่า Domain: funaging.studio

## Domain Registrar คืออะไร?

**Domain Registrar** = ที่ที่คุณซื้อ domain name `funaging.studio` มาจาก

### ตัวอย่าง Domain Registrar ที่นิยม:
- **Namecheap** (namecheap.com)
- **GoDaddy** (godaddy.com)
- **Google Domains** (domains.google.com)
- **Cloudflare** (cloudflare.com)
- **Name.com** (name.com)
- **Porkbun** (porkbun.com)
- **อื่นๆ**

---

## วิธีหาว่าซื้อ Domain จากที่ไหน?

### วิธีที่ 1: ตรวจสอบ Email
- เปิด Email ที่ใช้ซื้อ domain
- หา email จาก registrar (เช่น receipt, confirmation email)
- Email จะบอกว่าซื้อจากที่ไหน

### วิธีที่ 2: ตรวจสอบ Credit Card/Bank Statement
- ดู statement การชำระเงิน
- หา charge จาก registrar

### วิธีที่ 3: ตรวจสอบ Whois
- ไปที่: https://whois.net
- พิมพ์: `funaging.studio`
- ดู "Registrar" จะบอกว่าซื้อจากที่ไหน

---

## วิธีตั้งค่า DNS ในแต่ละ Registrar

### 1. Namecheap

**ขั้นตอน:**
1. Login ที่ https://namecheap.com
2. ไปที่ **Domain List**
3. คลิก **Manage** ข้าง `funaging.studio`
4. ไปที่ **Advanced DNS** tab
5. ใน **Host Records** section:
   - คลิก **Add New Record**
   - Type: **A Record**
   - Host: **@**
   - Value: **76.76.21.21**
   - TTL: **Automatic**
   - คลิก **Save**
6. รอ 5-30 นาที

---

### 2. GoDaddy

**ขั้นตอน:**
1. Login ที่ https://godaddy.com
2. ไปที่ **My Products** → **Domains**
3. คลิก **DNS** ข้าง `funaging.studio`
4. ใน **Records** section:
   - คลิก **Add**
   - Type: **A**
   - Name: **@**
   - Value: **76.76.21.21**
   - TTL: **600 seconds**
   - คลิก **Save**
5. รอ 5-30 นาที

---

### 3. Google Domains

**ขั้นตอน:**
1. Login ที่ https://domains.google.com
2. คลิก **DNS** ข้าง `funaging.studio`
3. ใน **Custom resource records** section:
   - คลิก **Add record**
   - Type: **A**
   - Name: **@**
   - Data: **76.76.21.21**
   - TTL: **3600**
   - คลิก **Save**
4. รอ 5-30 นาที

---

### 4. Cloudflare

**ขั้นตอน:**
1. Login ที่ https://cloudflare.com
2. เลือก domain `funaging.studio`
3. ไปที่ **DNS** → **Records**
4. คลิก **Add record**
5. Type: **A**
6. Name: **@** (หรือ `funaging.studio`)
7. IPv4 address: **76.76.21.21**
8. Proxy status: **DNS only** (ไม่เปิด proxy)
9. คลิก **Save**
10. รอ 5-30 นาที

---

### 5. Name.com

**ขั้นตอน:**
1. Login ที่ https://name.com
2. ไปที่ **My Domains**
3. คลิก **DNS Records** ข้าง `funaging.studio`
4. คลิก **Add Record**
5. Type: **A**
6. Host: **@**
7. Answer: **76.76.21.21**
8. TTL: **3600**
9. คลิก **Add Record**
10. รอ 5-30 นาที

---

### 6. Porkbun

**ขั้นตอน:**
1. Login ที่ https://porkbun.com
2. ไปที่ **My Domains**
3. คลิก **DNS** ข้าง `funaging.studio`
4. คลิก **Add Record**
5. Type: **A**
6. Subdomain: **@**
7. Answer: **76.76.21.21**
8. TTL: **300**
9. คลิก **Add**
10. รอ 5-30 นาที

---

## วิธีตรวจสอบว่า DNS ตั้งค่าถูกต้อง

### ตรวจสอบด้วย Command:
```powershell
nslookup funaging.studio
```

ถ้าเห็น `76.76.21.21` = ตั้งค่าถูกต้อง

### ตรวจสอบใน Vercel:
```powershell
vercel domains inspect funaging.studio
```

ถ้าไม่เห็น warning = พร้อมใช้งาน

---

## หลังจากตั้งค่า DNS แล้ว

1. **รอ 5-30 นาที** สำหรับ DNS propagation
2. **ตรวจสอบ:**
   ```powershell
   vercel domains inspect funaging.studio
   ```
3. **Vercel จะส่ง email** เมื่อ domain พร้อมใช้งาน
4. **เว็บจะทำงานที่:**
   - https://funaging.studio
   - https://www.funaging.studio (auto-redirect)

---

## ถ้าไม่รู้ว่าซื้อ Domain จากที่ไหน

1. **ตรวจสอบ Email** - หา receipt หรือ confirmation email
2. **ตรวจสอบ Whois:**
   - ไปที่: https://whois.net
   - พิมพ์: `funaging.studio`
   - ดู "Registrar"
3. **ลอง login ที่ registrar หลัก:**
   - Namecheap
   - GoDaddy
   - Google Domains
   - Cloudflare

---

## สรุป

1. **หาว่าซื้อ Domain จากที่ไหน** (ตรวจสอบ email หรือ whois)
2. **Login เข้า Domain Registrar**
3. **ตั้งค่า A Record:** `@` → `76.76.21.21`
4. **รอ 5-30 นาที**
5. **ตรวจสอบ:** `vercel domains inspect funaging.studio`

