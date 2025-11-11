// Simple JSON persistence service
import 'dart:convert';
import 'dart:io';

class PersistenceService {
  Future<void> saveToFile<T>(String filename, List<T> data) async {
    final file = File('data/$filename.json');
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<dynamic>> loadFromFile(String filename) async {
    try {
      final file = File('data/$filename.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents) as List<dynamic>;
      }
    } catch (e) {
      print('Error loading file: $e');
    }
    return [];
  }

  Future<void> initializeDataDirectory() async {
    final dir = Directory('data');
    if (!await dir.exists()) {
      await dir.create();
    }
  }
}
