import 'package:boin/customers_add.dart';
import 'package:flutter/material.dart';
import 'package:boin/details.dart';
import 'package:boin/manage_orders.dart';
import 'package:boin/manage_users.dart';
import 'package:boin/login.dart'; // Import login page to navigate to after logout

class AdminPage extends StatelessWidget {
  final String loggedInUser;

  const AdminPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Logout Icon
            onPressed: () {
              // Navigate to login page and remove all previous routes from the stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context: context,
            title: 'Manage Users',
            icon: Icons.supervised_user_circle, // Icon for Manage Users
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManageUsersPage(loggedInUser: loggedInUser),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Manage Orders',
            icon: Icons.shopping_cart, // Icon for Manage Orders
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManageOrdersPage(loggedInUser: loggedInUser),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Details Pages',
            icon: Icons.analytics, // Icon for Generate Reports
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(loggedInUser: loggedInUser),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            title: 'Manage Customers',
            icon: Icons.person_pin, // Icon for Manage Orders
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddCustomersPage(loggedInUser: loggedInUser),
                ),
              );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pink, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24.0,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
