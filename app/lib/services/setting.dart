import 'package:app/core/api.dart';

class SettingService {
  final ApiClient api;

  SettingService(this.api);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await api.put("/me/password", {
      "password": currentPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    });
  }

  Future<void> changeEmail({required String newEmail}) async {
    await api.put("/me/email", {"email": newEmail});
  }

  Future<void> verifyNewEmail({
    required String uid,
    required String otp,
    String purpose = "change_email",
  }) async {
    await api.post("/auth/verify-otp", {
      "uid": uid,
      "otp": otp,
      "purpose": purpose,
    });
  }
}
