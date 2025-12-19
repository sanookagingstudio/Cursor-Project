Write-Host "RESTORE START"
Set-Location "D:\SanookAgingStudio\shadow project\sanook-master-v2-main"
git reset --hard HEAD
git clean -fd
git pull origin main --rebase
npm install
npm run build
git commit --allow-empty -m "RESTORE TRIGGER"
git push origin main
Write-Host "RESTORE COMPLETE"


























