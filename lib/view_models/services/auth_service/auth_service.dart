import '../../../data/network/network_api_service.dart';
import '../../../res/app_url/app_url.dart';

class AuthService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic>loginApi(Map<String, dynamic> data) async {
    dynamic response = await _apiServices.postApi(data, AppUrl.login);
    return response;
  }
}
