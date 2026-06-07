import 'package:app/core/api.dart';
import 'package:app/core/storage.dart';
import 'package:app/services/auth.dart';

class App {
  static final SecureStorage storage = SecureStorage();
  static final ApiClient api = ApiClient();

  static final AuthService authService = AuthService(api, storage);
}
