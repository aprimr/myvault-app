import 'package:app/core/api.dart';
import 'package:dio/dio.dart';

class ProfileService {
  final ApiClient api;

  ProfileService(this.api);

  Future<Map<String, dynamic>> getProfile() async {
    final res = await api.get("/me");
    return res.data["data"];
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String username,
  }) async {
    final res = await api.put("/me", {"name": name, "username": username});
    return res.data["data"];
  }

  Future<String> updatePhoto({
    required String filePath,
    required String currentProfileUrl,
  }) async {
    final formData = FormData.fromMap({
      "profilepic": await MultipartFile.fromFile(filePath),
      "currprofileurl": currentProfileUrl,
    });

    final res = await api.putForm("/me/photo", formData);
    return res.data["data"] as String;
  }

  Future<void> deletePhoto() async {
    await api.delete("/me/photo");
  }
}
