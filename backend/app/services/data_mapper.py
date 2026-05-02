import logging
from typing import List, Dict, Any
from datetime import datetime, timezone

logger = logging.getLogger(__name__)

def map_labelme_to_chromosomes(ai_result: Dict[str, Any], order_id: str, image_id: str) -> List[Dict[str, Any]]:
    """
    Maps LabelMe JSON format to Firestore Chromosome documents.
    Handles polygon-to-bounding-box transformation and ensures compatibility
    with both the new specification and existing frontend models.
    """
    shapes = ai_result.get("shapes", [])
    chromosomes = []

    if not shapes:
        logger.warning(f"AI result for image {image_id} contains no shapes.")
        return []

    for index, shape in enumerate(shapes):
        label = str(shape.get("label", "unknown")).strip()
        points = shape.get("points", [])
        
        if not points or len(points) < 3:
            logger.warning(f"Skipping shape {index} in image {image_id}: Invalid points list.")
            continue

        # 1. Calculate Bounding Box (Min/Max approach)
        try:
            xs = [float(p[0]) for p in points]
            ys = [float(p[1]) for p in points]
        except (ValueError, IndexError) as e:
            logger.error(f"Error parsing coordinates for shape {index}: {e}")
            continue
            
        min_x, max_x = min(xs), max(xs)
        min_y, max_y = min(ys), max(ys)
        
        width = max_x - min_x
        height = max_y - min_y

        # 2. Construct Firestore document
        # Note: 'createdAt' should use timezone-aware datetime for consistent serialization
        chromosome_doc = {
            "orderId": order_id,
            "imageId": image_id,
            "label": label,
            "index": index + 1,
            "isPaired": False,
            "status": "DETECTED",
            "createdAt": datetime.now(timezone.utc),
            
            # New Spec Fields (Array [x1, y1, x2, y2])
            "bbox": [round(min_x, 2), round(min_y, 2), round(max_x, 2), round(max_y, 2)],
            "polygon": [coord for p in points for coord in (round(float(p[0]), 2), round(float(p[1]), 2))],
            
            # Compatibility Fields (for current Flutter ChromosomeModel)
            "coordinates": {
                "x": round(float(min_x), 2),
                "y": round(float(min_y), 2),
                "w": round(float(width), 2),
                "h": round(float(height), 2)
            },
            "rotation": 0.0,
            "is_flipped": False
        }
        
        chromosomes.append(chromosome_doc)

    logger.info(f"Successfully mapped {len(chromosomes)} chromosomes from AI result for image {image_id}.")
    return chromosomes
