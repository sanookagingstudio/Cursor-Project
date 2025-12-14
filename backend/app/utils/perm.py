from fastapi import HTTPException
def require_admin(user):
    if user.get('role') != 'admin':
        raise HTTPException(status_code=403, detail='admin_only')

def require_staff_or_admin(user):
    if user.get('role') not in ['admin','staff']:
        raise HTTPException(status_code=403, detail='staff_or_admin_only')
