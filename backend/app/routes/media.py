from fastapi import APIRouter
router = APIRouter(prefix='/media', tags=['media'])

@router.get('/ping')
async def ping(): return {'module': 'media', 'status': 'ok'}
