-- ==========================================================
-- FUNAGING.CLUB - SUPABASE AUTH / PROFILE FIX (v10 TEMPLATE)
-- ปรับอีเมลและ UUID ตามของจริงก่อนรัน
-- ==========================================================

-- ตรวจสอบ user ปัจจุบัน (Admin / Staff)
-- ปรับ email ให้ตรงกับระบบจริงก่อนรัน SELECT นี้
-- SELECT id, email FROM auth.users
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- ถ้า Staff ใช้ UUID เดียวกับ Admin:
--   1) สร้าง Staff user ใหม่จากหน้า Auth ของ Supabase (แนะนำใช้ Dashboard)
--   2) เอา UUID ใหม่ของ Staff มาแทน 'NEW-STAFF-UUID-HERE' ด้านล่าง

-- ตัวอย่างการผูก profiles กับ UUID ใหม่ (เปลี่ยนชื่อ table/column ให้ตรงโปรเจกต์จริง):

-- UPDATE profiles
--   SET user_id = 'NEW-STAFF-UUID-HERE', role = 'STAFF'
--   WHERE email = 'akemontree@gmail.com';

-- UPDATE profiles
--   SET role = 'ADMIN'
--   WHERE email = 'sanookagingstudio@gmail.com';

-- ตรวจอีกครั้ง
-- SELECT user_id, email, role FROM profiles
--   WHERE email IN ('sanookagingstudio@gmail.com','akemontree@gmail.com');

-- NOTE:
--   • ให้ copy ทีละคำสั่งไปวางใน Supabase SQL Editor แล้วรันด้วยความระมัดระวัง
--   • ONE PACK ไม่เก็บ SERVICE ROLE KEY เพื่อความปลอดภัยของระบบ
