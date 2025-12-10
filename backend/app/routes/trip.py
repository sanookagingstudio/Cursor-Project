from fastapi import APIRouter
router = APIRouter(prefix='/trip', tags=['trip'])

@router.get('/ping')
async def ping(): return {'module': 'trip', 'status': 'ok'}
