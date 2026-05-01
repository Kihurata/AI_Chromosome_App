import os
import sys
import asyncio

# Add the parent directory to sys.path to import from 'app'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Set Firebase Key Path for local execution from root
os.environ["FIREBASE_KEY_PATH"] = "backend/serviceAccountKey.json"

from app.core import firebase  # This initializes Firebase SDK
from app.services.ai_client import AIClient
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

async def test_ai_client():
    print("--- Testing AI Client Proxy ---")
    client = AIClient(timeout=10.0) # Short timeout for test
    
    # Use a dummy image URL
    test_image_url = "https://firebasestorage.googleapis.com/.../test.jpg"
    
    print(f"Attempting to call AI Server for image: {test_image_url}")
    result = await client.analyze_image(test_image_url)
    
    if result:
        print(f"SUCCESS: Received result from AI Server: {result}")
    else:
        print("INFO: AI Client call failed as expected (Mock URL may not be reachable), but check logs above for the connection attempt.")

if __name__ == "__main__":
    asyncio.run(test_ai_client())
