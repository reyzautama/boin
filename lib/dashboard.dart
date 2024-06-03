import 'dart:async';

import 'package:boin/analisys.dart';
import 'package:boin/back_order.dart';
import 'package:boin/change_password.dart';
import 'package:boin/help_center.dart';
import 'package:boin/maintenance_back_order.dart';
import 'package:boin/report.dart';
import 'package:boin/user_overview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'register.dart';
import 'login.dart';
import 'notifications_page.dart';
import 'order_management.dart';
import 'setting_page.dart';

class DashboardPage extends StatefulWidget {
  final String loggedInUser;

  const DashboardPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  int overdueCount = 0;
  late StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk menghitung jumlah pesanan yang terlambat
    countOverdueOrders();
    // Tambahkan listener Stream untuk mendengarkan perubahan pada koleksi tb_order
    _subscription = FirebaseFirestore.instance
        .collection('tb_order')
        .snapshots()
        .listen((snapshot) {
      countOverdueOrders();
    });
  }

  @override
  void dispose() {
    // Hapus listener Stream saat widget dihapus
    _subscription.cancel();
    super.dispose();
  }

  void countOverdueOrders() async {
    // Implementasi perhitungan jumlah pesanan yang terlambat seperti sebelumnya
    QuerySnapshot<Map<String, dynamic>> ordersSnapshot =
        await FirebaseFirestore.instance.collection('tb_order').get();
    int overdueOrders = 0;
    DateTime now = DateTime.now();

    for (var orderDoc in ordersSnapshot.docs) {
      Timestamp etdTimestamp = orderDoc['ETD'];
      DateTime etd = etdTimestamp.toDate();
      if (etd.isBefore(now)) {
        overdueOrders++;
      }
    }

    setState(() {
      overdueCount = overdueOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            icon: const Icon(Icons.person_add), // Icon for Register
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.login), // Icon for Login
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.black), // Added icon
                const SizedBox(width: 8), // Added SizedBox for spacing
                const Text(
                  'Welcome, ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                RichText(
                  text: TextSpan(
                    text: widget.loggedInUser,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                ),
                const Text(
                  '!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Add other widgets or content here
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 8),
                  Text('Welcome, ${widget.loggedInUser}'),
                ],
              ),
              accountEmail: null,
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            // Item-item menu
            _buildDrawerMenuItem(
              title: 'Overview',
              icon: FontAwesomeIcons.chartBar,
              onPressed: () {
                // Tambahkan logika untuk menu Overview di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserOverviewPage()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Back Orders',
              icon: FontAwesomeIcons.clock,
              onPressed: () {
                // Tambahkan logika untuk menu Pesanan Tertunda di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BackOrderPage()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Analysis',
              icon: FontAwesomeIcons.chartLine,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisPage()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Order Management',
              icon: FontAwesomeIcons.shoppingCart,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderManagementPage(
                          loggedInUser: widget.loggedInUser)),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Settings',
              icon: FontAwesomeIcons.cog,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Reports',
              icon: FontAwesomeIcons.fileAlt,
              onPressed: () {
                // Tambahkan logika untuk menu Laporan di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              },
            ),
            // Menu Notifications dengan badge
            ListTile(
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.bell), // Icon for Notifications
                  overdueCount > 0
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text(
                              overdueCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(), // Empty SizedBox if no overdue orders
                ],
              ),
              title: const Text('Notifications'),
              onTap: () {
                // Tampilkan jumlah pesanan yang terlambat pada menu Notifications
                // dengan memindahkan ke halaman NotificationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationPage(overdueCount: overdueCount)),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Maintenance',
              icon: FontAwesomeIcons.tools,
              onPressed: () {
                // Tambahkan logika untuk menu Riwayat Pesanan Tertunda di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const MaintenanceBackOrderPage()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Help Center',
              icon: FontAwesomeIcons.infoCircle,
              onPressed: () {
                // Tambahkan logika untuk menu Pusat Bantuan di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpCenter()),
                );
              },
            ),
            _buildDrawerMenuItem(
              title: 'Change Password',
              icon: FontAwesomeIcons.lock,
              onPressed: () {
                // Tambahkan logika untuk menu Pusat Bantuan di sini
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePassword(loggedInUser: widget.loggedInUser)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem(
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ListTile(
      leading: FaIcon(icon),
      title: Text(title),
      onTap: onPressed,
    );
  }
}
