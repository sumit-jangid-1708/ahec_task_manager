import 'package:ahec_task_manager/model/client_model.dart';
import 'package:ahec_task_manager/model/insert_client_model.dart';
import 'package:ahec_task_manager/res/components/app_alerts.dart';
import 'package:ahec_task_manager/view_models/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import 'list_controller.dart';

class ClientController extends GetxController {
  // RM data now lives in ListController
  final ListController _listController = Get.find<ListController>();
  final ClientService _clientService = ClientService();

  // Expose userRmId as passthrough so OrderController/DashboardController
  // can still use _clientController.userRmId without breaking changes
  int get userRmIdValue => _listController.userRmId.value;
  RxInt get userRmId => _listController.userRmId;

  // Expose RM dropdown data as passthrough for OrderController
  List<String> get rmList => _listController.rmList;
  Map<String, String> get rmIdMap => _listController.rmIdMap;
  RxString get rmIdSelected => _listController.rmIdSelected;

  // Client list
  final clients = <ClientData>[].obs;
  var filteredClients = <ClientData>[].obs;
  var isSearching = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var totalClients = 0.obs;
  var hasMoreData = true.obs;

  // Loading states
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // Form fields
  final firstName = TextEditingController().obs;
  final lastName = TextEditingController().obs;
  final email = TextEditingController().obs;
  final universityName = TextEditingController().obs;
  var phoneNumber = "".obs;
  var countryCode = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Wait for RM ID to resolve in ListController, then load clients
    ever(_listController.userRmId, (int rmId) {
      if (rmId != 0 && clients.isEmpty) {
        getClientList();
      }
    });

    // Load immediately if already available
    if (_listController.userRmId.value != 0) {
      getClientList();
    }
  }

  @override
  void onClose() {
    firstName.value.dispose();
    lastName.value.dispose();
    email.value.dispose();
    universityName.value.dispose();
    super.onClose();
  }

  void searchClients(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      filteredClients.clear();
      return;
    }
    isSearching.value = true;
    filteredClients.value = clients.where((client) {
      final q = query.toLowerCase();
      return client.userName.toLowerCase().contains(q) ||
          client.userEmail.toLowerCase().contains(q) ||
          client.mobile.toLowerCase().contains(q) ||
          client.univercityName.toLowerCase().contains(q) ||
          client.userId.toString().contains(q);
    }).toList();
  }

  List<ClientData> get displayClients =>
      isSearching.value ? filteredClients : clients;

  Future<void> getClientList() async {
    final int rmId = _listController.userRmId.value;
    if (rmId == 0) return;

    try {
      isLoading.value = true;
      currentPage.value = 1;
      clients.clear();

      final response = await _clientService.getClient(
        rmId: rmId,
        page: currentPage.value,
      );
      final clientModel = ClientModel.fromJson(response);

      totalClients.value = clientModel.usersList.total;
      lastPage.value = clientModel.usersList.lastPage;
      currentPage.value = clientModel.usersList.currentPage;
      clients.addAll(clientModel.usersList.data);
      hasMoreData.value = currentPage.value < lastPage.value;

      print("Clients fetched: ${clients.length} / ${totalClients.value}");
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      AppAlerts.error("Failed to load client list.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreClients() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _clientService.getClient(
        rmId: _listController.userRmId.value,
        page: currentPage.value,
      );
      final clientModel = ClientModel.fromJson(response);

      clients.addAll(clientModel.usersList.data);
      hasMoreData.value = currentPage.value < lastPage.value;

      print("More clients loaded. Total: ${clients.length}");
    } on AppExceptions catch (e) {
      currentPage.value--;
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      currentPage.value--;
      AppAlerts.error("Failed to load more clients.");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshClients() async {
    currentPage.value = 1;
    clients.clear();
    await getClientList();
  }

  Future<void> getAllClientsForDropdown() async {
    if (isLoading.value) return;
    final int rmId = _listController.userRmId.value;
    if (rmId == 0) return;

    try {
      isLoading.value = true;
      clients.clear();

      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _clientService.getClient(rmId: rmId, page: page);
        final model = ClientModel.fromJson(response);
        clients.addAll(model.usersList.data);
        hasMore = page < model.usersList.lastPage;
        page++;
      }

      print("All clients loaded for dropdown: ${clients.length}");
    } catch (e) {
      AppAlerts.error("Failed to load client list.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> insertClient() async {
    try {
      isLoading.value = true;

      final String? rmIdString =
      _listController.getRmIdFromName(_listController.rmIdSelected.value);
      if (rmIdString == null) {
        AppAlerts.error("RM ID is not set. Please try logging in again.");
        return;
      }

      final Map<String, dynamic> data = {
        "first_name": firstName.value.text.trim(),
        "last_name": lastName.value.text.trim(),
        "email": email.value.text.trim(),
        "phone_number": phoneNumber.value,
        "country_code": countryCode.value,
        "rm_id": int.parse(rmIdString),
        "univercity_name": universityName.value.text.trim(),
      };

      final response = await _clientService.insertClient(data);
      final insertResponse = InsertClientModel.fromJson(response);

      if (insertResponse.status == 200) {
        _clearForm();
        await refreshClients();
        Navigator.of(Get.context!).pop();
        Future.delayed(const Duration(milliseconds: 200), () {
          AppAlerts.success(insertResponse.message);
        });
      } else {
        AppAlerts.error(insertResponse.message);
      }
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      AppAlerts.error("Failed to add client.");
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    firstName.value.clear();
    lastName.value.clear();
    email.value.clear();
    universityName.value.clear();
    phoneNumber.value = "";
    countryCode.value = "";
  }
}


// import 'package:ahec_task_manager/model/client_model.dart';
// import 'package:ahec_task_manager/model/insert_client_model.dart';
// import 'package:ahec_task_manager/model/rm_list_model.dart';
// import 'package:ahec_task_manager/res/components/app_alerts.dart';
// import 'package:ahec_task_manager/res/storage_keys.dart';
// import 'package:ahec_task_manager/view_models/services/client_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import '../../data/app_exceptions.dart';
// import 'auth/auth_controller.dart';
//
// class ClientController extends GetxController {
//   final AuthController _authController = Get.find<AuthController>();
//   final ClientService _clientService = ClientService();
//   final GetStorage _storage = GetStorage();
//
//   // RM data
//   final rmIdModel = Rx<RmIDListModel?>(null);
//   var rmList = <String>[].obs;
//   var rmIdMap = <String, String>{}.obs;
//   var rmItems = <RmIDItem>[].obs;
//   var rmIdSelected = "".obs;
//   var userRmId = 0.obs; // The matched RM list ID used for API calls
//
//   // Client list
//   final clients = <ClientData>[].obs;
//   var filteredClients = <ClientData>[].obs;
//   var isSearching = false.obs;
//
//   // Pagination
//   var currentPage = 1.obs;
//   var lastPage = 1.obs;
//   var totalClients = 0.obs;
//   var hasMoreData = true.obs;
//
//   // Loading states
//   var isLoading = false.obs;
//   var isLoadingMore = false.obs;
//
//   // Form fields
//   final firstName = TextEditingController().obs;
//   final lastName = TextEditingController().obs;
//   final email = TextEditingController().obs;
//   final universityName = TextEditingController().obs;
//   var phoneNumber = "".obs;
//   var countryCode = "".obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Step 1: Fetch RM list and match current user.
//     // Step 2: Only after RM ID is resolved, fetch client list.
//     _initializeData();
//   }
//
//   @override
//   void onClose() {
//     firstName.value.dispose();
//     lastName.value.dispose();
//     email.value.dispose();
//     universityName.value.dispose();
//     super.onClose();
//   }
//
//   Future<void> _initializeData() async {
//     await getRmIdList();
//     if (userRmId.value != 0) {
//       await getClientList();
//     } else {
//       print("RM ID could not be resolved. Client list will not be loaded.");
//     }
//   }
//
//   // Returns the current user's name from storage or login response
//   String get _currentUserName {
//     final stored = _storage.read(StorageKeys.teamName) ?? '';
//     if (stored.isNotEmpty) return stored.trim();
//     return _authController.loginResponse?.user.teamName.trim() ?? '';
//   }
//
//   // Returns the current user's email from storage or login response
//   String get _currentUserEmail {
//     final stored = _storage.read(StorageKeys.teamEmail) ?? '';
//     if (stored.isNotEmpty) return stored.trim().toLowerCase();
//     return _authController.loginResponse?.user.teamEmail.trim().toLowerCase() ?? '';
//   }
//
//   void searchClients(String query) {
//     if (query.isEmpty) {
//       isSearching.value = false;
//       filteredClients.clear();
//       return;
//     }
//     isSearching.value = true;
//     filteredClients.value = clients.where((client) {
//       final q = query.toLowerCase();
//       return client.userName.toLowerCase().contains(q) ||
//           client.userEmail.toLowerCase().contains(q) ||
//           client.mobile.toLowerCase().contains(q) ||
//           client.univercityName.toLowerCase().contains(q) ||
//           client.userId.toString().contains(q);
//     }).toList();
//   }
//
//   List<ClientData> get displayClients =>
//       isSearching.value ? filteredClients : clients;
//
//   Future<void> getRmIdList() async {
//     try {
//       isLoading.value = true;
//
//       final response = await _clientService.rmList();
//       rmIdModel.value = RmIDListModel.fromJson(response);
//
//       if (rmIdModel.value == null || rmIdModel.value!.rmidList.isEmpty) {
//         print("RM list is empty or null.");
//         AppAlerts.error("No RM data available. Please contact admin.");
//         return;
//       }
//
//       // Build full RM list for dropdown (all RMs)
//       final allRms = rmIdModel.value!.rmidList;
//       rmList.value = allRms
//           .map((item) => '${item.rmid} - ${item.name}')
//           .toList();
//       rmIdMap.value = {
//         for (var item in allRms)
//           '${item.rmid} - ${item.name}': item.id.toString()
//       };
//       rmItems.value = allRms;
//
//       final String currentName = _currentUserName;
//       final String currentEmail = _currentUserEmail;
//
//       if (currentName.isEmpty || currentEmail.isEmpty) {
//         print("Current user name/email is missing. Cannot match RM.");
//         AppAlerts.error("User session data missing. Please login again.");
//         return;
//       }
//
//       print("Matching RM for: $currentName ($currentEmail)");
//
//       // Match by email + name
//       RmIDItem? matchedRm = allRms.firstWhereOrNull(
//             (item) =>
//         item.email.trim().toLowerCase() == currentEmail &&
//             item.name.trim().toLowerCase() == currentName.toLowerCase(),
//       );
//
//       // Fallback: match by email only
//       matchedRm ??= allRms.firstWhereOrNull(
//             (item) => item.email.trim().toLowerCase() == currentEmail,
//       );
//
//       if (matchedRm == null) {
//         print("No RM match found for: $currentName ($currentEmail)");
//         AppAlerts.error(
//             "Your account was not found in the RM list. Please contact admin.");
//         return;
//       }
//
//       // Set logged-in user's RM as default selection
//       rmIdSelected.value = '${matchedRm.rmid} - ${matchedRm.name}';
//       userRmId.value = matchedRm.id;
//
//       print("RM matched successfully:");
//       print("  Name : ${matchedRm.name}");
//       print("  Email: ${matchedRm.email}");
//       print("  RMID : ${matchedRm.rmid}");
//       print("  ID   : ${matchedRm.id}");
//       print("  Total RMs in dropdown: ${rmList.length}");
//     } on AppExceptions catch (e) {
//       print("RM list fetch error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected error fetching RM list: $e");
//       AppAlerts.error("Failed to load RM data.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> getClientList() async {
//     try {
//       isLoading.value = true;
//       currentPage.value = 1;
//       clients.clear();
//
//       final response = await _clientService.getClient(
//         rmId: userRmId.value,
//         page: currentPage.value,
//       );
//       final clientModel = ClientModel.fromJson(response);
//
//       totalClients.value = clientModel.usersList.total;
//       lastPage.value = clientModel.usersList.lastPage;
//       currentPage.value = clientModel.usersList.currentPage;
//       clients.addAll(clientModel.usersList.data);
//       hasMoreData.value = currentPage.value < lastPage.value;
//
//       print("Clients fetched: ${clients.length} / ${totalClients.value}");
//     } on AppExceptions catch (e) {
//       print("Client list fetch error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected error fetching clients: $e");
//       AppAlerts.error("Failed to load client list.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadMoreClients() async {
//     if (isLoadingMore.value || !hasMoreData.value) return;
//
//     try {
//       isLoadingMore.value = true;
//       currentPage.value++;
//
//       final response = await _clientService.getClient(
//         rmId: userRmId.value,
//         page: currentPage.value,
//       );
//       final clientModel = ClientModel.fromJson(response);
//
//       clients.addAll(clientModel.usersList.data);
//       hasMoreData.value = currentPage.value < lastPage.value;
//
//       print("More clients loaded. Total: ${clients.length}");
//     } on AppExceptions catch (e) {
//       currentPage.value--;
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       currentPage.value--;
//       AppAlerts.error("Failed to load more clients.");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
//
//   Future<void> refreshClients() async {
//     currentPage.value = 1;
//     clients.clear();
//     await getClientList();
//   }
//
//   String? getRmIdFromName(String displayName) => rmIdMap[displayName];
//
//   RmIDItem? getRmItemById(int id) {
//     try {
//       return rmIdModel.value?.rmidList.firstWhere((item) => item.id == id);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<void> insertClient() async {
//     try {
//       isLoading.value = true;
//
//       final String? rmIdString = getRmIdFromName(rmIdSelected.value);
//       if (rmIdString == null) {
//         AppAlerts.error("RM ID is not set. Please try logging in again.");
//         return;
//       }
//
//       final int rmIdInt = int.parse(rmIdString);
//
//       final Map<String, dynamic> data = {
//         "first_name": firstName.value.text.trim(),
//         "last_name": lastName.value.text.trim(),
//         "email": email.value.text.trim(),
//         "phone_number": phoneNumber.value,
//         "country_code": countryCode.value,
//         "rm_id": rmIdInt,
//         "univercity_name": universityName.value.text.trim(),
//       };
//
//       print("Submitting client data: $data");
//
//       final response = await _clientService.insertClient(data);
//       final insertResponse = InsertClientModel.fromJson(response);
//
//       if (insertResponse.status == 200) {
//         _clearForm();
//         await refreshClients();
//         Navigator.of(Get.context!).pop();
//         Future.delayed(const Duration(milliseconds: 200), () {
//           AppAlerts.success(insertResponse.message);
//         });
//       } else {
//         AppAlerts.error(insertResponse.message);
//       }
//     } on AppExceptions catch (e) {
//       print("Insert client error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected insert client error: $e");
//       AppAlerts.error("Failed to add client.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void _clearForm() {
//     firstName.value.clear();
//     lastName.value.clear();
//     email.value.clear();
//     universityName.value.clear();
//     phoneNumber.value = "";
//     countryCode.value = "";
//   }
//
//   RxList<String> items = <String>[].obs;
//   RxList<String> filteredItems = <String>[].obs;
//
//   void setItems(List<String> data) {
//     items.value = data;
//     filteredItems.value = data;
//   }
//
//   void search(String query) {
//     if (query.isEmpty) {
//       filteredItems.value = List.from(items);
//     } else {
//       filteredItems.value = items
//           .where((e) => e.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     }
//   }
//
// // Loads all pages of clients for use in order form dropdown
//   Future<void> getAllClientsForDropdown() async {
//     if (isLoading.value) return;
//
//     try {
//       isLoading.value = true;
//       clients.clear();
//
//       int page = 1;
//       bool hasMore = true;
//
//       while (hasMore) {
//         final response = await _clientService.getClient(
//           rmId: userRmId.value,
//           page: page,
//         );
//         final model = ClientModel.fromJson(response);
//         clients.addAll(model.usersList.data);
//         hasMore = page < model.usersList.lastPage;
//         page++;
//       }
//
//       print("All clients loaded for dropdown: ${clients.length}");
//     } catch (e) {
//       print("Failed to load all clients for dropdown: $e");
//       AppAlerts.error("Failed to load client list.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }