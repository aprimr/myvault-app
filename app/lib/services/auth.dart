import 'package:app/core/api.dart';
import 'package:app/core/storage.dart';

class AuthService {
  final ApiClient api;
  final SecureStorage storage;

  AuthService(this.api, this.storage);

  Future<void> login(String email, String password) async {
    final res = await api.post("/auth/login", {
      "email": email,
      "password": password,
    });

    final token = res.data["data"]["token"];
    await storage.saveToken(token);
  }

  Future<void> signup(String name, String email, String password) async {
    await api.post('/auth/signup', {
      "name": name,
      "email": email,
      "password": password,
    });
  }

  Future<void> logout() async {
    await storage.clear();
  }
}
