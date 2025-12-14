import os, psycopg2
from fastapi import APIRouter, Request
from app.routes.auth import verify
from app.utils.perm import require_admin, require_staff_or_admin

router = APIRouter(prefix='/members', tags=['members'])

def db():
    return psycopg2.connect(
        host=os.getenv('POSTGRES_HOST','sas_db'),
        dbname=os.getenv('POSTGRES_DB','sas'),
        user=os.getenv('POSTGRES_USER','sas'),
        password=os.getenv('POSTGRES_PASSWORD','sas'),
    )

@router.get('/')
def list_members(request: Request):
    user = verify(request.cookies.get('fa_session'))
    require_staff_or_admin(user)
    c=db(); cur=c.cursor()
    cur.execute('select id,name from members order by id')
    rows=cur.fetchall(); cur.close(); c.close()
    return rows

@router.post('/')
def create_member(data: dict, request: Request):
    user = verify(request.cookies.get('fa_session'))
    require_admin(user)
    c=db(); cur=c.cursor()
    cur.execute('insert into members(name) values(%s)',(data['name'],))
    c.commit(); cur.close(); c.close()
    return {'ok':True}

@router.delete('/{id}')
def delete_member(id:int, request: Request):
    user = verify(request.cookies.get('fa_session'))
    require_admin(user)
    c=db(); cur=c.cursor()
    cur.execute('delete from members where id=%s',(id,))
    c.commit(); cur.close(); c.close()
    return {'ok':True}
