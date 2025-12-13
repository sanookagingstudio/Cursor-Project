# FunAging.club — RESTORE MASTER GUIDE

Generated automatically by **ONEPACK v14 — Hybrid Backup & Restore Engine**
Timestamp: 25681212-072445

## 1. Concept

- ทุกครั้งที่รัน ONEPACK v14 ระบบจะสร้าง **snapshot tag** หนึ่งตัวเสมอ
- snapshot นี้สามารถใช้เป็นจุด restore ได้ทุกเมื่อ
- โดยปกติ tag จะมีรูปแบบ:

  - stable-v14-YYYYMMDD-HHmmss

## 2. Latest Snapshot Tag (From This Run)

- Latest tag from this run: stable-v14-25681212-072445

### Restore from this exact snapshot

``bash
# สร้าง branch ใหม่จาก snapshot แท็กนี้
git fetch --all --tags
git checkout tags/stable-v14-25681212-072445 -b restore-stable-v14-25681212-072445

# จากนั้นสามารถรันระบบตามปกติ เช่น
pwsh .\onepack_funaging_v13.ps1
``

## 3. Other Recent Snapshot Tags

Recent tags (max 10):
- stable-v14-25681212-072445
- stable-v14-25681212-072324
- stable-v13-25681212-001803
- v12-stable
- onepack-az-v5-25681210224303
- onepack-az-v4-25681210222124
- onepack-az-v3-25681210220731
- onepack-az-v2-25681210214807
- onepack-az-25681210213402
- onepack-az-25681210212700

## 4. Full Restore Procedure (Recommended)

1. ตรวจสอบให้แน่ใจว่าไม่มีงานค้างที่ยังไม่ backup:
   ``bash
   git status
   ``

2. เลือกแท็ก snapshot ที่ต้องการ (เช่น stable-v14-25681212-072445 หรือ stable อื่น ๆ)
3. สร้าง branch ใหม่จากแท็กนั้น:

   ``bash
   git fetch --all --tags
   git checkout tags/<TAG_NAME> -b restore-<TAG_NAME>
   ``

4. ตรวจสอบไฟล์สำคัญ:
   - backend/app/main.py
   - backend/app/new_main.py
   - backend/app/routes/*.py
   - backend/Dockerfile.backend
   - docker-compose.sas.yml
   - frontend/.env.local

5. รัน ONEPACK และ verifier ที่เหมาะสม:

   ``bash
   pwsh .\onepack_funaging_v13.ps1
   pwsh .\onepack_verifier_v13.ps1
   ``

6. เมื่อตรวจสอบว่าระบบกลับมาทำงานได้สมบูรณ์แล้ว:
   - สามารถ merge เข้ากับ branch หลัก (เช่น main)
   - หรือใช้ branch restore-* เป็นฐานในการพัฒนาต่อ

## 5. Notes

- ONEPACK v14 สร้าง snapshot ทั้ง **เมื่อมีการเปลี่ยนแปลงไฟล์สำคัญ** และ **เมื่อไม่มีการเปลี่ยนแปลง (tag-only)**
- ควร push tags ขึ้น GitHub เสมอ เพื่อความปลอดภัยของข้อมูล
- ถ้า snapshot หนึ่ง ๆ ใช้งานได้ดี แนะนำให้จดบันทึกในระบบหรือตั้งชื่อ tag เพิ่มเติมเช่น prod-stable-YYYYMMDD
