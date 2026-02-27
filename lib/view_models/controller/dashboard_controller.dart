import 'package:ahec_task_manager/model/dashboard_data_model.dart';
import 'package:ahec_task_manager/view_models/services/dashboard_service.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../res/components/app_alerts.dart';
import 'list_controller.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final ListController _listController = Get.find<ListController>(); // CHANGED

  final dashboardData = Rx<DashboardDataModel?>(null);
  var selectedIndex = 0.obs;
  var isLoading = false.obs;

  String get currentMonth {
    const months = [
      "January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December",
    ];
    return months[DateTime.now().month - 1];
  }

  @override
  void onInit() {
    super.onInit();

    ever(_listController.userRmId, (int rmId) { // CHANGED
      if (rmId != 0) getDashboardData();
    });

    if (_listController.userRmId.value != 0) { // CHANGED
      getDashboardData();
    }
  }

  void changeTab(int index) => selectedIndex.value = index;

  Future<void> getDashboardData() async {
    final int rmId = _listController.userRmId.value; // CHANGED

    if (rmId == 0) {
      print("Dashboard load skipped: RM ID not yet resolved.");
      return;
    }

    try {
      isLoading.value = true;
      final response = await _dashboardService.getDashboardData(rmId);
      dashboardData.value = DashboardDataModel.fromJson(response);
      print("Dashboard data loaded successfully.");
    } on AppExceptions catch (e) {
      AppAlerts.error(e.cleanMessage);
    } catch (e) {
      AppAlerts.error("Failed to load dashboard data.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async => await getDashboardData();

  String get weekInr => dashboardData.value?.data.weekTotalAmount.inr ?? "0.00";
  String get weekAud => dashboardData.value?.data.weekTotalAmount.aud ?? "0.00";
  String get monthInr => dashboardData.value?.data.monthTotalCurrencyAmount.inr ?? "0.00";
  String get monthAud => dashboardData.value?.data.monthTotalCurrencyAmount.aud ?? "0.00";
}


// import 'package:ahec_task_manager/model/dashboard_data_model.dart';
// import 'package:ahec_task_manager/view_models/services/dashboard_service.dart';
// import 'package:get/get.dart';
//
// import '../../data/app_exceptions.dart';
// import '../../res/components/app_alerts.dart';
// import 'client_controller.dart';
//
// class DashboardController extends GetxController {
//   final DashboardService _dashboardService = DashboardService();
//   final ClientController _clientController = Get.find<ClientController>();
//
//   final dashboardData = Rx<DashboardDataModel?>(null);
//   var selectedIndex = 0.obs;
//   // var currentMonth = ''.obs;
//   var isLoading = false.obs;
//
//   String get currentMonth {
//     const months = [
//       "January", "February", "March", "April",
//       "May", "June", "July", "August",
//       "September", "October", "November", "December",
//     ];
//
//     return months[DateTime.now().month - 1];
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     // _setCurrentMonth();
//
//     // Auto-load dashboard once RM ID is resolved
//     ever(_clientController.userRmId, (int rmId) {
//       if (rmId != 0) {
//         getDashboardData();
//       }
//     });
//
//     // Load immediately if RM ID already available
//     if (_clientController.userRmId.value != 0) {
//       getDashboardData();
//     }
//   }
//
//   void changeTab(int index) {
//     selectedIndex.value = index;
//   }
//
//   // void _setCurrentMonth() {
//   //   const months = [
//   //     "January", "February", "March", "April",
//   //     "May", "June", "July", "August",
//   //     "September", "October", "November", "December",
//   //   ];
//   //   currentMonth.value = months[DateTime.now().month - 1];
//   //   print(currentMonth);
//   // }
//
//   Future<void> getDashboardData() async {
//     final int rmId = _clientController.userRmId.value;
//
//     if (rmId == 0) {
//       print("Dashboard load skipped: RM ID not yet resolved.");
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       final response = await _dashboardService.getDashboardData(rmId);
//       dashboardData.value = DashboardDataModel.fromJson(response);
//
//       print("Dashboard data loaded successfully.");
//     } on AppExceptions catch (e) {
//       print("Dashboard fetch error: $e");
//       AppAlerts.error(e.cleanMessage);
//     } catch (e) {
//       print("Unexpected dashboard error: $e");
//       AppAlerts.error("Failed to load dashboard data.");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> refreshDashboard() async {
//     await getDashboardData();
//   }
//
//   // Convenience getters for UI
//   String get weekInr => dashboardData.value?.data.weekTotalAmount.inr ?? "0.00";
//   String get weekAud => dashboardData.value?.data.weekTotalAmount.aud ?? "0.00";
//   String get monthInr => dashboardData.value?.data.monthTotalCurrencyAmount.inr ?? "0.00";
//   String get monthAud => dashboardData.value?.data.monthTotalCurrencyAmount.aud ?? "0.00";
// }