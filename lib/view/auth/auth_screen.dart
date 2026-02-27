import 'package:ahec_task_manager/view/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../res/components/widgets/app_text_field.dart';
import '../../res/routes/routes_names.dart';
import '../../view_models/controller/auth/auth_controller.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),

              // Username field
              AppTextField(
                hint: "Username",
                controller: controller.usernameController,
              ),

              // Password field
              // AppTextField(
              //   hint: "Password",
              //   controller: controller.passwordController,
              //   isObscure: true,
              // ),
              Obx(() => AppTextField(
                hint: "Password",
                controller: controller.passwordController,
                isObscure: controller.isPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    controller.isPasswordHidden.value = !controller.isPasswordHidden.value;
                  },
                ),
              )),
              const SizedBox(height: 15),

              // Login Button
              SizedBox(
                width: 120,
                height: 45,
                child: ElevatedButton(
                  onPressed: (){
                    // Get.toNamed(RouteName.dashboard);
                    controller.login();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F63F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.montaga(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    // TextStyle(
                    //   fontSize: 16,
                    //   color: Colors.white,
                    //
                    // ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
