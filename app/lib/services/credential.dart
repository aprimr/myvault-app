import 'package:app/core/api.dart';

class CredentialService {
  final ApiClient api;

  CredentialService(this.api);

  Future<List<dynamic>> getAllCredentials() async {
    final res = await api.get("/credential/");
    return res.data["data"] ?? [];
  }

  Future<Map<String, dynamic>> getCredentialById(String id) async {
    final res = await api.get("/credential/$id");
    return res.data["data"];
  }

  Future<void> addCredential({
    required String title,
    required String emailOrUsername,
    required String password,
    String? loginUrl,
    String? description,
  }) async {
    final body = {
      "title": title,
      "email_or_username": emailOrUsername,
      "password": password,
      if (loginUrl != null && loginUrl.isNotEmpty) "login_url": loginUrl,
      if (description != null && description.isNotEmpty)
        "description": description,
    };

    final res = await api.post("/credential/", body);
    return res.data["data"];
  }

  Future<void> deleteCredential(String id) async {
    await api.delete("/credential/$id");
  }
}
