import 'package:ahec_task_manager/data/network/network_api_service.dart';
import 'package:ahec_task_manager/res/app_url/app_url.dart';

class DashboardService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getDashboardData (int rmId) async{
    final response = await _apiServices.getApi("${AppUrl.dashboardData}/$rmId");
    return response;
  }

  Future<dynamic> getAdminDashboardData(data) async {
    final response = await _apiServices.postApi(data, AppUrl.adminDashboardData);
    return response;
  }
}