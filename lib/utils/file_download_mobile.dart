import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> downloadFile(String jsonString, String filename) async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$filename';
    final File file = File(filePath);
    await file.writeAsString(jsonString);
    return filePath;
  } catch (e) {
    return null;
  }
}