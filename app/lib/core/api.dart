import 'package:app/core/storage.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.100.30:8000/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  final storage = SecureStorage();

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String path) => dio.get(path);
  Future<Response> post(String path, dynamic data) =>
      dio.post(path, data: data);
  Future<Response> put(String path, dynamic data) => dio.put(path, data: data);
  Future<Response> delete(String path) => dio.delete(path);
}
