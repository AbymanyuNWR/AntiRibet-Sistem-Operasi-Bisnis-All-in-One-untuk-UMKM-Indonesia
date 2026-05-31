import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Baca token dari secure storage (prioritas) atau memori
          final storedToken = await secureStorage.read(key: 'auth_token');
          final token = storedToken ?? AuthService.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Hapus token lama dan bersihkan sesi
            await secureStorage.delete(key: 'auth_token');
            AuthService.logout();
            // Sinyal ke router untuk redirect ke login
            AuthService.onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
