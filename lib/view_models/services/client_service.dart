import 'package:ahec_task_manager/data/network/network_api_service.dart';
import '../../res/app_url/app_url.dart';

class ClientService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  // Pagination support ke saath
  Future<dynamic> getClient({required int rmId, int page = 1}) async {
    final response = await _apiServices.getApi(
      '${AppUrl.clientList}/$rmId?page=$page',
    );
    return response;
  }



  Future<dynamic> insertClient(data) async {
    final response = await _apiServices.postApi(data, AppUrl.addClient);
    return response;
  }
}
