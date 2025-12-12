# Cloudflare Deployment Setup (One-Time)

1. Login: https://dash.cloudflare.com
2. เลือกโดเมน funaging.club
3. เข้าเมนู: Workers & Pages → Pages → Create Project
4. เลือก Connect to GitHub
5. เลือก Repo: Cursor-Project
6. Build command:
   npm run build
7. Output directory:
   dist
8. Framework: None (Vite)
9. ตั้ง Secrets:
   CF_API_TOKEN
   CF_ACCOUNT_ID
   (สร้างใน Cloudflare → API Tokens)

หลังจากนั้นทุกครั้งที่ push โค้ดขึ้น branch main จะ deploy อัตโนมัติทันที











