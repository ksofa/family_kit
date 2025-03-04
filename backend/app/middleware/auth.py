from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth
from ..models.user import User

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> User:
    try:
        # Verify Firebase token
        token = credentials.credentials
        decoded_token = auth.verify_id_token(token)
        
        # Get user from Firebase
        user_record = auth.get_user(decoded_token['uid'])
        
        # Convert to our User model
        user = User(
            id=user_record.uid,
            email=user_record.email,
            first_name=user_record.display_name.split()[0] if user_record.display_name else "",
            last_name=user_record.display_name.split()[1] if user_record.display_name and len(user_record.display_name.split()) > 1 else "",
            avatar_url=user_record.photo_url
        )
        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        ) 