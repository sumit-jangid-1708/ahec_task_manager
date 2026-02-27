import 'package:ahec_task_manager/data/network/network_api_service.dart';
import '../../res/app_url/app_url.dart';

class ListService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> serviceList() async{
    final response = await _apiServices.getApi(AppUrl.serviceList);
    return response;
  }

  Future<dynamic> currencyList() async{
    final response = await _apiServices.getApi(AppUrl.currencyList);
    return response;
  }

  Future<dynamic>rmList() async {
    final response = await _apiServices.getApi(AppUrl.rmIdList);
    return response;
  }
}