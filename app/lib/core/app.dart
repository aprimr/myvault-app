import 'package:app/core/api.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/core/storage.dart';
import 'package:app/services/auth.dart';

class App {
  static final SecureStorage storage = SecureStorage();

  static ApiClient get api => apiClient;

  static final AuthService authService = AuthService(api, storage);
}
