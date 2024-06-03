import 'package:flutter/material.dart';

class ModalBottomSheet extends StatelessWidget {
  const ModalBottomSheet({required this.child, required this.title, super.key});

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ThemeData theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.75,
      widthFactor: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold
                  )
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                )
              ],
            ),
            Divider(),
            const SizedBox(height: 10,),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAdditionalScreen({
  required BuildContext context,
  required String title, 
  required Widget child
  }) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true, 
    builder: (context) {
      return ModalBottomSheet(child: child, title: title);
    },
  );
}