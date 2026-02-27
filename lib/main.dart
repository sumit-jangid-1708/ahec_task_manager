import 'package:ahec_task_manager/bindings/auth_binding.dart';
import 'package:ahec_task_manager/res/routes/routes.dart';
import 'package:ahec_task_manager/res/routes/routes_names.dart';
import 'package:ahec_task_manager/res/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final storage = GetStorage();
  final token = storage.read(StorageKeys.token);

  String startRoute;

  if (token != null && token.toString().isNotEmpty) {
    startRoute = RouteName.appLockScreen;
  } else {
    startRoute = RouteName.auth;
  }

  runApp(MyApp(startRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      initialBinding: AuthBinding(),
      initialRoute: initialRoute,
      getPages: AppRoutes.appRoute(),
    );
  }
}