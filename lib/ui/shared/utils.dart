import 'dart:developer';

class Utils {
  //Hàm loại bỏ dấu Tiếng Việt để dễ dàng trong tìm kiếm
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

  //Hàm bổ trợ log thông tin ra màn hình để debug với thông tin về file và dòng
  static void logMessage(String message) {
    //Lấy thông tin về thực thị trong stack tại thời điểm gọi hàm này.
    //Thông tin stack trace như sau: #1.....................
    //#2.....................
    //vvv.v..vvv
    //Nó giống như là một stack biểu thị thứ tự thực thi của từng thần phần trong hệ
    //thống khi gọi hàm này, mỗi dòng được đánh dấu bằng ký tự # và số thứ tự
    //#0 chính là hàm logMessage bởi vì nó phải truy xuất đến người gọi nó trước rồi mới
    //tới nó cuối cùng. Có thể hiểu là thứ tự thực hiện các lệnh từ lệnh nhỏ nhất
    //tới lệnh lớn nhất.
    final stackTrace = StackTrace.current;
    //Chuyển thông tin stack trace thành một chuỗi và tách thành các phần tử
    final frames = stackTrace.toString().split('\n');
    //Nếu có nhiều hơn 1 phần tử thì lấy phần tử thứ 2
    if (frames.length > 1) {
      //Phần tử thứ hai chính là nơi nó được gọi gần nhất, thí dụ, nếu trong file main
      //gọi hàm logMessage thì phần tử thứ 2 sẽ là thông tin đường dẫn file main và dòng
      final frame = frames[1];
      final fileInfo = _extractFileInfo(frame);
      log('$message ($fileInfo)\n');
    } else {
      log(message);
    }
  }

  //Hàm lấy thông tin về file và dòng của phần tử thứ 2 trong stack trace
  static String _extractFileInfo(String frame) {
    //r'...': The r before the string indicates a raw string in Dart, which means special characters like backslashes are treated as literals.
    //(\S+\.dart):(\d+):(\d+): This part of the pattern matches a file name with an extension (like .dart), followed by a colon, a line number, another colon, and a column number.
    //The \S+ matches one or more non-whitespace characters, which typically represent the file name.
    //The :(\d+):(\d+) matches a colon, followed by one or more digits (representing the line number), another colon, and one or more digits (representing the column number).
    //`(...)`: Parentheses create a capturing group, which allows us to extract the matched column number.
    final fileInfoPattern = RegExp(r'(\S+\.dart):(\d+):(\d+)');
    //Tìm kiếm mẫu trong chuỗi frame
    final match = fileInfoPattern.firstMatch(frame);
    if (match != null) {
      //Mỗi ngoặc tròn là một nhóm, mỗi nhóm sẽ được lưu trữ trong một list
      //Ví dụ: match.group(0) sẽ là toàn bộ chuỗi khớp, match.group(1) sẽ là phần tử thứ nhất trong list, match.group(2) sẽ là phần tử thứ hai trong list, vv...
      final fileName = match.group(1);
      final lineNumber = match.group(2);
      return '$fileName:$lineNumber';
    }

    return 'unknown location';
  }
}
