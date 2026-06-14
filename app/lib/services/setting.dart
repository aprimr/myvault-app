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

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final res = await api.post("/auth/forgot-password", {"email": email});
    return res.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String uid,
    required String otp,
    String purpose = "forgot_password",
  }) async {
    final res = await api.post("/auth/verify-otp", {
      "uid": uid,
      "otp": otp,
      "purpose": purpose,
    });
    return res.data["data"] as Map<String, dynamic>;
  }

  Future<void> setNewPassword({
    required String uid,
    required String otpId,
    required String newPassword,
  }) async {
    await api.post("/auth/set-new-password", {
      "uid": uid,
      "otp_id": otpId,
      "password": newPassword,
    });
  }
}
