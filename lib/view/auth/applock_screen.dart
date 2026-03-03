import 'package:ahec_task_manager/view_models/controller/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../res/components/widgets/app_dialog.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with WidgetsBindingObserver {
  AuthController get controller => Get.find<AuthController>();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Slight delay to prevent native dialog from clashing with route transition
    Future.delayed(const Duration(milliseconds: 500), () {
      _triggerAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-trigger authentication when app is brought back to foreground
    if (state == AppLifecycleState.resumed &&
        !controller.isAuthenticated.value &&
        !_isAuthenticating) {
      _triggerAuth();
    }
    // if (state == AppLifecycleState.resumed &&
    //     !controller.isAuthenticated.value) {
    //   _triggerAuth();
    // }
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;
    if (!mounted) return;
    setState(() => _isAuthenticating = true);
    await controller.authenticate();
    if (!mounted) return;
    setState(() => _isAuthenticating = false);
  }
  // Future<void> _triggerAuth() async {
  //   if (_isAuthenticating) return; // Prevent duplicate authentication calls
  //   setState(() => _isAuthenticating = true);
  //   await controller.authenticate();
  //   if (mounted) setState(() => _isAuthenticating = false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFF3F63F4).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(
                () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Lock icon container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F63F4).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 80,
                    color: Color(0xFF3F63F4),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  "App Locked",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Please verify your identity to continue to your Task Manager.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Unlock button - shown when not yet authenticated
                if (!controller.isAuthenticated.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: _triggerAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F63F4),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isAuthenticating
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        "Unlock with Biometrics / PIN",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Logout option
                TextButton(
                  onPressed: (){
                    AppDialog.confirm(
                      message: "Are you sure you want to Logout?",
                      // onConfirm:()=> controller.logout(),
                      onConfirm: () {
                        if (mounted) controller.logout();
                      },
                    );
                  },
                  style:
                  TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}