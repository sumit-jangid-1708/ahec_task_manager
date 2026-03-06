import 'package:ahec_task_manager/model/dashboard_data_model.dart';
import 'package:ahec_task_manager/view_models/controller/base_controller.dart';
import 'package:ahec_task_manager/view_models/services/dashboard_service.dart';
import 'package:get/get.dart';
import '../../data/app_exceptions.dart';
import '../../model/dashboard_response_model.dart';
import 'list_controller.dart';
class DashboardController extends GetxController with BaseController {
  final DashboardService _dashboardService = DashboardService();
  final ListController _listController = Get.find<ListController>();

  final dashboardData = Rx<DashboardDataModel?>(null);

  // ✅ FIXED: Changed from RxList to Rx
  final adminDashboardData = Rx<DashboardResponseModel?>(null);

  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  final currentYear = DateTime.now().year;

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

    ever(_listController.userRmId, (int rmId) {
      if (rmId != 0) getAdminDashboardData(); // ✅ Changed to new API
    });

    if (_listController.userRmId.value != 0) {
      getAdminDashboardData(); // ✅ Changed to new API
    }
  }

  void changeTab(int index) => selectedIndex.value = index;

  /// ✅ New API - Admin Dashboard
  Future<void> getAdminDashboardData() async {
    final int rmId = _listController.userRmId.value;

    if (rmId == 0) {
      print("Dashboard load skipped: RM ID not yet resolved.");
      return;
    }

    final Map<String, dynamic> data = {
      "year": currentYear,
      "rm_id": rmId
    };

    try {
      isLoading.value = true;
      final response = await _dashboardService.getAdminDashboardData(data);

      // ✅ FIXED: Assign directly to .value
      adminDashboardData.value = DashboardResponseModel.fromJson(response);

      print("✅ Admin Dashboard data loaded successfully.");
    } on AppExceptions catch (e) {
      handleError(e.cleanMessage);
    } catch (e) {
      handleError("Failed to load dashboard data.");
      print("❌ Dashboard Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async => await getAdminDashboardData();

  // ✅ Getters for Summary Data (from adminDashboardData)
  String get weekInr => adminDashboardData.value?.data.summary.weekInr.toString() ?? "0";
  String get weekAud => adminDashboardData.value?.data.summary.weekAud.toStringAsFixed(2) ?? "0.00";
  String get monthInr => adminDashboardData.value?.data.summary.monthInr.toString() ?? "0";
  String get monthAud => adminDashboardData.value?.data.summary.monthAud.toStringAsFixed(2) ?? "0.00";

  // ✅ Word Count getters
  int get weekWordCount => adminDashboardData.value?.data.summary.weekWordCount ?? 0;
  int get monthWordCount => adminDashboardData.value?.data.summary.monthWordCount ?? 0;

  // ✅ Chart data getters
  List<String> get monthNames =>
      adminDashboardData.value?.data.monthlyAudOrders.monthNames ?? [];

  List<double> get audAmounts =>
      adminDashboardData.value?.data.monthlyAudOrders.audAmounts ?? [];

  List<int> get orderCounts =>
      adminDashboardData.value?.data.monthlyAudOrders.orderCounts ?? [];
}