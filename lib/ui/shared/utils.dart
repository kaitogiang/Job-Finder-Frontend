import 'dart:developer';

class Utils {
  //Function to remove Vietnamese accents for easier searching
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

  //Helper function to log information to screen for debugging with file and line info
  static void logMessage(String message) {
    //Get execution information in the stack at the time this function is called.
    //Stack trace information is as follows: #1.....................
    //#2.....................
    //vvv.v..vvv
    //It's like a stack showing the execution order of each component in the system
    //when calling this function, each line is marked with # and sequence number
    //#0 is the logMessage function itself because it has to access its caller first
    //before getting to itself last. Can be understood as the order of execution from
    //smallest to largest command.
    final stackTrace = StackTrace.current;
    //Convert stack trace information to a string and split into elements
    final frames = stackTrace.toString().split('\n');
    //If there is more than 1 element, take the second element
    if (frames.length > 1) {
      //The second element is where it was called most recently, for example, if in the main file
      //calls logMessage then the second element will be the main file path and line information
      final frame = frames[1];
      final fileInfo = _extractFileInfo(frame);
      log('$message ($fileInfo)\n');
    } else {
      log(message);
    }
  }

  //Function to get file and line information of the second element in stack trace
  static String _extractFileInfo(String frame) {
    //r'...': The r before the string indicates a raw string in Dart, which means special characters like backslashes are treated as literals.
    //(\S+\.dart):(\d+):(\d+): This part of the pattern matches a file name with an extension (like .dart), followed by a colon, a line number, another colon, and a column number.
    //The \S+ matches one or more non-whitespace characters, which typically represent the file name.
    //The :(\d+):(\d+) matches a colon, followed by one or more digits (representing the line number), another colon, and one or more digits (representing the column number).
    //`(...)`: Parentheses create a capturing group, which allows us to extract the matched column number.
    final fileInfoPattern = RegExp(r'(\S+\.dart):(\d+):(\d+)');
    //Search for pattern in frame string
    final match = fileInfoPattern.firstMatch(frame);
    if (match != null) {
      //Each parenthesis is a group, each group will be stored in a list
      //Example: match.group(0) will be the entire matching string, match.group(1) will be the first element in the list, match.group(2) will be the second element in the list, etc...
      final fileName = match.group(1);
      final lineNumber = match.group(2);
      return '$fileName:$lineNumber';
    }

    return 'unknown location';
  }
}
