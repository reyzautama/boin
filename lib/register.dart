import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _registerUser(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Register'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Please Confirm if You Have Registered',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    String username = usernameController.text;
    String password = passwordController.text;

    // Validasi apakah field username dan password tidak kosong
    if (username.isEmpty && password.isEmpty) {
      _showSnackBar('Username and password cannot be empty.');
      return;
    } else if (username.isEmpty) {
      _showSnackBar('Username cannot be empty.');
      return;
    } else if (password.isEmpty) {
      _showSnackBar('Password cannot be empty.');
      return;
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tb_users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _showSnackBar('Username is already registered.');
    } else {
      try {
        await FirebaseFirestore.instance.collection('tb_users').add({
          'username': username,
          'password': password,
          'role': 'user', // Automatically assign the role value
          'approval': 'Wait Approval', // Add approval field with default value
        });

        _showSuccessDialog('Your account has been registered successfully.');
      } catch (error) {
        _showSnackBar('Failed to register. Please try again later.');
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                usernameController.clear();
                passwordController.clear();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
