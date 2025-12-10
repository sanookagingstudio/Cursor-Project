cd 'D:\SanookAgingStudio\shadow project\sanook-master-v2-main\backend'
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
uvicorn app.new_main:app --reload
