import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static Future<bool?> showSuccess(
    BuildContext context, {
    required String message,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return _show(
      message: message,
      backgroundColor: scheme.primary,
      textColor: scheme.onPrimary,
    );
  }

  static Future<bool?> showError(
    BuildContext context, {
    required String message,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return _show(
      message: message,
      backgroundColor: scheme.error,
      textColor: scheme.onError,
    );
  }

  static Future<bool?> showInfo(
    BuildContext context, {
    required String message,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return _show(
      message: message,
      backgroundColor: scheme.surfaceContainerHighest,
      textColor: scheme.onSurface,
    );
  }

  static Future<bool?> _show({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14,
    );
  }
}
