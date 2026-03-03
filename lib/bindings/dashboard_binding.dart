import 'package:get/get.dart';
import '../view_models/controller/auth/auth_controller.dart';
import '../view_models/controller/client_controller.dart';
import '../view_models/controller/dashboard_controller.dart';
import '../view_models/controller/list_controller.dart';
import '../view_models/controller/order_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ListController());
    Get.put(ClientController());
    Get.put(OrderController());
    Get.put(DashboardController());
  }
}
// class DashboardBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.put(ListController());
//     Get.put(ClientController());
//     Get.put(OrderController());
//
//   }
// }