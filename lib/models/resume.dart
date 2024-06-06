class Resume {
  final String fileName;
  final String url;
  final DateTime uploadedDate;

  Resume({
    required this.fileName,
    required this.url,
    required this.uploadedDate,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      fileName: json['filename'],
      url: json['url'],
      uploadedDate: DateTime.parse(json['uploadedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'url': url,
      'uploadedDate': uploadedDate.toIso8601String(),
    };
  }
}
