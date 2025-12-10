from fastapi import APIRouter
router = APIRouter(prefix='/office', tags=['office'])

@router.get('/ping')
async def ping(): return {'module': 'office', 'status': 'ok'}
