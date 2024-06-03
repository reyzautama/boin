import 'package:boin/delivery_page.dart';
import 'package:boin/details.dart';
import 'package:boin/upload.dart';
import 'package:flutter/material.dart';
import 'input_order.dart'; // Import halaman InputOrderPage

class OrderManagementPage extends StatelessWidget {
  final String loggedInUser;

  const OrderManagementPage({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                const Icon(Icons.person),
                Text(loggedInUser),
              ],
            ),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2, // Menampilkan 2 kartu per baris
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: [
          _buildMenuItem(
            context: context,
            title: 'Input Order',
            icon: Icons.create,
            onPressed: () {
              // Arahkan pengguna ke halaman InputOrderPage saat tombol ditekan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InputOrderPage(loggedInUser: loggedInUser),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Upload Order',
            icon: Icons.cloud_upload,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Details',
            icon: Icons.bar_chart,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(loggedInUser: loggedInUser),
                ),
              );
              debugPrint('Reports pressed');
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Delivery',
            icon: Icons.check_box_rounded,
            onPressed: () {
              // Tambahkan logika untuk menu lainnya
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DeliveryPage(loggedInUser: loggedInUser),
                ),
              );
              debugPrint('Delivery');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
