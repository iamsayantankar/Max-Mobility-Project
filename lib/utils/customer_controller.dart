import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import '../login_page.dart';


// GetX Controller for managing customer list
class CustomerController extends GetxController {
  var customers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final data = await DatabaseHelper.getCustomers();
    customers.assignAll(data);
  }

  Future<void> addCustomer(Map<String, dynamic> customer) async {
    await DatabaseHelper.insertCustomer(customer);
    customers.add(customer); // Add customer directly to the observable list
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    Get.offAll(() => LoginPage());
  }

  void openGoogleMaps(String latitude, String longitude) async {
    final Uri googleUrl = Uri.parse(
        "google.navigation:q=$latitude,$longitude&mode=d"); // Deep linking for Android

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else {
      final Uri fallbackUrl =
      Uri.parse('https://maps.google.com/?q=$latitude,$longitude');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl);
      } else {
        Get.snackbar("Error", "Could not open the map.");
      }
    }
  }
}
