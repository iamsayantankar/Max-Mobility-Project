import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/customer_controller.dart';

class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _geoAddressController = TextEditingController();

  double? lat;
  double? long;
  String address = "";
  bool geoFetch = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void getLatLong() {
    _determinePosition().then((value) {
      setState(() {
        lat = value.latitude;
        long = value.longitude;
        _latitudeController.text = value.latitude.toString();
        _longitudeController.text = value.longitude.toString();
      });
      getAddress(value.latitude, value.longitude);
    }).catchError((error) {
      print("Error: $error");
    });
  }

  Future<void> getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country} - ${placemarks[0].postalCode}";
      geoFetch = true;
      _geoAddressController.text = address;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedImage = await _saveImageToAppFolder(File(pickedFile.path));
      setState(() {
        _image = savedImage;
      });
    }
  }

  Future<File> _saveImageToAppFolder(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await imageFile.copy(imagePath);
  }

  bool _validateInputs() {
    // bool isValidEmail(String email) {
      String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
      RegExp regex = RegExp(emailPattern);
    //   return regex.hasMatch(email);
    // }

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return false;
    }

    if (!regex.hasMatch(_emailController.text)) {
      Get.snackbar("Error", "Invalid email format");
      return false;
    }

    if (_phoneController.text.length < 10 || _phoneController.text.length > 13) {
      Get.snackbar("Error", "Invalid phone number");
      return false;
    }
    return true;
  }

  Future<void> _saveCustomer() async {
    if (!_validateInputs()) return;

    final customer = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'image': _image?.path ?? '',
      'address': _addressController.text,
      'latitude': _latitudeController.text,
      'longitude': _longitudeController.text,
      'geoAddress': _geoAddressController.text,
    };

    final customerController = Get.find<CustomerController>();
    await customerController.addCustomer(customer); // Add customer & refresh list
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    getLatLong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, width: 100, height: 100),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: const Text("Pick Image")),
            const SizedBox(height: 10),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 10),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Address")),
            const SizedBox(height: 10),
            TextField(controller: _latitudeController, readOnly: true, decoration: const InputDecoration(labelText: "Latitude")),
            const SizedBox(height: 10),
            TextField(controller: _longitudeController, readOnly: true, decoration: const InputDecoration(labelText: "Longitude")),
            const SizedBox(height: 10),
            TextField(controller: _geoAddressController, readOnly: true, decoration: const InputDecoration(labelText: "Geo Address")),
            const SizedBox(height: 20),
            if (geoFetch)
              ElevatedButton(onPressed: _saveCustomer, child: const Text("Save Customer")),
          ],
        ),
      ),
    );
  }
}
