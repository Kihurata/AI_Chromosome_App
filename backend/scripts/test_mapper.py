import os
import json
import sys
from pprint import pprint
from datetime import datetime

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.data_mapper import map_labelme_to_chromosomes

def test_mapper():
    print("--- [TEST] Data Mapper Verification ---")
    
    # 1. Create Mock AI Result
    mock_ai_result = {
        "shapes": [
            {
                "label": "1",
                "points": [
                    [100.5, 200.2],
                    [150.8, 200.2],
                    [150.8, 300.7],
                    [100.5, 300.7]
                ]
            }
        ]
    }
    
    order_id = "order_999"
    image_id = "img_888"
    
    # 2. Map
    chromosomes = map_labelme_to_chromosomes(mock_ai_result, order_id, image_id)
    
    print(f"Mapped {len(chromosomes)} chromosomes.")
    assert len(chromosomes) == 1
    
    c = chromosomes[0]
    
    # 3. Verify BBox Math
    # points: min_x=100.5, max_x=150.8, min_y=200.2, max_y=300.7
    expected_bbox = [100.5, 200.2, 150.8, 300.7]
    expected_w = round(150.8 - 100.5, 2)
    expected_h = round(300.7 - 200.2, 2)
    
    print(f"Verifying coordinates: BBox={c['bbox']}, W={c['coordinates']['w']}, H={c['coordinates']['h']}")
    
    assert c['bbox'] == expected_bbox
    assert c['coordinates']['x'] == 100.5
    assert c['coordinates']['y'] == 200.2
    assert c['coordinates']['w'] == expected_w
    assert c['coordinates']['h'] == expected_h
    
    # Verify flattened polygon
    assert len(c['polygon']) == 8 # 4 points * 2 coords
    assert c['polygon'][0] == 100.5
    assert c['polygon'][1] == 200.2
    
    # 4. Verify Metadata
    assert c['orderId'] == order_id
    assert c['imageId'] == image_id
    assert c['label'] == "1"
    assert c['status'] == "DETECTED"
    assert isinstance(c['createdAt'], datetime)
    
    print("\n[SUCCESS] Mapper logic is precise and spec-compliant.")

if __name__ == "__main__":
    test_mapper()
