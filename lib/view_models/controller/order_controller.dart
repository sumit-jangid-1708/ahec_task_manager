import 'dart:io';
import 'package:ahec_task_manager/model/order_model.dart';
import 'package:ahec_task_manager/res/components/app_alerts.dart';
import 'package:ahec_task_manager/view_models/controller/base_controller.dart';
import 'package:ahec_task_manager/view_models/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../model/add_order_model.dart';
import '../../model/client_model.dart';
import 'auth/auth_controller.dart';
import 'client_controller.dart';
import 'list_controller.dart';

class OrderController extends GetxController with BaseController {
  final AuthController _authController = Get.find<AuthController>();
  final ClientController _clientController = Get.find<ClientController>();
  final ListController _listController = Get.find<ListController>(); // ADD
  final OrderService _orderService = OrderService();
  // Exposes full RM list from ClientController for the RM dropdown
  List<String> get rmList => _listController.rmList;

  // Order form text controllers
  final moduleCode = TextEditingController();
  final moduleName = TextEditingController();
  final deadline = TextEditingController();
  final wordCount = TextEditingController(text: "0");
  final type = TextEditingController();
  final clientAmount = TextEditingController();
  final audAmount = TextEditingController();
  final inrAmount = TextEditingController();
  final shortNote = TextEditingController();
  final transactionId = TextEditingController();

  // Dropdown selected values
  var clientDropdownList = <String>[].obs;
  var clientSelected = "Select Client".obs;
  var paymentTypeSelected = "Select payment type".obs;
  var orderTypeSelected = "Select Order Type".obs;
  var serviceTypeSelected = "Service Type".obs;
  var currencySelected = "Currency".obs;
  var rmIdSelected = "".obs;
  var orderIdSelected = "Select Order ID".obs;

  // Dropdown static lists
  final orderIdList = <String>[].obs;
  final paymentTypeList = [
    "Full Payment",
    "Partial Payment",
    "Remaining Payment",
  ];
  final orderTypeList = ["New Order", "Existing Order"];

  // Payment screenshot
  Rx<File?> paymentImage = Rx<File?>(null);

  // Order list
  final orders = <OrderData>[].obs;
  var filteredOrders = <OrderData>[].obs;
  var isSearching = false.obs;

  // Loading states
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // Pagination
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var totalOrders = 0.obs;
  var hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    rmIdSelected.value = _listController.rmIdSelected.value;
    ever(_listController.rmIdSelected, (String value) {
      if (rmIdSelected.value.isEmpty) {
        rmIdSelected.value = value;
      }
    });
    // // Sync RM selection - default to logged-in user's RM
    // rmIdSelected.value = _clientController.rmIdSelected.value;
    // ever(_clientController.rmIdSelected, (String value) {
    //   if (rmIdSelected.value.isEmpty) {
    //     rmIdSelected.value = value;
    //   }
    // });

    // Rebuild client dropdown whenever client list changes
    ever(_clientController.clients, (_) => _updateClientDropdown());
    if (_clientController.clients.isNotEmpty) _updateClientDropdown();
    // ever(_clientController.clients, (_) => _updateClientDropdown());
    // if (_clientController.clients.isNotEmpty) {
    //   _updateClientDropdown();
    // }

    // Auto-load orders once RM ID is resolved.
    // Uses ever() to react when ClientController resolves userRmId asynchronously.
    ever(_listController.userRmId, (int rmId) {
      if (rmId != 0 && orders.isEmpty) {
        getOrderList();
      }
    });
    // ever(_clientController.userRmId, (int rmId) {
    //   if (rmId != 0 && orders.isEmpty) {
    //     print("RM ID resolved ($rmId). Auto-loading orders.");
    //     getOrderList();
    //   }
    // });

    // Load immediately if RM ID is already available (e.g., app resume)
    if (_listController.userRmId.value != 0) {
      getOrderList();
    }
    // if (_clientController.userRmId.value != 0) {
    //   getOrderList();
    // }
  }

  @override
  void onClose() {
    moduleCode.dispose();
    moduleName.dispose();
    deadline.dispose();
    wordCount.dispose();
    type.dispose();
    clientAmount.dispose();
    audAmount.dispose();
    inrAmount.dispose();
    shortNote.dispose();
    transactionId.dispose();
    super.onClose();
  }

  // Returns ClientData object matching the selected dropdown string.
  // Matching is done via the same format used to build the dropdown: "${userName} (${mobile})"
  ClientData? getSelectedClientObject() {
    if (clientSelected.value == "Select Client") return null;
    try {
      return _clientController.clients.firstWhere(
        (client) =>
            "${client.userName.trim()} (${client.mobile.trim()})" ==
            clientSelected.value,
      );
    } catch (_) {
      print("Selected client not found in list: ${clientSelected.value}");
      return null;
    }
  }

  // Resolves the integer RM ID from the selected RM display string.
  // Falls back to the logged-in user's RM ID if no match found.
  int get selectedRmId {
    final String? idStr = _listController.rmIdMap[rmIdSelected.value];
    return int.tryParse(idStr ?? '') ?? _listController.userRmId.value;
  }
  // int get selectedRmId {
  //   final String? idStr = _clientController.rmIdMap[rmIdSelected.value];
  //   return int.tryParse(idStr ?? '') ?? _clientController.userRmId.value;
  // }

  void _updateClientDropdown() {
    final Set<String> seen = {};
    clientDropdownList.value = _clientController.clients
        .map((c) => "${c.userName.trim()} (${c.mobile.trim()})")
        .where(seen.add)
        .toList();

    if (clientDropdownList.isEmpty) {
      clientDropdownList.add("No clients available");
    }
    print("Client dropdown updated: ${clientDropdownList.length} items");
  }

  void searchOrders(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      filteredOrders.clear();
      return;
    }
    isSearching.value = true;
    filteredOrders.value = orders.where((order) {
      final q = query.toLowerCase();
      return order.clientName.toLowerCase().contains(q) ||
          order.orderNumber.toLowerCase().contains(q) ||
          order.servicesName.toLowerCase().contains(q) ||
          order.paymentType.toLowerCase().contains(q) ||
          order.enId.toString().contains(q);
    }).toList();
  }

  List<OrderData> get displayOrders =>
      isSearching.value ? filteredOrders : orders;

  Future<void> getOrderList() async {
    final int rmId = _listController.userRmId.value;
    // final int rmId = _clientController.userRmId.value;
    if (rmId == 0) {
      print("Order list skipped: RM ID not yet resolved.");
      return;
    }

    try {
      isLoading.value = true;
      currentPage.value = 1;
      orders.clear();

      final response = await _orderService.getOrders(
        page: currentPage.value,
        rmId: rmId,
      );

      final orderModel = OrderModel.fromJson(response);
      totalOrders.value = orderModel.usersList.total;
      lastPage.value = orderModel.usersList.lastPage;
      currentPage.value = orderModel.usersList.currentPage;
      orders.addAll(orderModel.usersList.data);
      hasMoreData.value = currentPage.value < lastPage.value;

      print("Orders fetched: ${orders.length} / ${totalOrders.value}");
    } on AppExceptions catch (e) {
      print("Order list fetch error: $e");
      handleError(e);
    } catch (e) {
      print("Unexpected error fetching orders: $e");
      handleError("Failed to load order list.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMoreData.value) return;
    final int rmId = _listController.userRmId.value;
    // final int rmId = _clientController.userRmId.value;
    if (rmId == 0) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _orderService.getOrders(
        page: currentPage.value,
        rmId: rmId,
      );
      final orderModel = OrderModel.fromJson(response);
      orders.addAll(orderModel.usersList.data);
      hasMoreData.value = currentPage.value < lastPage.value;

      print("More orders loaded. Total: ${orders.length}");
    } on AppExceptions catch (e) {
      currentPage.value--;
      handleError(e);
    } catch (e) {
      currentPage.value--;
      handleError("Failed to load more orders.");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshOrders() async {
    currentPage.value = 1;
    orders.clear();
    await getOrderList();
  }

  bool validateForm() {
    if (clientSelected.value == "Select Client") {
      AppAlerts.error("Please select a client.");
      return false;
    }
    if (orderTypeSelected.value == "Select Order Type") {
      AppAlerts.error("Please select an order type.");
      return false;
    }
    if (paymentTypeSelected.value == "Select payment type") {
      AppAlerts.error("Please select a payment type.");
      return false;
    }
    if (serviceTypeSelected.value == "Service Type") {
      AppAlerts.error("Please select a service type.");
      return false;
    }
    if (moduleName.text.trim().isEmpty) {
      AppAlerts.error("Please enter a module name.");
      return false;
    }
    if (deadline.text.trim().isEmpty) {
      AppAlerts.error("Please select a deadline.");
      return false;
    }
    if (currencySelected.value == "Currency") {
      AppAlerts.error("Please select a currency.");
      return false;
    }
    if (clientAmount.text.trim().isEmpty) {
      AppAlerts.error("Please enter the client amount.");
      return false;
    }
    return true;
  }

  void resetForm() {
    moduleCode.clear();
    moduleName.clear();
    deadline.clear();
    wordCount.text = "0";
    type.clear();
    clientAmount.clear();
    audAmount.clear();
    inrAmount.clear();
    shortNote.clear();
    transactionId.clear();
    clientSelected.value = "Select Client";
    paymentTypeSelected.value = "Select payment type";
    orderTypeSelected.value = "Select Order Type";
    serviceTypeSelected.value = "Service Type";
    currencySelected.value = "Currency";
    orderIdSelected.value = "Select Order ID";
    paymentImage.value = null;
  }

  String _formatDeadline(String input) {
    try {
      final parts = input.split('-');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
      return input;
    } catch (_) {
      return input;
    }
  }

  Future<void> submitOrder() async {
    if (!validateForm()) return;
    final ClientData? client = getSelectedClientObject();
    if (client == null) {
      handleError("Selected client not found. Please reselect.");
      return;
    }
    final int rmId = selectedRmId;
    if (rmId == 0) {
      handleError("RM ID is not set. Please select an RM.");
      return;
    }
    final String? serviceId = _listController.getServiceIdFromName(
      serviceTypeSelected.value,
    );
    if (serviceId == null) {
      handleError("Invalid service selected. Please reselect.");
      return;
    }
    // Currency ID (int) chahiye - "AUD" nahi
    final int? currencyId = _listController.getCurrencyIdFromName(
      currencySelected.value,
    );
    if (currencyId == null) {
      handleError("Invalid currency selected. Please reselect.");
      return;
    }
    // order_type DB mein int hai
    final Map<String, int> orderTypeMap = {"New Order": 1, "Existing Order": 2};
    final int orderTypeInt = orderTypeMap[orderTypeSelected.value] ?? 1;
    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {
        "user_email": client.userEmail,
        "rm_id": rmId,
        "univercity_name": client.univercityName,
        "order_type": orderTypeInt, // ✅ int
        "payment_type": paymentTypeSelected.value,
        "en_service": int.tryParse(serviceId) ?? serviceId, // ✅ int
        "modal_en_subject": moduleCode.text.trim(),
        "modal_en_module_name": moduleName.text.trim(),
        "deadline": _formatDeadline(deadline.text.trim()),
        "word_count": int.tryParse(wordCount.text.trim()) ?? 0,
        "assignment_type": type.text.trim(),
        "currency_type": currencyId, // ✅ int, not "AUD"
        "client_amount": double.tryParse(clientAmount.text.trim()) ?? 0,
        "inr_amount": double.tryParse(inrAmount.text.trim()) ?? 0,
        "aud_amount": double.tryParse(audAmount.text.trim()) ?? 0,
        "modal_en_query": shortNote.text.trim(),
        "tranxid": transactionId.text.trim(),
      };
      if (orderTypeSelected.value == "Existing Order" &&
          orderIdSelected.value != "Select Order ID") {
        data["pre_order_id"] = orderIdSelected.value;
      }
      print("Submitting order: $data");
      final response = await _orderService.addOrder(
        data,
        paymentImage: paymentImage.value,
      );
      final addOrderModel = AddOrderModel.fromJson(response);
      if (addOrderModel.status == 200 || addOrderModel.status == 201) {
        handleSuccess(addOrderModel.message);
        resetForm();
        rmIdSelected.value = _listController.rmIdSelected.value;
        await refreshOrders();
        Get.back();
      } else {
        AppAlerts.error(addOrderModel.message);
      }
    } on AppExceptions catch (e) {
      print("Submit order error: $e");
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      print("Unexpected submit order error: $e");
      AppAlerts.error("Failed to create order.");
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderData> getOrdersByPaymentType(String paymentType) =>
      orders.where((o) => o.paymentType == paymentType).toList();

  List<OrderData> getTodaysOrders() {
    final today = DateTime.now();
    final todayStr =
        "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
    return orders.where((o) => o.orderDate == todayStr).toList();
  }
}

// import 'dart:io';
// import 'package:ahec_task_manager/model/order_model.dart';
// import 'package:ahec_task_manager/res/components/app_alerts.dart';
// import 'package:ahec_task_manager/view_models/services/order_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../data/app_exceptions.dart';
// import '../../model/client_model.dart';
// import 'auth/auth_controller.dart';
// import 'client_controller.dart';
//
// class OrderController extends GetxController {
//   final AuthController _authController = Get.find<AuthController>();
//   final ClientController _clientController = Get.find<ClientController>();
//   final OrderService _orderService = OrderService();
//   List<String> get rmList => _clientController.rmList;
//   // Order form controllers
//   final moduleCode = TextEditingController();
//   final moduleName = TextEditingController();
//   final deadline = TextEditingController();
//   final wordCount = TextEditingController(text: "0");
//   final type = TextEditingController();
//   final clientAmount = TextEditingController();
//   final audAmount = TextEditingController();
//   final inrAmount = TextEditingController();
//   final shortNote = TextEditingController();
//   final transactionId = TextEditingController();
//
//   // Dropdown selections
//   var clientDropdownList = <String>[].obs;
//   var clientSelected = "Select Client".obs;
//   var paymentTypeSelected = "Select payment type".obs;
//   var orderTypeSelected = "Select Order Type".obs;
//   var serviceTypeSelected = "Service Type".obs;
//   var currencySelected = "Currency".obs;
//   var rmIdSelected = "".obs;
//
//   var orderIdSelected = "Select Order ID".obs;
//   final orderIdList = <String>[].obs;
//
//   final paymentTypeList = ["Full Payment", "Partial Payment", "Remaining Payment"];
//   final orderTypeList = ["New Order", "Existing Order"];
//
//   Rx<File?> paymentImage = Rx<File?>(null);
//
//   // Order list
//   final orders = <OrderData>[].obs;
//   var filteredOrders = <OrderData>[].obs;
//   var isSearching = false.obs;
//
//   // Loading states
//   var isLoading = false.obs;
//   var isLoadingMore = false.obs;
//
//   // Pagination
//   var currentPage = 1.obs;
//   var lastPage = 1.obs;
//   var totalOrders = 0.obs;
//   var hasMoreData = true.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // Sync RM selection from ClientController
//     rmIdSelected.value = _clientController.rmIdSelected.value;
//     ever(_clientController.rmIdSelected, (String value) {
//       if (rmIdSelected.value.isEmpty) {
//         rmIdSelected.value = value;
//       }
//     });
//
//     // Build client dropdown whenever the client list updates
//     ever(_clientController.clients, (_) => _updateClientDropdown());
//     if (_clientController.clients.isNotEmpty) {
//       _updateClientDropdown();
//     }
//
//     // Auto-load orders as soon as userRmId becomes available.
//     // This fixes the issue where orders required a manual refresh.
//     ever(_clientController.userRmId, (int rmId) {
//       if (rmId != 0 && orders.isEmpty) {
//         print("RM ID resolved ($rmId). Auto-loading orders.");
//         getOrderList();
//       }
//     });
//
//     // If RM ID is already available (e.g., app resumed), load immediately
//     if (_clientController.userRmId.value != 0) {
//       getOrderList();
//     }
//   }
//
//   ClientData? getSelectedClientObject() {
//     if (clientSelected.value == "Select Client") return null;
//
//     try {
//       return _clientController.clients.firstWhere(
//             (client) =>
//         "${client.userName.trim()} (${client.mobile.trim()})" ==
//             clientSelected.value,
//       );
//     } catch (e) {
//       print("Selected client not found in list: ${clientSelected.value}");
//       return null;
//     }
//   }
//
//   // Returns the RM ID (int) for the currently selected RM display text
//   int get selectedRmId {
//     final String? idStr = _clientController.rmIdMap[rmIdSelected.value];
//     return int.tryParse(idStr ?? '') ?? _clientController.userRmId.value;
//   }
//
//   @override
//   void onClose() {
//     moduleCode.dispose();
//     moduleName.dispose();
//     deadline.dispose();
//     wordCount.dispose();
//     type.dispose();
//     clientAmount.dispose();
//     audAmount.dispose();
//     inrAmount.dispose();
//     shortNote.dispose();
//     transactionId.dispose();
//     super.onClose();
//   }
//
//   void _updateClientDropdown() {
//     final Set<String> seen = {};
//     clientDropdownList.value = _clientController.clients
//         .map((c) => "${c.userName.trim()} (${c.mobile.trim()})")
//         .where(seen.add)
//         .toList();
//
//     if (clientDropdownList.isEmpty) {
//       clientDropdownList.add("No clients available");
//     }
//
//     print("Client dropdown updated: ${clientDropdownList.length} items");
//   }
//
//   void searchOrders(String query) {
//     if (query.isEmpty) {
//       isSearching.value = false;
//       filteredOrders.clear();
//       return;
//     }
//     isSearching.value = true;
//     filteredOrders.value = orders.where((order) {
//       final q = query.toLowerCase();
//       return order.clientName.toLowerCase().contains(q) ||
//           order.orderNumber.toLowerCase().contains(q) ||
//           order.servicesName.toLowerCase().contains(q) ||
//           order.paymentType.toLowerCase().contains(q) ||
//           order.enId.toString().contains(q);
//     }).toList();
//   }
//
//   List<OrderData> get displayOrders =>
//       isSearching.value ? filteredOrders : orders;
//
//   Future<void> getOrderList() async {
//     final int rmId = _clientController.userRmId.value;
//
//     if (rmId == 0) {
//       print("Order list skipped: RM ID not yet resolved.");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//       currentPage.value = 1;
//       orders.clear();
//
//       final response = await _orderService.getOrders(
//         page: currentPage.value,
//         rmId: rmId,
//       );
//
//       final orderModel = OrderModel.fromJson(response);
//
//       totalOrders.value = orderModel.usersList.total;
//       lastPage.value = orderModel.usersList.lastPage;
//       currentPage.value = orderModel.usersList.currentPage;
//       orders.addAll(orderModel.usersList.data);
//       hasMoreData.value = currentPage.value < lastPage.value;
//
//       print("Orders fetched: ${orders.length} / ${totalOrders.value}");
//     } on AppExceptions catch (e) {
//       print("Order list fetch error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected error fetching orders: $e");
//       AppAlerts.error("Failed to load order list.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> loadMoreOrders() async {
//     if (isLoadingMore.value || !hasMoreData.value) return;
//
//     final int rmId = _clientController.userRmId.value;
//     if (rmId == 0) return;
//
//     try {
//       isLoadingMore.value = true;
//       currentPage.value++;
//
//       final response = await _orderService.getOrders(
//         page: currentPage.value,
//         rmId: rmId,
//       );
//       final orderModel = OrderModel.fromJson(response);
//
//       orders.addAll(orderModel.usersList.data);
//       hasMoreData.value = currentPage.value < lastPage.value;
//
//       print("More orders loaded. Total: ${orders.length}");
//     } on AppExceptions catch (e) {
//       currentPage.value--;
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       currentPage.value--;
//       AppAlerts.error("Failed to load more orders.");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }
//
//   Future<void> refreshOrders() async {
//     currentPage.value = 1;
//     orders.clear();
//     await getOrderList();
//   }
//
//   bool validateForm() {
//     if (clientSelected.value == "Select Client") {
//       AppAlerts.error("Please select a client.");
//       return false;
//     }
//     if (moduleName.text.trim().isEmpty) {
//       AppAlerts.error("Please enter a module name.");
//       return false;
//     }
//     if (deadline.text.trim().isEmpty) {
//       AppAlerts.error("Please select a deadline.");
//       return false;
//     }
//     return true;
//   }
//
//   void resetForm() {
//     moduleCode.clear();
//     moduleName.clear();
//     deadline.clear();
//     wordCount.text = "0";
//     type.clear();
//     clientAmount.clear();
//     audAmount.clear();
//     inrAmount.clear();
//     shortNote.clear();
//     transactionId.clear();
//     clientSelected.value = "Select Client";
//     paymentTypeSelected.value = "Select payment type";
//     orderTypeSelected.value = "Select Order Type";
//     serviceTypeSelected.value = "Service Type";
//     currencySelected.value = "Currency";
//     paymentImage.value = null;
//   }
//
//   Future<void> submitOrder() async {
//     if (!validateForm()) return;
//
//     final ClientData? client = getSelectedClientObject();
//     if (client == null) {
//       AppAlerts.error("Selected client not found. Please reselect.");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       final int rmId = selectedRmId;
//       if (rmId == 0) {
//         AppAlerts.error("RM ID is not set. Please select an RM.");
//         return;
//       }
//
//       final Map<String, dynamic> data = {
//         "user_email": client.userEmail,
//         "rm_id": rmId,
//         "univercity_name": client.univercityName,
//         "order_type": orderTypeSelected.value,
//         "payment_type": paymentTypeSelected.value,
//         "en_service": serviceTypeSelected.value,
//         "modal_en_subject": moduleCode.text.trim(),
//         "modal_en_module_name": moduleName.text.trim(),
//         "deadline": deadline.text.trim(),
//         "word_count": wordCount.text.trim(),
//         "assignment_type": type.text.trim(),
//         "currency_type": currencySelected.value,
//         "client_amount": clientAmount.text.trim(),
//         "inr_amount": inrAmount.text.trim(),
//         "aud_amount": audAmount.text.trim(),
//         "modal_en_query": shortNote.text.trim(),
//         "tranxid": transactionId.text.trim(),
//       };
//
//       print("Submitting order with body: $data");
//
//       final response = await _orderService.addOrder(data);
//
//       // Check response status if API returns one
//       final status = response['status'];
//       final message = response['message'] ?? "Order created successfully.";
//
//       if (status == 200 || status == 201) {
//         AppAlerts.success(message);
//         resetForm();
//         rmIdSelected.value = _clientController.rmIdSelected.value;
//         await refreshOrders();
//       } else {
//         AppAlerts.error(message);
//       }
//     } on AppExceptions catch (e) {
//       print("Submit order API error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected submit order error: $e");
//       AppAlerts.error("Failed to create order.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   List<OrderData> getOrdersByPaymentType(String type) =>
//       orders.where((o) => o.paymentType == type).toList();
//
//   List<OrderData> getTodaysOrders() {
//     final today = DateTime.now();
//     final todayStr =
//         "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
//     return orders.where((o) => o.orderDate == todayStr).toList();
//   }
// }
