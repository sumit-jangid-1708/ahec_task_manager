import 'dart:io';
import 'package:ahec_task_manager/data/network/network_api_service.dart';
import '../../res/app_url/app_url.dart';

class OrderService {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getOrders({required int rmId, int page = 1}) async {
    return await _apiServices.getApi('${AppUrl.orderList}/$rmId?page=$page');
  }

  Future<dynamic> addOrder(
      Map<String, dynamic> data, {
        File? paymentImage,
      }) async {
    if (paymentImage != null) {
      final Map<String, String> fields =
      data.map((key, value) => MapEntry(key, value.toString()));

      return await _apiServices.multipartApi(
        AppUrl.createOrder,
        fields,
        file: paymentImage,
        fileField: 'Screenshot',
      );
    } else {

      return await _apiServices.postApi(data, AppUrl.createOrder);
    }
  }
}