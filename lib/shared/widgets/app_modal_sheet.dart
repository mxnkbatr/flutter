import 'package:flutter/material.dart';

/// Shows a bottom sheet above [ClientShell]'s floating navigation bar.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isScrollControlled = false,
  ShapeBorder? shape,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    shape: shape,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: builder,
  );
}
