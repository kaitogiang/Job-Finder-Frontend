import 'package:flutter/material.dart';

class SortBox extends StatelessWidget {
  const SortBox({
    super.key,
    required this.sortOptions,
    required this.selectedIndex,
  });

  final Map<String, void Function()> sortOptions;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final menuButtonStyle = MenuItemButton.styleFrom(
      padding: EdgeInsets.only(
        left: 10,
        right: 20,
        top: 7,
        bottom: 7,
      ),
    );

    //Lấy thông tin về tiêu đề các option
    final optionTitles = sortOptions.keys.toList();
    //Lấy thông tin về xử lý khi chọn vào từng option
    final optionHandlers = sortOptions.values.toList();

    return MenuAnchor(
      menuChildren: List<MenuItemButton>.generate(sortOptions.length, (index) {
        return MenuItemButton(
          style: menuButtonStyle,
          onPressed: optionHandlers[index],
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.check,
                    color: selectedIndex == index
                        ? Colors.green.shade800
                        : Colors.transparent,
                  ),
                ),
                WidgetSpan(
                  child: const SizedBox(width: 5),
                ),
                TextSpan(
                  text: optionTitles[index],
                ),
              ],
            ),
          ),
        );
      }),
      builder: (context, controller, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 7,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fixedSize: Size(130, 38),
          ),
          icon: Icon(
            Icons.sort,
            color: Colors.grey.shade600,
          ),
          label: Text(
            'Sắp xếp',
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey.shade600),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        ),
      ),
    );
  }
}
