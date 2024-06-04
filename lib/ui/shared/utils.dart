class Utils {
  //TODO: Hàm loại bỏ dấu Tiếng Việt để dễ dàng trong tìm kiếm
  static String removeVietnameseAccent(String origin) {
    Map<String, List<String>> template = {
      'a': [
        'á',
        'à',
        'ã',
        'ạ',
        'â',
        'ấ',
        'ầ',
        'ẫ',
        'ậ',
        'ă',
        'ắ',
        'ằ',
        'ẵ',
        'ặ'
      ],
      'e': ['é', 'è', 'ẽ', 'ẹ', 'ê', 'ế', 'ề', 'ễ', 'ệ', 'ẻ'],
      'i': ['í', 'ì', 'ĩ', 'ị'],
      'o': [
        'ó',
        'ò',
        'õ',
        'ọ',
        'ô',
        'ố',
        'ồ',
        'ỗ',
        'ộ',
        'ơ',
        'ớ',
        'ờ',
        'ỡ',
        'ợ'
      ],
      'u': ['ú', 'ù', 'ũ', 'ụ', 'ư', 'ứ', 'ừ', 'ữ', 'ự'],
      'y': ['ý', 'ỳ', 'ỹ', 'ỵ'],
    };

    String newString = origin.toLowerCase();

    template.forEach((basic, list) {
      for (int i = 0; i < newString.length; i++) {
        if (list.contains(newString[i])) {
          newString = newString.replaceAll(newString[i], basic);
        }
      }
    });
    return newString;
  }
}
