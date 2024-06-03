// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import library

class ChangePassword extends StatefulWidget {
  final String loggedInUser;

  const ChangePassword({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                errorText: _currentPasswordError,
                labelStyle: const TextStyle(color: Colors.pink), // Text color
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink), // Border color
                ),
                prefixIcon: const Icon(
                  Icons.lock, // You can use Font Awesome icons here
                  color: Colors.pink, // Icon color
                ),
              ),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                errorText: _newPasswordError,
                labelStyle: const TextStyle(color: Colors.pink), // Text color
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink), // Border color
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.key, // Font Awesome icon
                  color: Colors.pink, // Icon color
                ),
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _confirmPasswordError,
                labelStyle: const TextStyle(color: Colors.pink), // Text color
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink), // Border color
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.key, // Font Awesome icon
                  color: Colors.pink, // Icon color
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _changePassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .pink, // Ubah warna latar belakang tombol menjadi pink
              ),
              child: const Text('Change Password',
                  style: TextStyle(
                      color: Colors.white)), // Ubah warna teks menjadi putih
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Reset errors
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    // Validate fields
    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordError = 'Please enter your current password';
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = 'Please enter a new password';
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your new password';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    // Fetch user data
    final userSnapshot = await FirebaseFirestore.instance
        .collection('tb_users')
        .where('username', isEqualTo: widget.loggedInUser)
        .get();

    if (userSnapshot.docs.isEmpty) {
      setState(() {
        _currentPasswordError = 'User not found';
      });
      return;
    }

    final userData = userSnapshot.docs.first.data();
    final storedPassword = userData['password'];

    // Validate current password
    if (storedPassword != currentPassword) {
      setState(() {
        _currentPasswordError = 'Incorrect current password';
      });
      return;
    }

    // Update password
    final userDocId = userSnapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('tb_users')
        .doc(userDocId)
        .update({'password': newPassword});

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Password updated successfully'),
      duration: Duration(seconds: 5), // Adjust duration as needed
    ));

    // Clear fields
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    // Return to dashboard
    Navigator.pop(context);
  }
}
