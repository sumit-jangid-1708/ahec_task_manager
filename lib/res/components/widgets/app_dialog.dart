import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDialog {
  // ✅ Base Style Constants
  static const _primaryColor = Color(0xFF3F63F4);
  static const _textStyle = TextStyle(fontFamily: 'Poppins');

  // ✅ Generic Modern Alert Dialog
  static Future<void> show({
    String title = "Alert",
    required String message,
    String buttonText = "OK",
    Color color = _primaryColor,
    IconData icon = Icons.info_outline_rounded,
    VoidCallback? onConfirm,
  }) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(Get.context!).pop();
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Simplified Confirmation (Yes/No)
  static Future<void> confirm({
    required String message,
    required VoidCallback onConfirm,
    String title = "Are you sure?",
  }) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Get.back();
              Navigator.of(Get.context!).pop();
              onConfirm();
            },
            child: Text("Confirm", style: GoogleFonts.poppins(color: _primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✅ Simple Loading Overlay
  static void showLoading({String message = 'Please wait...'}) {
    Get.dialog(
      PopScope(
        canPop: false, // Prevents closing via back button
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _primaryColor),
                const SizedBox(height: 16),
                Text(message, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black, decoration: TextDecoration.none)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Navigator.of(Get.context!).pop();
  }
}