import 'package:boin/head_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dashboard.dart';
import 'register.dart';
import 'administrator.dart'; // Import halaman AdministratorPage

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Validasi apakah field username dan password tidak kosong
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Username and password cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Menghentikan eksekusi proses login jika field kosong
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('tb_users')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Cek approval pengguna
      var userData = snapshot.docs.first.data();
      String approval = userData['approval'];
      if (approval != 'approved') {
        Get.snackbar(
          'Warning',
          'Please confirm with the admin',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Cek role pengguna
      String role = userData['role'];
      if (role == 'admin') {
        Get.offAll(() => AdminPage(loggedInUser: username));
      } else if (role == 'head') {
        Get.offAll(() => HeadDashboard(
            loggedInUser:
                username)); // Menambahkan logika untuk head_dashboard.dart
      } else {
        // Jika bukan admin atau head, arahkan ke halaman DashboardPage
        Get.offAll(() => DashboardPage(loggedInUser: username));
      }
    } else {
      Get.snackbar(
        'Error',
        'Invalid username or password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 30, color: Colors.pinkAccent),
        ),
        centerTitle: true, // Mengatur judul ke tengah
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/selog.png', // Gambar sebagai logo
              height: 50, // Tentukan tinggi gambar
              width: 50, // Tentukan lebar gambar
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monitor,
                  color: Colors.pinkAccent, // Warna ikon
                  size: 30, // Ukuran ikon
                ),
                SizedBox(width: 10), // Spasi antara ikon dan teks
                Text(
                  'Back-Order App Monitoring',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Spasi antara judul dan elemen lainnya
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleVisibility,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const RegisterPage());
                  },
                  child: const Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
