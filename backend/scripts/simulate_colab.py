import os
import sys
import time
import argparse
import requests
import firebase_admin
from firebase_admin import credentials, firestore, storage

def init_firebase():
    """Khởi tạo Firebase Admin SDK với file service account cục bộ."""
    # Tìm file credentials ở thư mục backend gốc
    backend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    cred_path = os.path.join(backend_dir, "serviceAccountKey.json")
    
    if not os.path.exists(cred_path):
        print(f"❌ LỖI: Không tìm thấy file {cred_path}!")
        return None, None
        
    print(f"✅ Đã tìm thấy file credentials tại: {cred_path}")
    
    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'chromosome-app-d6167.firebasestorage.app'
        })
        
    return firestore.client(), storage.bucket()

def check_ngrok_status(ai_url):
    """Kiểm tra xem tunnel Ngrok có đang hoạt động không."""
    print(f"\n🔍 Kiểm tra kết nối tới: {ai_url}")
    try:
        response = requests.get(ai_url, headers={"ngrok-skip-browser-warning": "true"})
        if response.status_code == 404 and "ERR_NGROK" in response.text:
            print("❌ LỖI: Tunnel Ngrok đã chết hoặc bị offline. Bạn cần chạy lại Ngrok bên phía Server.")
            return False
        else:
            print("✅ Tunnel Ngrok đang online. Đường dẫn sẵn sàng.")
            return True
    except Exception as e:
        print(f"❌ Không thể kết nối tới URL này: {e}")
        return False

def simulate_colab_flow(image_path):
    """Mô phỏng lại luồng làm việc của file Colab: Upload ảnh -> Lấy AI config -> Gọi AI -> In kết quả."""
    print("🚀 BẮT ĐẦU MÔ PHỎNG FLUTTER APP & BACKEND LOCAL (TỪ COLAB)")
    
    db, bucket = init_firebase()
    if not db or not bucket:
        return
        
    if not os.path.exists(image_path):
        print(f"❌ LỖI: Không tìm thấy ảnh tại: {image_path}")
        return
        
    test_order_id = f"test_order_sim_{int(time.time())}"
    print(f"\n⏳ [Flutter Sim] Đang upload ảnh lên Firebase Storage...")
    
    blob_path = f"metaphase_images/{test_order_id}.jpg"
    blob = bucket.blob(blob_path)
    
    try:
        # Bước 1: Upload ảnh (Mô phỏng Flutter App)
        blob.upload_from_filename(image_path, content_type='image/jpeg')
        blob.make_public()
        image_url = blob.public_url
        print(f"✅ [Flutter Sim] Upload thành công! Link ảnh: {image_url}")
        
        # Bước 2: Lấy config URL từ Firestore
        doc = db.collection("system_configs").document("ai_server").get()
        if doc.exists:
            ai_url = doc.to_dict().get("url", "").strip().rstrip('/')
            
            # Bước 3: Kiểm tra Ngrok
            if not check_ngrok_status(ai_url):
                return
            
            # Bước 4: Gửi POST request tới AI Server
            full_api_url = f"{ai_url}/analyze"
            print(f"\n✅ [Backend Sim] Gọi AI Server tại: {full_api_url}")
            
            API_KEY = "MY_SECRET_AI_KEY_2026"
            headers = {
                "X-API-Key": API_KEY,
                "ngrok-skip-browser-warning": "true",
                "Content-Type": "application/json"
            }
            # Dựng storage_path giả lập để test
            import urllib.parse
            path = urllib.parse.urlparse(image_url).path
            filename = path.split('%2F')[-1] if '%2F' in path else "test_image.jpg"
            storage_path = f"test_orders/{test_order_id}/ai_predict/{filename}"

            payload = {
                "image_url": image_url, 
                "test_order_id": test_order_id,
                "storage_path": storage_path
            }
            
            print("⏳ Đang chờ kết quả từ AI Server...")
            response = requests.post(full_api_url, json=payload, headers=headers)
            
            # Bước 5: In kết quả
            if response.status_code == 200:
                result = response.json()
                print(f"🎉 [Backend Sim] Nhận kết quả thành công!")
                
                zip_url = result.get('crops_zip_url')
                if zip_url:
                    print(f"📦 [Link Tải] File ZIP chứa các NST đã cắt: {zip_url}")
                    
                chromosomes = result.get('chromosomes', [])
                print(f"🧬 Tìm thấy {len(chromosomes)} nhiễm sắc thể.")
            else:
                print(f"❌ AI Server error: {response.status_code}")
                print(f"Nội dung lỗi: {response.text}")
        else:
            print("❌ LỖI: Không tìm thấy config 'ai_server' trong Firestore.")
    except Exception as e:
        print(f"❌ LỖI: Thao tác thất bại: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script mô phỏng Colab để test AI Pipeline")
    parser.add_argument("--image", required=True, help="Đường dẫn đến file ảnh NST cần phân tích")
    args = parser.parse_args()
    
    simulate_colab_flow(args.image)
