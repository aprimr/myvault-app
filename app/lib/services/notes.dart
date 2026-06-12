import 'package:app/core/api.dart';

class NoteService {
  final ApiClient api;

  NoteService(this.api);

  Future<List<dynamic>> getAllNotes() async {
    final res = await api.get("/notes/");
    return res.data["data"] ?? [];
  }

  Future<Map<String, dynamic>> getNoteById(String id) async {
    final res = await api.get("/notes/$id");
    return res.data["data"];
  }

  Future<void> addNote({required String title, required String content}) async {
    final body = {"title": title, "content": content};

    await api.post("/notes/", body);
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final body = {"title": title, "content": content};

    await api.patch("/notes/$id", body);
  }

  Future<void> deleteNote(String id) async {
    await api.delete("/notes/$id");
  }
}
