import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'api_constants.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.aiServerBaseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          //'X-API-Key': 'your-api-key',
        },
      ),
    );
    // 2. Lắp thêm "Đồng hồ đo" (Interceptor)
    // Thằng này sẽ tự động in ra Terminal mọi thứ: bạn gửi gì đi, server AI trả về cái gì, lỗi số mấy.
    // Cực kỳ hữu ích khi debug model AI!
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
      ),
    );
    return dio;
  }
}
