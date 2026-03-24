import os
import firebase_admin
from firebase_admin import credentials

def init_firebase():
    """
    Initializes Firebase Admin SDK using service account key.
    """
    # Key located at the root of the backend folder or configured passing env variables
    key_path = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
    
    if not firebase_admin._apps:
        if os.path.exists(key_path):
            try:
                cred = credentials.Certificate(key_path)
                firebase_admin.initialize_app(cred)
                print("Firebase Admin initialized successfully.")
            except Exception as e:
                print(f"Failed to initialize Firebase Admin: {e}")
        else:
            print(f"Warning: Firebase Admin credentials not found at {key_path}")

# Call init_firebase when the module is imported
init_firebase()
