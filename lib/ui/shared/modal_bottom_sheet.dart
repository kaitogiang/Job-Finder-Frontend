import 'package:flutter/material.dart';

class ModalBottomSheet extends StatelessWidget {
  const ModalBottomSheet(
      {required this.child,
      required this.title,
      super.key,
      this.heightFactor = 0.75});

  final Widget child;
  final String title;
  final double heightFactor;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeData theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: heightFactor,
      widthFactor: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: textTheme.titleLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
            Divider(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAdditionalScreen(
    {required BuildContext context,
    required String title,
    required Widget child,
    double heightFactor = 0.75}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) {
      return ModalBottomSheet(
        child: child,
        title: title,
        heightFactor: heightFactor,
      );
    },
  );
}
