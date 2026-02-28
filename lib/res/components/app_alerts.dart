import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppAlerts {
  static void error(String message){
    if (Get.isDialogOpen ?? false) Get.back();

    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      // duration: const Duration(seconds: 3),
    );
  }
  static void success(String message){
    Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green.shade700,
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15)
    );
  }
}