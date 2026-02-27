import 'package:ahec_task_manager/res/components/widgets/app_dialog.dart';
import 'package:ahec_task_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/components/widgets/monthly_chart.dart';
import '../../view_models/controller/auth/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Small tile widget
  Widget statTile({
    required Color color,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),

          // ICON FIX
          Flexible(
            child: Icon(icon, size: 38, color: Colors.white30),
          ),
        ],
      ),
    );
  }


  // Large tile widget
  Widget largeTile({
    required Color color,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          Flexible(
            child: Icon(icon, size: 50, color: Colors.white70),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF3F63F4),
          automaticallyImplyLeading: false,
          elevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              "assets/images/footer-logo.png",
              height: 40,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                // onPressed: (){
                //   AppDialog.confirm(
                //       message: "Are you sure you want to Logout?",
                //       onConfirm:()=> Get.find<AuthController>().logout(),
                //   );
                // },
                onPressed: () => Get.find<AuthController>().logout(),
              ),
            ),
          ],
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value && controller.dashboardData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3F63F4)),
          );
        }
        return RefreshIndicator(
          color: const Color(0xFF3F63F4),
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ----------- SMALL TILES ROW 1 ----------
                Row(
                  children: [
                    Expanded(
                      child: statTile(
                        color: Colors.cyan,
                        value: "\$${controller.monthAud}",
                        label: "${controller.currentMonth} AUD",
                        icon: Icons.school,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: statTile(
                        color: Colors.green,
                        value: "₹${controller.monthInr}",
                        label: "${controller.currentMonth} INR",
                        icon: Icons.book,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ----------- SMALL TILES ROW 2 ----------
                Row(
                  children: [
                    Expanded(
                      child: statTile(
                        color: Colors.orange,
                        value: "\$${controller.weekAud}",
                        label: "This Week AUD",
                        icon: Icons.person_add,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: statTile(
                        color: Colors.red,
                        value: "₹${controller.weekInr}",
                        label: "This Week INR",
                        icon: Icons.group,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ----------- LARGE TILE 1 ----------
                largeTile(
                  color: Colors.lightBlue,
                  value: "22600",
                  label: "This Week Word Count",
                  icon: Icons.description,
                ),

                const SizedBox(height: 16),

                // ----------- LARGE TILE 2 ----------
                largeTile(
                  color: Colors.amber,
                  value: "44100",
                  label: "November Word Count",
                  icon: Icons.description,
                ),
                const SizedBox(height: 25),
                MonthlyChart(),
              ],
            ),
          ),
        );
      })

    );
  }
}
