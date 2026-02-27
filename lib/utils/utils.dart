
import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class Utils{
  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus){
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // static toastMessage(String message){
  //   Fluttertoast.showToast(
  //       msg: message,
  //       backgroundColor: AppColor.blackColor,
  //       gravity: ToastGravity.BOTTOM,
  //   );
  // }

  // static toastMessageCenter(String message){
  //   Fluttertoast.showToast(
  //     msg: message,
  //     backgroundColor: AppColor.blackColor,
  //     gravity: ToastGravity.BOTTOM,
  //   );
  // }

  static bool isEmailValid(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email.trim());
  }

  static snackBar(String title, String message) {
    Get.snackbar(title, message);
  }
}