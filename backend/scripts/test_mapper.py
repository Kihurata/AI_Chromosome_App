import os
import json
import sys
from pprint import pprint

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.data_mapper import map_labelme_to_chromosomes

def test_mapper():
    print("--- Testing Data Mapper ---")
    
    # Load sample JSON
    sample_path = "211025-003C_32_1_835_213_0.523.json"
    if not os.path.exists(sample_path):
        # Try finding it relative to project root if running from elsewhere
        sample_path = os.path.join(os.path.dirname(__file__), "../../", sample_path)

    with open(sample_path, 'r') as f:
        ai_result = json.load(f)
    
    order_id = "test_order_123"
    image_id = "test_image_456"
    
    chromosomes = map_labelme_to_chromosomes(ai_result, order_id, image_id)
    
    print(f"Mapped {len(chromosomes)} chromosomes.")
    
    if chromosomes:
        print("\nExample Chromosome Document (First one):")
        # Pretty print the first one, but truncate polygon for readability
        example = chromosomes[0].copy()
        example['polygon'] = f"[{len(example['polygon'])} points...]"
        pprint(example)
        
        # Verify fields
        assert example['orderId'] == order_id
        assert example['imageId'] == image_id
        assert 'coordinates' in example
        assert 'bbox' in example
        assert 'label' in example
        print("\nSUCCESS: All expected fields are present.")

if __name__ == "__main__":
    test_mapper()
