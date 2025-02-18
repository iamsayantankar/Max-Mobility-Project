import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/permissions.dart';
import 'login_page.dart';
import 'customer_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPermissions.requestAllPermissions();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer App',
      home: isLoggedIn ? CustomerListPage() : LoginPage(),
    );
  }
}
