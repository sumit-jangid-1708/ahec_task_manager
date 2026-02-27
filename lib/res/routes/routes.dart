import 'package:ahec_task_manager/bindings/dashboard_binding.dart';
import 'package:ahec_task_manager/res/routes/routes_names.dart';
import 'package:ahec_task_manager/view/client/client_screen.dart';
import 'package:get/get.dart';

import '../../bindings/auth_binding.dart';
import '../../view/auth/applock_screen.dart';
import '../../view/auth/auth_screen.dart';
import '../../view/dashboard/dashboard.dart';
import '../../view/home_screen/home_screen.dart';
import '../../view/orders/order_screen.dart';

class AppRoutes {
  static List<GetPage> appRoute() => [
    GetPage(
      name: RouteName.auth,
      page: () => AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: RouteName.dashboard,
      page: () => Dashboard(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: RouteName.appLockScreen,
      page: () => AppLockScreen(),
    ),
    GetPage(name: RouteName.homeScreen, page: () => HomeScreen()),
    GetPage(name: RouteName.orderScreen, page: () => OrderScreen()),
    GetPage(name: RouteName.clientScreen, page: () => ClientScreen()),
  ];
}
