import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  Future<void> clear() async {
    await _storage.delete(key: "token");
  }
}

class AppPin {
  final _storage = FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(key: 'app_pin', value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: "app_pin");
  }

  Future<void> clear() async {
    await _storage.delete(key: "app_pin");
  }
}
