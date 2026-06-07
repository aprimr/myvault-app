import 'package:app/core/api.dart';
import 'package:app/core/constants.dart';
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

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final res = await api.post('/auth/signup', {
      "name": name,
      "email": email,
      "password": password,
    });

    return res.data;
  }

  Future<void> verifyAccount(String uid, String otp) async {
    await api.post('/auth/verify-otp', {
      "uid": uid,
      "otp": otp,
      "purpose": Constants.otpPurposeVerifyEmail,
    });
  }

  Future<void> logout() async {
    await storage.clear();
  }
}
