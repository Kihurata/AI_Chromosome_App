class ApiConstants {
  // Thay thế bằng IP hoặc Domain con AI Server của bạn.
  // Ví dụ nếu bạn chạy FastAPI ở máy tính khác trong mạng LAN: 'http://192.168.1.100:8000/api'
  static const String aiServerBaseUrl = 'http://localhost:8000/api';

  // Thời gian chờ tối đa. Vì upload ảnh và chờ AI phân tích rất lâu nên ta set 30 giây
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
