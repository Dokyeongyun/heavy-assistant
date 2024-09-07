import 'package:http/http.dart' as http;

class NetworkClient {
  final http.Client client;

  NetworkClient(this.client);

  Future<http.Response> get(String url, Map<String, String> headers) {
    return client.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> post(String url, Map<String, String> headers) {
    return client.post(Uri.parse(url), headers: headers);
  }
}
