import os
import sys

# Add the parent directory to sys.path to import from 'app'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Set Firebase Key Path for local execution from root
os.environ["FIREBASE_KEY_PATH"] = "backend/serviceAccountKey.json"

from app.core import firebase  # This initializes Firebase SDK
from app.core.ai_config import get_ai_server_url

def test_config():
    print("--- Testing AI Config Fetcher ---")
    url = get_ai_server_url()
    
    if url:
        print(f"SUCCESS: AI Server URL found: {url}")
    else:
        print("FAILURE: Could not fetch AI Server URL.")

if __name__ == "__main__":
    test_config()
