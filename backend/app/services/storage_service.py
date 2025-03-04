from typing import Dict, List
from ..models.medicine import Medicine

class StorageService:
    # Standard storage conditions and their requirements
    STORAGE_CONDITIONS = {
        "room_temperature": {
            "temp_min": 15,
            "temp_max": 25,
            "humidity_max": 60,
            "description": "Store at room temperature (15-25°C)",
            "recommendations": [
                "Keep in a cool, dry place",
                "Avoid direct sunlight",
                "Keep away from heat sources"
            ]
        },
        "refrigerated": {
            "temp_min": 2,
            "temp_max": 8,
            "humidity_max": 65,
            "description": "Store in refrigerator (2-8°C)",
            "recommendations": [
                "Keep refrigerated",
                "Do not freeze",
                "Keep in original packaging"
            ]
        },
        "cool": {
            "temp_min": 8,
            "temp_max": 15,
            "humidity_max": 65,
            "description": "Store in a cool place (8-15°C)",
            "recommendations": [
                "Keep in a cool place",
                "Protect from light",
                "Keep container tightly closed"
            ]
        }
    }

    @staticmethod
    def get_storage_recommendations(medicine: Medicine) -> Dict:
        """Get storage recommendations for a medicine"""
        try:
            form = medicine.form.lower()
            storage_type = "room_temperature"  # default

            # Determine storage type based on medicine form
            if form in ["liquid", "suspension", "syrup"]:
                storage_type = "cool"
            elif form in ["injection", "vaccine"]:
                storage_type = "refrigerated"

            # Get standard conditions
            conditions = StorageService.STORAGE_CONDITIONS[storage_type]

            # Add form-specific recommendations
            form_recommendations = StorageService.get_form_specific_recommendations(form)
            
            return {
                "storage_type": storage_type,
                "conditions": conditions,
                "form_specific_recommendations": form_recommendations
            }

        except Exception as e:
            print(f"Error getting storage recommendations: {str(e)}")
            return None

    @staticmethod
    def get_form_specific_recommendations(form: str) -> List[str]:
        """Get recommendations specific to medicine form"""
        recommendations = {
            "tablet": [
                "Keep in original container",
                "Protect from moisture",
                "Keep container tightly closed"
            ],
            "capsule": [
                "Keep in original container",
                "Protect from moisture",
                "Store in a dry place"
            ],
            "liquid": [
                "Do not freeze",
                "Shake well before use",
                "Keep bottle tightly closed"
            ],
            "cream": [
                "Do not refrigerate unless specified",
                "Keep tube properly closed",
                "Store at room temperature"
            ],
            "injection": [
                "Keep in original packaging",
                "Protect from light",
                "Check expiration date before use"
            ]
        }
        
        return recommendations.get(form.lower(), [
            "Keep in original container",
            "Follow package instructions",
            "Store safely away from children"
        ]) 