from fastapi import HTTPException, status
from typing import Optional, Dict
import re
from ..firebase_admin import db

class ScannerService:
    @staticmethod
    async def process_qr_code(qr_data: str) -> Dict:
        """Process QR code data and extract medicine information"""
        try:
            # Expected QR code format: JSON or specific format with medicine details
            # Example: {"name":"Aspirin","expiry":"2024-12-31","manufacturer":"Bayer"}
            
            # Basic validation of QR data format
            if not qr_data:
                raise ValueError("Empty QR code data")
                
            # Here you would implement the actual QR code parsing logic
            # This is a simplified example
            medicine_data = {
                "name": qr_data.get("name"),
                "expiration_date": qr_data.get("expiry"),
                "manufacturer": qr_data.get("manufacturer")
            }
            
            if not all(medicine_data.values()):
                raise ValueError("Invalid QR code format")
                
            return medicine_data
            
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="QR code not recognized. Check the packaging or enter data manually."
            )
    
    @staticmethod
    async def process_barcode(barcode: str) -> Optional[Dict]:
        """Process barcode and retrieve medicine information"""
        try:
            # Validate barcode format (EAN-13, UPC-A, Code 128)
            if not re.match(r'^[0-9]{12,13}$', barcode):  # Simple EAN/UPC validation
                raise ValueError("Invalid barcode format")
            
            # First check local database
            medicine_ref = db.collection('medicine_catalog').document(barcode)
            medicine = medicine_ref.get()
            
            if medicine.exists:
                return medicine.to_dict()
            
            # If not found locally, query external API
            # This is where you would implement the external API call
            # For example:
            # response = await external_api_client.get_medicine_info(barcode)
            # if response.is_success:
            #     return response.data
            
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Barcode not recognized. Check the packaging or enter data manually."
            )
            
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Error processing barcode"
            ) 