from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from ..models.first_aid_kit import FirstAidKit, FirstAidKitCreate, FirstAidKitUser
from ..firebase_admin import db
from firebase_admin import auth
from datetime import datetime
from ..services.access_code_service import AccessCodeService

router = APIRouter(prefix="/first-aid-kits", tags=["first-aid-kits"])

async def get_current_user():
    # Implement authentication logic here
    pass

@router.post("/", response_model=FirstAidKit)
async def create_first_aid_kit(
    first_aid_kit: FirstAidKitCreate,
    current_user = Depends(get_current_user)
):
    try:
        kit_data = first_aid_kit.dict()
        kit_data["created_at"] = datetime.utcnow()
        kit_data["updated_at"] = kit_data["created_at"]
        kit_data["users"] = [{
            "user_id": current_user.id,
            "role": "administrator"
        }]
        
        # Create document in Firestore
        doc_ref = db.collection('first_aid_kits').document()
        kit_data["id"] = doc_ref.id
        doc_ref.set(kit_data)
        
        return FirstAidKit(**kit_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.get("/", response_model=List[FirstAidKit])
async def get_user_first_aid_kits(current_user = Depends(get_current_user)):
    try:
        # Query Firestore for first aid kits where user is a member
        kits_ref = db.collection('first_aid_kits')
        query = kits_ref.where('users', 'array_contains', {'user_id': current_user.id})
        kits = query.stream()
        
        return [FirstAidKit(**kit.to_dict()) for kit in kits]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/{kit_id}/users")
async def add_user_to_first_aid_kit(
    kit_id: str,
    user_data: FirstAidKitUser,
    current_user = Depends(get_current_user)
):
    try:
        # Verify current user is admin
        kit_ref = db.collection('first_aid_kits').document(kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        current_user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if current_user_role != "administrator":
            raise HTTPException(
                status_code=403,
                detail="Only administrators can add users"
            )
            
        # Add new user
        kit_ref.update({
            "users": firestore.ArrayUnion([user_data.dict()]),
            "updated_at": datetime.utcnow()
        })
        
        return {"message": "User added successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/{kit_id}/access-code")
async def create_access_code(
    kit_id: str,
    role: str,
    current_user: User = Depends(get_current_user)
):
    try:
        # Verify current user is admin
        kit_ref = db.collection('first_aid_kits').document(kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        current_user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if current_user_role != "administrator":
            raise HTTPException(
                status_code=403,
                detail="Only administrators can generate access codes"
            )
            
        # Generate access code
        code = await AccessCodeService.create_access_code(kit_id, role)
        
        return {"access_code": code}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/join/{access_code}")
async def join_first_aid_kit(
    access_code: str,
    current_user: User = Depends(get_current_user)
):
    try:
        # Validate access code
        code_data = await AccessCodeService.validate_access_code(access_code)
        if not code_data:
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired access code"
            )
            
        kit_id = code_data['first_aid_kit_id']
        role = code_data['role']
        
        # Add user to first aid kit
        kit_ref = db.collection('first_aid_kits').document(kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        
        # Check if user is already a member
        if any(user["user_id"] == current_user.id for user in kit_data["users"]):
            raise HTTPException(
                status_code=400,
                detail="You are already a member of this first aid kit"
            )
            
        # Add user with specified role
        kit_ref.update({
            "users": firestore.ArrayUnion([{
                "user_id": current_user.id,
                "role": role
            }]),
            "updated_at": datetime.utcnow()
        })
        
        # Delete used access code
        db.collection('access_codes').document(access_code).delete()
        
        return {"message": "Successfully joined first aid kit"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{kit_id}/users/{user_id}")
async def remove_user_from_first_aid_kit(
    kit_id: str,
    user_id: str,
    current_user: User = Depends(get_current_user)
):
    try:
        kit_ref = db.collection('first_aid_kits').document(kit_id)
        kit = kit_ref.get()
        
        if not kit.exists:
            raise HTTPException(status_code=404, detail="First aid kit not found")
            
        kit_data = kit.to_dict()
        
        # Check if current user is admin
        current_user_role = next(
            (user["role"] for user in kit_data["users"] 
             if user["user_id"] == current_user.id),
            None
        )
        
        if current_user_role != "administrator":
            raise HTTPException(
                status_code=403,
                detail="Only administrators can remove users"
            )
            
        # Remove user
        kit_ref.update({
            "users": firestore.ArrayRemove([{
                "user_id": user_id,
                "role": next(
                    (user["role"] for user in kit_data["users"] 
                     if user["user_id"] == user_id),
                    None
                )
            }]),
            "updated_at": datetime.utcnow()
        })
        
        return {"message": "User removed successfully"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        ) 