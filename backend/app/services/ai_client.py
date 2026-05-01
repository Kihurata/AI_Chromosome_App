import httpx
import logging
from typing import Dict, Any, Optional
from app.core.ai_config import get_ai_server_url

logger = logging.getLogger(__name__)

class AIClient:
    def __init__(self, timeout: float = 120.0):
        self.timeout = timeout
        self.headers = {
            "ngrok-skip-browser-warning": "true",
            "Content-Type": "application/json"
        }

    async def analyze_image(self, image_url: str) -> Optional[Dict[str, Any]]:
        """
        Sends image_url to AI Server and receives analysis results.
        """
        api_url = get_ai_server_url()
        if not api_url:
            logger.error("AI Server URL is not configured.")
            return None

        # Ensure endpoint is correctly formatted
        endpoint = f"{api_url.rstrip('/')}/analyze"
        
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            try:
                logger.info(f"Calling AI Server at: {endpoint}")
                response = await client.post(
                    endpoint,
                    json={"image_url": image_url},
                    headers=self.headers
                )
                
                response.raise_for_status()
                logger.info("AI Server responded successfully.")
                return response.json()
                
            except httpx.HTTPStatusError as e:
                logger.error(f"AI Server returned error status: {e.response.status_code}")
            except httpx.TimeoutException:
                logger.error(f"AI Server request timed out after {self.timeout}s")
            except Exception as e:
                logger.error(f"Unexpected error calling AI Server: {e}")
                
        return None
