import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class WebService {
  Future<void> downloadFile(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print('Error in web download service: $response');
      }
    } catch (error) {
      print('Error in web download service: $error');
    }
  }
}