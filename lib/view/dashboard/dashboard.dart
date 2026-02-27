import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/dashboard_controller.dart';
import '../client/client_screen.dart';
import '../home_screen/home_screen.dart';
import '../orders/order_screen.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      ClientScreen(),
      OrderScreen(),
    ];

    return Obx(() {
      return PopScope(
        // canPop = true only when already on Home tab (index 0)
        // Otherwise intercept back press and go to Home
        canPop: controller.selectedIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            controller.changeTab(0);
          }
        },
        child: Scaffold(
          body: screens[controller.selectedIndex.value],
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFF3F63F4),
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: "Clients",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: "Orders",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}