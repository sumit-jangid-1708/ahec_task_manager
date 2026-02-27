import 'package:ahec_task_manager/model/login_model.dart';
import 'package:ahec_task_manager/res/components/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/app_exceptions.dart';
import '../../../res/routes/routes_names.dart';
import '../../../res/storage_keys.dart';
import '../../services/auth_service/auth_service.dart';
import 'package:local_auth/local_auth.dart';

import '../client_controller.dart';
import '../dashboard_controller.dart';
import '../list_controller.dart';
import '../order_controller.dart';

class AuthController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var isPasswordHidden = true.obs;

  LoginResponseModel? loginResponse;

  final AuthService _authService = AuthService();
  final storage = GetStorage();

  final LocalAuthentication auth = LocalAuthentication();
  var isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final token = storage.read(StorageKeys.token);
    isLoggedIn.value = token != null && token.toString().isNotEmpty;
  }

  // Returns stored team name for RM matching
  String get storedTeamName => storage.read(StorageKeys.teamName) ?? '';

  // Returns stored team email for RM matching
  String get storedTeamEmail => storage.read(StorageKeys.teamEmail) ?? '';

  Future<void> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        isAuthenticated.value = true;
        Get.offAllNamed(RouteName.dashboard);
        return;
      }

      final List<BiometricType> availableBiometrics =
      await auth.getAvailableBiometrics();
      print("Available biometrics: $availableBiometrics");

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Verify your identity to unlock the app',
        biometricOnly: false,
      );

      isAuthenticated.value = didAuthenticate;

      if (didAuthenticate) {
        Get.offAllNamed(RouteName.dashboard);
      }
    } on LocalAuthException catch (e) {
      print("LocalAuthException: ${e.code} - ${e.description}");
      isAuthenticated.value = false;

      bool allowAccess = false;
      String errorMsg = "Authentication failed";

      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.noCredentialsSet:
          allowAccess = true;
          break;
        case LocalAuthExceptionCode.biometricLockout:
        case LocalAuthExceptionCode.temporaryLockout:
          errorMsg = "Too many failed attempts. Please try again later.";
          break;
        case LocalAuthExceptionCode.userCanceled:
          errorMsg = "Authentication was cancelled.";
          break;
        default:
          errorMsg = "Authentication error: ${e.description}";
      }

      if (allowAccess) {
        isAuthenticated.value = true;
        Get.offAllNamed(RouteName.dashboard);
        return;
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        AppAlerts.error(errorMsg);
      });
    } catch (e) {
      print("Unexpected error during authentication: $e");
      isAuthenticated.value = false;

      Future.delayed(const Duration(milliseconds: 300), () {
        AppAlerts.error("Something went wrong during authentication.");
      });
    }
  }

  Future<void> login() async {
    Map<String, String> data = {
      "team_email": usernameController.text.trim(),
      "team_password": passwordController.text.trim(),
    };

    try {
      isLoading.value = true;

      final response = await _authService.loginApi(data);
      loginResponse = LoginResponseModel.fromJson(response);

      // Clear ALL previous user session data before saving new user data.
      // This prevents stale data from a previous login affecting the new session.
      _clearStorage();

      // Save only login-specific session data.
      // Note: RM list ID is NOT stored here — it is always derived fresh
      // by matching teamName + teamEmail against the RM list API.
      storage.write(StorageKeys.token, loginResponse!.user.token);
      storage.write(StorageKeys.isLoggedIn, true);
      storage.write(StorageKeys.teamName, loginResponse!.user.teamName);
      storage.write(StorageKeys.teamEmail, loginResponse!.user.teamEmail);

      isLoggedIn.value = true;
      Get.offAllNamed(RouteName.dashboard);
        AppAlerts.success("Login Successful");

    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      AppAlerts.error("Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _clearStorage();
    isLoggedIn.value = false;
    isAuthenticated.value = false;

    Get.delete<DashboardController>(force: true);
    Get.delete<OrderController>(force: true);
    Get.delete<ClientController>(force: true);
    Get.delete<ListController>(force: true);

    Get.offAllNamed(RouteName.auth);
  }

  // Clears all stored session data for the current user
  void _clearStorage() {
    storage.remove(StorageKeys.token);
    storage.remove(StorageKeys.isLoggedIn);
    storage.remove(StorageKeys.teamName);
    storage.remove(StorageKeys.teamEmail);
  }
}