# Jarvis Status Dashboard — FunAging.club

- Generated at: 2568-12-12 08:11:05
- Backend status: **HEALTHY**
- Docker engine: **running**
- Git branch: **backup-v12-stable**

---

## 1. Backend Health Check

Status: **HEALTHY**

Checked endpoints:

- GET /health
- GET /

If UNHEALTHY → ใช้ onepack_funaging_v16.ps1 เพื่อ auto-heal อีกครั้งได้เลย.

---

## 2. Docker Containers

Engine: **running**

`
sas_backend|Up 55 minutes|0.0.0.0:8000->8000/tcp, [::]:8000->8000/tcp
sas_db|Up 55 minutes|0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
jarvis-ecosystem-db-1|Up 55 minutes|5432/tcp
jarvis-ecosystem-n8n-1|Up 55 minutes|0.0.0.0:5680->5678/tcp, [::]:5680->5678/tcp
`

---

## 3. Git Summary

### Branch
`
backup-v12-stable
`

### Working Tree
`
dirty
 M RESTORE_MASTER.md ?? JARVIS_STATUS_DASHBOARD.md ?? onepack_funaging_v15.ps1 ?? onepack_funaging_v15B.ps1 ?? onepack_funaging_v16.ps1 ?? onepack_funaging_v17.ps1
`

### Latest Tags
`
stable-v14-25681212-072445
stable-v14-25681212-072324
stable-v13-25681212-001803
v12-stable
onepack-az-v5-25681210224303
onepack-az-v4-25681210222124
onepack-az-v3-25681210220731
onepack-az-v2-25681210214807
onepack-az-25681210213402
onepack-az-25681210212700
`

### Recent Commits
`
8ef44d0 [AUTO-SNAPSHOT][v14] FunAging backup before pipeline v14โ€“17 - 25681212-072445
39e49c6 [AUTO-SNAPSHOT][v14] FunAging backup before pipeline v14โ€“17 - 25681212-072324
910fe8f AUTO-BACKUP: v13 snapshot 25681212-001803
422a01f Backup: FunAging.club stable snapshot after ONEPACK SelfTest v12 (backend + db fully operational)
64db569 [ONEPACK-v8] Auto snapshot 2025-12-10T23:58:16
4816f3c [ONEPACK-v7] Auto snapshot 2025-12-10T23:42:33
83b213d [ONEPACK-v6] Auto snapshot 2025-12-10T23:35:30
332c5ff [ONEPACK-AZ-v5] Auto snapshot 2025-12-10T22:43:03
770e772 [ONEPACK-AZ-v4] Auto snapshot 2025-12-10T22:21:24
2e8cbcf [ONEPACK-AZ-v3] Auto snapshot 2025-12-10T22:07:30
`

---

## 4. Environment Files (Supabase / Backend / Frontend)

Detected:

`
.env
frontend/.env.local

`

---

## 5. Jarvis Recent Logs (v16 / v17 etc.)

`
### jarvis_v17_25681212-081105.log
2568-12-12 08:11:05  ================================================
2568-12-12 08:11:05  ONEPACK v17 — Jarvis Monitoring + Snapshot START
2568-12-12 08:11:05  ================================================
2568-12-12 08:11:05  [INFO] SummaryOnly flag set — skipping heal step.
2568-12-12 08:11:05  [HEALTH] /health OK → {"status":"ok"}
2568-12-12 08:11:05  [HEALTH] / OK → {"status":"ok","service":"FunAging SAS Backend"}
2568-12-12 08:11:05  [BACKUP] SummaryOnly mode — no backup executed.

### jarvis_v17_25681212-081052.log
2568-12-12 08:10:53  [HEALTH] / OK → {"status":"ok","service":"FunAging SAS Backend"}
2568-12-12 08:10:53  [BACKUP] SummaryOnly mode — no backup executed.
2568-12-12 08:10:53  [HEALTH] /health OK → {"status":"ok"}
2568-12-12 08:10:53  [HEALTH] / OK → {"status":"ok","service":"FunAging SAS Backend"}
2568-12-12 08:10:53  [DASHBOARD] JARVIS_STATUS_DASHBOARD.md generated.
2568-12-12 08:10:53  ================================================
2568-12-12 08:10:53  ONEPACK v17 COMPLETE — Dashboard: D:\SanookAgingStudio\shadow project\sanook-master-v2-main\JARVIS_STATUS_DASHBOARD.md
2568-12-12 08:10:53  Log file: D:\SanookAgingStudio\shadow project\sanook-master-v2-main\.jarvis\jarvis_v17_25681212-081052.log
2568-12-12 08:10:53  ================================================
2568-12-12 08:10:53  

### jarvis_v16_25681212-080333.log
2568-12-12 08:03:33  [INFO] Running ONEPACK v13 verifier...
2568-12-12 08:03:34  [INFO] Verifier v13 completed.
2568-12-12 08:03:34  [HEALTH] /health OK → {"status":"ok"}
2568-12-12 08:03:34  [HEALTH] / OK → {"status":"ok","service":"FunAging SAS Backend"}
2568-12-12 08:03:34  [STATUS] System already healthy — no heal required.
2568-12-12 08:03:34  [BACKUP] SkipBackup flag set — auto-backup disabled for this run.
2568-12-12 08:03:34  ================================================
2568-12-12 08:03:34  ONEPACK v16 COMPLETE — see log file: D:\SanookAgingStudio\shadow project\sanook-master-v2-main\.jarvis\jarvis_v16_25681212-080333.log
2568-12-12 08:03:34  ================================================
2568-12-12 08:03:34
`

---

## 6. Quick Commands (Reference)

- Run self-heal:
  - pwsh .\onepack_funaging_v16.ps1

- Run version manager (non-interactive):
  - Show inventory: pwsh .\onepack_funaging_v15B.ps1 -ShowInventory
  - Backup now:     pwsh .\onepack_funaging_v15B.ps1 -Backup

- Full check + dashboard:
  - pwsh .\onepack_funaging_v17.ps1

---
