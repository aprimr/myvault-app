import 'package:app/core/api.dart';
import 'package:dio/dio.dart';

class DocumentService {
  final ApiClient api;

  DocumentService(this.api);

  Future<List<dynamic>> getAllDocuments() async {
    final res = await api.get("/document/");
    return res.data["data"] ?? [];
  }

  Future<Map<String, dynamic>> getDocumentById(String id) async {
    final res = await api.get("/document/$id");
    return res.data["data"];
  }

  Future<void> addDocument({
    required String filePath,
    required String title,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
      "title": title,
      if (description != null && description.isNotEmpty)
        "description": description,
    });

    await api.postForm("/document/", formData);
  }

  Future<void> deleteDocument(String id) async {
    await api.delete("/document/$id");
  }
}
