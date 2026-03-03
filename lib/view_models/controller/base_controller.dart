import 'dart:ui';

import 'package:ahec_task_manager/data/app_exceptions.dart';
import 'package:ahec_task_manager/res/components/widgets/app_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin BaseController {
  void handleError(dynamic error, {VoidCallback? onRetry}) {
    if (!Get.isRegistered<GetMaterialController>()) return;
    if (Get.isDialogOpen == true) return;

    if (Get.context == null) return;

    String title = "Error";
    String message =
    error is AppExceptions ? error.cleanMessage : error.toString();
    IconData icon = Icons.error_outline_rounded;
    Color color = Colors.red;

    if (error is InternetExceptions) {
      title = "No Internet";
      message = "Please check your connection.";
      icon = Icons.wifi_off_rounded;
      color = Colors.orange;
    } else if (error is ServerException) {
      title = "Server Error";
      message = "Something went wrong. Please try again.";
      icon = Icons.dns_rounded;
    } else if (error is UnauthorizedException) {
      title = "Session Expired";
      message = "Please login again.";
      icon = Icons.lock_outline_rounded;
    }

    Future.microtask(() {
      if (Get.context != null) {
        AppDialog.show(
          title: title,
          message: message,
          icon: icon,
          color: color,
          onConfirm: onRetry,
        );
      }
    });
  }

  void handleSuccess(String message) {
    if (Get.context == null) return;
    if (Get.isDialogOpen == true) return;

    Future.microtask(() {
      if (Get.context != null) {
        AppDialog.show(
          title: "Success",
          message: message,
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
        );
      }
    });
  }
}


// mixin BaseController {
//   void handleError(dynamic error, {VoidCallback? onRetry}) {
//     if (Get.isDialogOpen ?? false) return;
//
//     String title = "Error";
//     String message = error is AppExceptions
//         ? error.cleanMessage
//         : error.toString();
//     IconData icon = Icons.error_outline_rounded;
//     Color color = Colors.red;
//
//     if (error is InternetExceptions) {
//       title = "No Internet";
//       message = "Please check your connection.";
//       icon = Icons.wifi_off_rounded;
//       color = Colors.orange;
//     } else if (error is ServerException) {
//       title = "Server Error";
//       message = "Something went wrong. Please try again.";
//       icon = Icons.dns_rounded;
//     } else if (error is UnauthorizedException) {
//       title = "Session Expired";
//       message = "Please login again.";
//       icon = Icons.lock_outline_rounded;
//     }
//
//     AppDialog.show(
//       title: title,
//       message: message,
//       icon: icon,
//       color: color,
//       onConfirm: onRetry,
//     );
//   }
//
//   void handleSuccess(String message) {
//     AppDialog.show(
//       title: "Success",
//       message: message,
//       icon: Icons.check_circle_outline_rounded,
//       color: Colors.green,
//     );
//   }
// }
