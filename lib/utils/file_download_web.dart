import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> downloadFile(String jsonString, String filename) async {
  try {
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    return 'web_download'; // 返回特殊标识符表示成功
  } catch (e) {
    return null;
  }
}