import 'package:flutter/material.dart';

/// Single visible SnackBar — avoids stacking when users tap quickly.
void showAppSnackBar(BuildContext context, SnackBar snackBar) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(snackBar);
}
