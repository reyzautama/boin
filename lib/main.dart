import 'package:boin/background_task.dart';
import 'package:boin/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'login.dart';
import 'notification_manager.dart';
import 'theme_notifier.dart'; // Tambahkan impor ThemeNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());

  // Jalankan background task
  runBackgroundTask();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      // Tambahkan ChangeNotifierProvider
      create: (_) => ThemeNotifier(), // Buat instance dari ThemeNotifier
      child: Builder(
        builder: (context) {
          return GetMaterialApp(
            home: const SplashScreen(),
            theme: ThemeData(
              primaryColor: Colors.pink,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color.fromARGB(255, 218, 7, 255),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const LoginPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    final NotificationManager notificationManager = NotificationManager();
    notificationManager.init(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shopping_bag,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Isolate untuk menjalankan tugas latar belakang
void runBackgroundTask() {
  // Panggil metode yang akan berjalan di latar belakang di sini
  backgroundTask();
}
