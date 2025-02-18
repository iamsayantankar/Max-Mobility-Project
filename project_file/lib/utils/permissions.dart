import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<void> requestAllPermissions() async {
    await [
      Permission.location,
      Permission.storage,
    ].request();
  }
}
