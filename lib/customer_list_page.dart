import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_customer_page.dart';
import 'utils/customer_controller.dart';


// Main Page using GetX
class CustomerListPage extends StatelessWidget {
  final CustomerController controller = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(
        () => controller.customers.isEmpty
            ? const Center(child: Text("No Customers Found"))
            : ListView.builder(
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return ListTile(
                    leading: customer['image'] != ''
                        ? Image.file(File(customer['image']),
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 50),
                    title: Text(customer['name']),
                    subtitle: Text(
                      "Phone No: ${customer['phone']}\n"
                      "Email: ${customer['email']}\n"
                      "Address: ${customer['address']}\n"
                      "Geo Address: ${customer['geoAddress']}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () => controller.openGoogleMaps(
                          customer['latitude'].toString(), customer['longitude'].toString()),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddCustomerPage()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
