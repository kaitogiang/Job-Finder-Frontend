class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  HttpException.fromJson(Map<String, dynamic> json)
      : message = json['message'] ?? 'Unknown error occurred';

  @override
  String toString() {
    return message;
  }
}
