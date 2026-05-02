import logging
from typing import List, Dict, Any
from datetime import datetime

logger = logging.getLogger(__name__)

def map_labelme_to_chromosomes(ai_result: Dict[str, Any], order_id: str, image_id: str) -> List[Dict[str, Any]]:
    """
    Maps LabelMe JSON format to Firestore Chromosome documents.
    """
    shapes = ai_result.get("shapes", [])
    chromosomes = []

    for index, shape in enumerate(shapes):
        label = shape.get("label", "unknown")
        points = shape.get("points", [])
        
        if not points:
            continue

        # Calculate Bounding Box
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        
        min_x, max_x = min(xs), max(xs)
        min_y, max_y = min(ys), max(ys)
        
        width = max_x - min_x
        height = max_y - min_y

        # Construct Firestore document
        # We include both the new spec fields and the compatibility fields for existing frontend
        chromosome_doc = {
            "orderId": order_id,
            "imageId": image_id,
            "label": label,
            "index": index + 1,
            "isPaired": False,
            "status": "DETECTED",
            "createdAt": datetime.utcnow(),
            
            # New Spec Fields
            "bbox": [min_x, min_y, max_x, max_y],
            "polygon": points,
            
            # Compatibility Fields (for current frontend ChromosomeModel)
            "coordinates": {
                "x": float(min_x),
                "y": float(min_y),
                "w": float(width),
                "h": float(height)
            },
            "rotation": 0.0,
            "is_flipped": False
        }
        
        chromosomes.append(chromosome_doc)

    logger.info(f"Mapped {len(chromosomes)} chromosomes from AI result.")
    return chromosomes
