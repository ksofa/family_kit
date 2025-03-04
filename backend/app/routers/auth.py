from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from ..models.user import UserCreate, User
from ..middleware.auth import get_current_user
from firebase_admin import auth
from ..firebase_admin import db

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=User)
async def register_user(user: UserCreate):
    try:
        # Create user in Firebase Auth
        user_record = auth.create_user(
            email=user.email,
            password=user.password,
            display_name=f"{user.first_name} {user.last_name}"
        )
        
        # Store additional user data in Firestore
        user_data = user.dict(exclude={'password'})
        user_data['id'] = user_record.uid
        
        db.collection('users').document(user_record.uid).set(user_data)
        
        return User(**user_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/me", response_model=User)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user 