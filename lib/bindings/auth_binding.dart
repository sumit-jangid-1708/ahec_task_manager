import 'package:ahec_task_manager/view_models/controller/list_controller.dart';
import 'package:get/get.dart';
import '../view_models/controller/auth/auth_controller.dart';
import '../view_models/controller/client_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(),);
    // Get.put(ListController(),);
    // Get.put(ClientController());
  }
}
