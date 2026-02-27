// lib/res/components/app_notification.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NotificationType { success, error, warning, info }

class AppNotification {
  // Private constructor - direct instantiation nahi hoga
  AppNotification._();

  static void show({
    required String message,
    NotificationType type = NotificationType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    // Agar koi snackbar already open hai to pehle close karo
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final config = _getConfig(type);

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar(
        title ?? config.title,
        message,
        snackPosition: position,
        backgroundColor: config.backgroundColor,
        colorText: Colors.white,
        duration: duration,
        borderRadius: 10,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icon(config.icon, color: Colors.white, size: 24),
        shouldIconPulse: false,
        boxShadows: [
          BoxShadow(
            color: config.backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    });
  }

  // ✅ Shortcut methods
  static void success(String message, {String? title}) => show(
    message: message,
    type: NotificationType.success,
    title: title,
  );

  static void error(String message, {String? title}) => show(
    message: message,
    type: NotificationType.error,
    title: title,
  );

  static void warning(String message, {String? title}) => show(
    message: message,
    type: NotificationType.warning,
    title: title,
  );

  static void info(String message, {String? title}) => show(
    message: message,
    type: NotificationType.info,
    title: title,
  );

  static _NotificationConfig _getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          title: 'Success',
          backgroundColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
        );
      case NotificationType.error:
        return _NotificationConfig(
          title: 'Error',
          backgroundColor: const Color(0xFFC62828),
          icon: Icons.error_rounded,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          title: 'Warning',
          backgroundColor: const Color(0xFFE65100),
          icon: Icons.warning_rounded,
        );
      case NotificationType.info:
        return _NotificationConfig(
          title: 'Info',
          backgroundColor: const Color(0xFF1565C0),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _NotificationConfig {
  final String title;
  final Color backgroundColor;
  final IconData icon;

  _NotificationConfig({
    required this.title,
    required this.backgroundColor,
    required this.icon,
  });
}