import 'package:ahec_task_manager/model/currency_model.dart';
import 'package:ahec_task_manager/model/rm_list_model.dart';
import 'package:ahec_task_manager/res/components/app_alerts.dart';
import 'package:ahec_task_manager/res/storage_keys.dart';
import 'package:ahec_task_manager/view_models/services/list_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/app_exceptions.dart';
import '../../model/servcie_list_model.dart';
import 'auth/auth_controller.dart';

class ListController extends GetxController {
  final ListService _listService = ListService();
  final GetStorage _storage = GetStorage();
  late final AuthController _authController;

  var isLoading = false.obs;

  // ── RM list ──────────────────────────────────────────────────────────────
  final rmIdModel = Rx<RmIDListModel?>(null);
  var rmList = <String>[].obs;
  var rmIdMap = <String, String>{}.obs;
  var rmIdSelected = "".obs;
  var userRmId = 0.obs; // Logged-in user's matched RM ID (used by all controllers)

  // ── Service list ─────────────────────────────────────────────────────────
  final serviceListModel = Rx<ServiceListModel?>(null);
  var serviceList = <String>[].obs;
  var serviceIdMap = <String, String>{}.obs;

  // ── Currency list ─────────────────────────────────────────────────────────
  final currencyModel = Rx<CurrencyModel?>(null);
  var currencyList = <String>[].obs;
  var currencyCodeMap = <String, String>{}.obs;
  var currencyIdMap = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    // RM list must resolve first — others depend on userRmId
    getRmList();
    getServiceList();
    getCurrencyList();
  }

  // ── Current logged-in user helpers ────────────────────────────────────────

  String get _currentUserName {
    final stored = _storage.read(StorageKeys.teamName) ?? '';
    if (stored.isNotEmpty) return stored.trim();
    return _authController.loginResponse?.user.teamName.trim() ?? '';
  }

  String get _currentUserEmail {
    final stored = _storage.read(StorageKeys.teamEmail) ?? '';
    if (stored.isNotEmpty) return stored.trim().toLowerCase();
    return _authController.loginResponse?.user.teamEmail.trim().toLowerCase() ?? '';
  }

  // ── RM List ───────────────────────────────────────────────────────────────

  Future<void> getRmList() async {
    try {
      isLoading.value = true;

      final response = await _listService.rmList();
      rmIdModel.value = RmIDListModel.fromJson(response);

      if (rmIdModel.value == null || rmIdModel.value!.rmidList.isEmpty) {
        AppAlerts.error("No RM data available. Please contact admin.");
        return;
      }

      final allRms = rmIdModel.value!.rmidList;

      // Build full RM dropdown list and map for all controllers
      rmList.value = allRms.map((item) => '${item.rmid} - ${item.name}').toList();
      rmIdMap.value = {
        for (var item in allRms) '${item.rmid} - ${item.name}': item.id.toString()
      };

      final String currentName = _currentUserName;
      final String currentEmail = _currentUserEmail;

      if (currentName.isEmpty || currentEmail.isEmpty) {
        AppAlerts.error("User session data missing. Please login again.");
        return;
      }

      print("Matching RM for: $currentName ($currentEmail)");

      // Match by email + name first
      RmIDItem? matchedRm = allRms.firstWhereOrNull(
            (item) =>
        item.email.trim().toLowerCase() == currentEmail &&
            item.name.trim().toLowerCase() == currentName.toLowerCase(),
      );

      // Fallback: email-only match
      matchedRm ??= allRms.firstWhereOrNull(
            (item) => item.email.trim().toLowerCase() == currentEmail,
      );

      if (matchedRm == null) {
        AppAlerts.error("Your account was not found in the RM list. Please contact admin.");
        return;
      }

      // Set logged-in user's RM as default
      rmIdSelected.value = '${matchedRm.rmid} - ${matchedRm.name}';
      userRmId.value = matchedRm.id;

      print("RM matched: ${matchedRm.name} (${matchedRm.email}) | ID: ${matchedRm.id}");
      print("Total RMs in dropdown: ${rmList.length}");
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      print("Unexpected error fetching RM list: $e");
      AppAlerts.error("Failed to load RM data.");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper for InsertClient - get RM ID int from display name
  String? getRmIdFromName(String displayName) => rmIdMap[displayName];

  // ── Service List ──────────────────────────────────────────────────────────

  Future<void> getServiceList() async {
    try {
      final response = await _listService.serviceList();
      serviceListModel.value = ServiceListModel.fromJson(response);

      serviceList.value = serviceListModel.value!.serviceList.entries
          .map((entry) => '${entry.value} (ID: ${entry.key})')
          .toList();

      serviceIdMap.value = {};
      serviceListModel.value!.serviceList.forEach((key, value) {
        serviceIdMap['$value (ID: $key)'] = key;
      });

      print("Service list fetched: ${serviceList.length}");
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      if (kDebugMode) print("Service list error: $e");
      AppAlerts.error("Failed to load service list.");
    }
  }

  // ── Currency List ─────────────────────────────────────────────────────────

  Future<void> getCurrencyList() async {
    try {
      final response = await _listService.currencyList();
      currencyModel.value = CurrencyModel.fromJson(response);

      currencyList.value = currencyModel.value!.currencyList!.map((c) {
        return '${c.currencyCode} - ${c.currencyName} (${c.currencySymbol})';
      }).toList();

      currencyCodeMap.value = {};
      currencyIdMap.value = {};
      for (var c in currencyModel.value!.currencyList!) {
        final display = '${c.currencyCode} - ${c.currencyName} (${c.currencySymbol})';
        currencyCodeMap[display] = c.currencyCode!;
        currencyIdMap[display] = c.currencyId!;
      }

      print("Currency list fetched: ${currencyList.length}");
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      if (kDebugMode) print("Currency list error: $e");
      AppAlerts.error("Failed to load currency list.");
    }
  }

  // ── Service helpers ───────────────────────────────────────────────────────
  String? getServiceIdFromName(String displayName) => serviceIdMap[displayName];
  String? getServiceNameById(String id) => serviceListModel.value?.serviceList[id];

  // ── Currency helpers ──────────────────────────────────────────────────────
  String? getCurrencyCodeFromName(String displayName) => currencyCodeMap[displayName];
  int? getCurrencyIdFromName(String displayName) => currencyIdMap[displayName];
}





// import 'package:ahec_task_manager/model/currency_model.dart';
// import 'package:ahec_task_manager/res/components/app_alerts.dart';
// import 'package:ahec_task_manager/view_models/services/list_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../data/app_exceptions.dart';
// import '../../model/servcie_list_model.dart';
//
// class ListController extends GetxController {
//   var isLoading = false.obs;
//
//   // Service list data
//   final serviceListModel = Rx<ServiceListModel?>(null);
//   var serviceList = <String>[].obs; // List for dropdown display
//   var serviceIdMap = <String, String>{}.obs; // Map of name -> id
//
//   // Currency list data
//   final currencyModel = Rx<CurrencyModel?>(null);
//   var currencyList = <String>[].obs; // List for dropdown display
//   var currencyCodeMap = <String, String>{}.obs; // Map of display -> code
//   var currencyIdMap = <String, int>{}.obs; // Map of display -> id
//
//   final ListService listService = ListService();
//
//   @override
//   void onInit() {
//     super.onInit();
//     getServiceList();
//     getCurrencyList();
//   }
//
//   Future<void> getServiceList() async {
//     try {
//       isLoading.value = true;
//
//       final response = await listService.serviceList();
//
//       // Parse the ServiceListModel
//       serviceListModel.value = ServiceListModel.fromJson(response);
//
//       // Extract service names for dropdown (with ID in display)
//       serviceList.value = serviceListModel.value!.serviceList.entries.map((
//         entry,
//       ) {
//         return '${entry.value} (ID: ${entry.key})'; // e.g., "Assignment Writing (ID: 1)"
//       }).toList();
//
//       // Create reverse map (name -> id) for submission
//       serviceIdMap.value = {};
//       serviceListModel.value!.serviceList.forEach((key, value) {
//         serviceIdMap['${value} (ID: ${key})'] = key;
//       });
//
//       print("✅ Service List fetched: ${serviceList.length}");
//     } on AppExceptions catch (e) {
//       if (kDebugMode) {
//         print("❌ Service List Exception: $e");
//       }
// AppAlerts.error(e.cleanMessage);
//       // Get.snackbar(
//       //   "Error",
//       //   e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
//       //   duration: const Duration(seconds: 2),
//       //   snackPosition: SnackPosition.TOP,
//       //   backgroundColor: Colors.red,
//       //   colorText: Colors.white,
//       // );
//     } catch (e) {
//       if (kDebugMode) {
//         print("🚩 Service List Error: $e");
//       }
// AppAlerts.error('Failed to load Service List: ${e.toString()}');
//       // Get.snackbar(
//       //   'Error',
//       //   'Failed to load Service List: ${e.toString()}',
//       //   duration: const Duration(seconds: 2),
//       //   snackPosition: SnackPosition.TOP,
//       //   backgroundColor: Colors.red,
//       //   colorText: Colors.white,
//       // );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ✅ Currency List Method
//   Future<void> getCurrencyList() async {
//     try {
//       isLoading.value = true;
//
//       final response = await listService.currencyList();
//
//       // Parse the CurrencyModel
//       currencyModel.value = CurrencyModel.fromJson(response);
//
//       // Extract currency info for dropdown
//       // Format: "USD - US Dollar ($)" or "INR - Indian Rupee (₹)"
//       currencyList.value = currencyModel.value!.currencyList!.map((currency) {
//         return '${currency.currencyCode} - ${currency.currencyName} (${currency.currencySymbol})';
//       }).toList();
//
//       // Create maps for easy access
//       currencyCodeMap.value = {};
//       currencyIdMap.value = {};
//
//       for (var currency in currencyModel.value!.currencyList!) {
//         String displayName =
//             '${currency.currencyCode} - ${currency.currencyName} (${currency.currencySymbol})';
//         currencyCodeMap[displayName] = currency.currencyCode!;
//         currencyIdMap[displayName] = currency.currencyId!;
//       }
//
//       print("✅ Currency List fetched: ${currencyList.length}");
//     } on AppExceptions catch (e) {
//       if (kDebugMode) {
//         print("❌ Currency List Exception: $e");
//       }
//       AppAlerts.error(e.cleanMessage);
//       // Get.snackbar(
//       //   "Error",
//       //   e.toString().replaceAll(RegExp(r"<[^>]*>"), ""),
//       //   duration: const Duration(seconds: 2),
//       //   snackPosition: SnackPosition.TOP,
//       //   backgroundColor: Colors.red,
//       //   colorText: Colors.white,
//       // );
//     } catch (e) {
//       if (kDebugMode) {
//         print("🚩 Currency List Error: $e");
//       }
// AppAlerts.error("Failed to load Currency List:${e.toString()} ");
//       // Get.snackbar(
//       //   'Error',
//       //   'Failed to load Currency List: ${e.toString()}',
//       //   duration: const Duration(seconds: 2),
//       //   snackPosition: SnackPosition.TOP,
//       //   backgroundColor: Colors.red,
//       //   colorText: Colors.white,
//       // );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // ===== Service Helper Methods =====
//
//   // Helper method to get Service ID from selected name
//   String? getServiceIdFromName(String displayName) {
//     return serviceIdMap[displayName];
//   }
//
//   // Helper method to get all service IDs
//   List<String> getAllServiceIds() {
//     return serviceListModel.value?.serviceList.keys.toList() ?? [];
//   }
//
//   // Helper method to get all service names
//   List<String> getAllServiceNames() {
//     return serviceListModel.value?.serviceList.values.toList() ?? [];
//   }
//
//   // Helper method to get service name by ID
//   String? getServiceNameById(String id) {
//     return serviceListModel.value?.serviceList[id];
//   }
//
//   // ===== Currency Helper Methods =====
//
//   // Helper method to get Currency Code from selected display name
//   String? getCurrencyCodeFromName(String displayName) {
//     return currencyCodeMap[displayName];
//   }
//
//   // Helper method to get Currency ID from selected display name
//   int? getCurrencyIdFromName(String displayName) {
//     return currencyIdMap[displayName];
//   }
//
//   // Helper method to get currency by code
//   CurrencyItem? getCurrencyByCode(String code) {
//     return currencyModel.value?.currencyList?.firstWhere(
//       (currency) => currency.currencyCode == code,
//       orElse: () => CurrencyItem(),
//     );
//   }
//
//   // Helper method to get currency by ID
//   CurrencyItem? getCurrencyById(int id) {
//     return currencyModel.value?.currencyList?.firstWhere(
//       (currency) => currency.currencyId == id,
//       orElse: () => CurrencyItem(),
//     );
//   }
// }
