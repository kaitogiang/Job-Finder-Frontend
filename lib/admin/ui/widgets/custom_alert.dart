import 'package:flutter/material.dart';

enum CustomAlertType { delete, lock, unlock }

Future<bool?> confirmActionDialog(BuildContext context, String title,
    String content, String warmingText, CustomAlertType type) async {
  final textTheme = Theme.of(context).textTheme;
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: type == CustomAlertType.delete
                  ? Colors.red
                  : type == CustomAlertType.lock
                      ? Colors.yellow.shade400
                      : Colors.green.shade400,
              child: Icon(
                type == CustomAlertType.delete
                    ? Icons.delete_rounded
                    : type == CustomAlertType.lock
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: textTheme.titleLarge!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
            child: Column(
          children: [
            Text(content, style: textTheme.bodyMedium!.copyWith(fontSize: 15)),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: type == CustomAlertType.delete
                    ? const Color(0xFFffe9d9)
                    : const Color(0xFFF8F3D6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          (Icons.warning),
                          color: type == CustomAlertType.delete
                              ? Colors.red.shade900
                              : type == CustomAlertType.lock
                                  ? Colors.yellow.shade900
                                  : Colors.green.shade900,
                        ),
                      ),
                      const WidgetSpan(child: SizedBox(width: 5)),
                      TextSpan(
                        text: 'Cảnh báo',
                        style: textTheme.bodyMedium!.copyWith(
                          color: type == CustomAlertType.delete
                              ? Colors.red.shade900
                              : type == CustomAlertType.lock
                                  ? Colors.yellow.shade900
                                  : Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  warmingText,
                  style: textTheme.bodyMedium!.copyWith(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        )),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              foregroundColor: Colors.grey.shade900,
              textStyle: textTheme.bodyMedium!.copyWith(
                fontSize: 16,
              ),
              fixedSize: const Size(120, 40),
            ),
            child: const Text('Không'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          const SizedBox(width: 10),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: type == CustomAlertType.delete
                  ? Colors.red.shade900
                  : type == CustomAlertType.lock
                      ? Colors.yellow.shade900
                      : Colors.green.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              foregroundColor: Colors.white,
              textStyle: textTheme.bodyMedium!.copyWith(
                fontSize: 16,
              ),
              fixedSize: const Size(120, 40),
            ),
            child: const Text('Chắc chắn'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<void> showAdditionalInfoDialog(
    {required BuildContext context,
    required String title,
    required String headerIcon,
    required Widget content}) {
  final textTheme = Theme.of(context).textTheme;
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        children: [
          Image.asset(
            headerIcon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: textTheme.titleLarge!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
      content: content,
    ),
  );
}
