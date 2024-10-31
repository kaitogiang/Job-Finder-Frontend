import 'package:flutter/material.dart';

class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  // @override
  // Route<T> createRoute(BuildContext context) => DialogRoute<T>(
  //       context: context,
  //       settings: this,
  //       builder: builder, // Pass the builder directly
  //       anchorPoint: anchorPoint,
  //       barrierColor: barrierColor,
  //       barrierDismissible: barrierDismissible,
  //       barrierLabel: barrierLabel,
  //       useSafeArea: useSafeArea,
  //       themes: themes,
  //     );

  //Tạo route cho DialogPage để thêm hiệu ứng fade transition
  @override
  Route<T> createRoute(BuildContext context) => PageRouteBuilder<T>(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: builder(context),
          );
        },
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        opaque: false,
        transitionDuration: const Duration(
            milliseconds: 300), // Adjust duration for smoother transition
        reverseTransitionDuration: const Duration(milliseconds: 300),
      );
}
