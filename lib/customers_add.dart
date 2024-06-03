import 'package:boin/customers_edit.dart';
import 'package:boin/customers_upload.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCustomersPage extends StatefulWidget {
  final String loggedInUser;

  const AddCustomersPage({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  AddCustomersPageState createState() => AddCustomersPageState();
}

class AddCustomersPageState extends State<AddCustomersPage> {
  String? selectedCustomerType;
  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Function to clear all text fields
  void _clearFields() {
    customerCodeController.clear();
    customerNameController.clear();
    addressController.clear();
    setState(() {
      selectedCustomerType = null;
    });
  }

  // Function to validate if customer code already exists
  Future<bool> _validateCustomerCode(String customerCode) async {
    final customersCollection =
        FirebaseFirestore.instance.collection('tb_customers');
    final querySnapshot = await customersCollection
        .where('customer_code', isEqualTo: customerCode)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  // Function to show alert dialog
  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Success') {
                  _clearFields();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.pink,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'Edit Customers':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditCustomersPage()),
                  );
                  break;
                case 'Upload Customers':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadDataCustomersPage()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Edit Customers',
                child: Text('Edit Customers'),
              ),
              const PopupMenuItem<String>(
                value: 'Upload Customers',
                child: Text('Upload Customers'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: customerCodeController,
              decoration: const InputDecoration(
                labelText: 'Customer Code',
                hintText: 'Enter customer code',
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // You can update customer code here
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // You can update customer name here
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter address',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              onChanged: (value) {
                // You can update address here
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCustomerType,
              decoration: const InputDecoration(
                labelText: 'Customer Type',
                hintText: 'Select customer type',
                filled: true,
                fillColor: Colors.white,
              ),
              items:
                  <String>['Workshop', 'Partshop', 'SCW'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCustomerType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Validate that no fields are empty
                if (customerCodeController.text.isEmpty ||
                    customerNameController.text.isEmpty ||
                    addressController.text.isEmpty ||
                    selectedCustomerType == null) {
                  _showAlertDialog('Error', 'Please fill out all fields.');
                  return;
                }

                // Validate customer code
                final String customerCode = customerCodeController.text;
                final bool codeExists =
                    await _validateCustomerCode(customerCode);
                if (!codeExists) {
                  // Show error message if customer code already exists
                  _showAlertDialog(
                      'Error', 'Customer with this code already exists.');
                } else {
                  // Add customer logic
                  final Map<String, dynamic> customerData = {
                    'customer_code': customerCode,
                    'customer_name': customerNameController.text,
                    'address': addressController.text,
                    'customer_type': selectedCustomerType ??
                        '', // null check for selectedCustomerType
                  };

                  // Send data to Firestore
                  await FirebaseFirestore.instance
                      .collection('tb_customers')
                      .add(customerData);

                  // Show success message
                  _showAlertDialog('Success', 'Customer added successfully.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                textStyle: const TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
