import 'package:flutter/material.dart';

class UploadDataCustomersPage extends StatelessWidget {
  const UploadDataCustomersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Data Customers'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Upload Data Customers Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
