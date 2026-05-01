from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import cv2
import numpy as np
import httpx
import uuid
# from firebase_admin import storage # Used for real Firebase storage

router = APIRouter()

class Point2D(BaseModel):
    x: float
    y: float

class PolygonRequest(BaseModel):
    id: str
    points: List[Point2D]

class SliceRequest(BaseModel):
    image_url: str
    polygons: List[PolygonRequest]

class SliceResponse(BaseModel):
    id: str
    url: str

@router.post("/slice", response_model=List[SliceResponse])
async def slice_image(request: SliceRequest):
    try:
        # 1. Fetch image from URL
        async with httpx.AsyncClient() as client:
            response = await client.get(request.image_url)
            if response.status_code != 200:
                raise HTTPException(status_code=400, detail="Failed to download image")
            
        # Decode image using OpenCV
        image_array = np.frombuffer(response.content, np.uint8)
        img = cv2.imdecode(image_array, cv2.IMREAD_UNCHANGED)
        
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image format")

        results = []
        
        # 2. Process each polygon
        for poly in request.polygons:
            if len(poly.points) < 3:
                continue
                
            # Convert points to numpy array
            pts = np.array([[p.x, p.y] for p in poly.points], np.int32)
            pts = pts.reshape((-1, 1, 2))
            
            # Create a mask
            mask = np.zeros(img.shape[:2], dtype=np.uint8)
            cv2.fillPoly(mask, [pts], 255)
            
            # Apply mask to image
            masked_img = cv2.bitwise_and(img, img, mask=mask)
            
            # Add alpha channel if not present
            if masked_img.shape[2] == 3:
                b, g, r = cv2.split(masked_img)
                alpha = mask
                masked_img = cv2.merge([b, g, r, alpha])
            else:
                masked_img[:, :, 3] = mask
                
            # Crop to bounding box
            x, y, w, h = cv2.boundingRect(pts)
            cropped = masked_img[y:y+h, x:x+w]
            
            # Convert to PNG buffer
            success, buffer = cv2.imencode('.png', cropped)
            if not success:
                continue
                
            # 3. Upload to Firebase Storage (Mocked for MVP)
            # bucket = storage.bucket()
            # blob = bucket.blob(f"chromosomes/{uuid.uuid4()}.png")
            # blob.upload_from_string(buffer.tobytes(), content_type="image/png")
            # blob.make_public()
            # url = blob.public_url
            
            # Mock URL
            mock_url = f"https://mock-storage.com/chromosomes/{poly.id}.png"
            
            results.append(SliceResponse(id=poly.id, url=mock_url))
            
        return results
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
