// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_launch_store/flutter_launch_store.dart';
import 'dart:io' show Platform;

class HelpCenter extends StatelessWidget {
  const HelpCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFFE02F26), // Shopee Pink
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Help Center'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to the Help Center!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'If you need assistance, please select one of the following options:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: ListTile(
                  onTap: () => _launchWhatsApp(context),
                  leading: const FaIcon(FontAwesomeIcons.whatsapp,
                      color: Colors.green), // Use WhatsApp icon
                  title: const Text('Request Help via WhatsApp',
                      style: TextStyle(color: Colors.black)), // Text color
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                child: ListTile(
                  onTap: _launchPhone,
                  leading: const Icon(Icons.phone,
                      color: Colors.black), // Use Phone icon
                  title: const Text('Request Help via Phone',
                      style: TextStyle(color: Colors.black)), // Text color
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                child: ListTile(
                  onTap: _launchEmailApp,
                  leading: const Icon(Icons.email,
                      color: Colors.red), // Use Email icon
                  title: const Text('Request Help via Email App',
                      style: TextStyle(color: Colors.black)), // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to launch WhatsApp
  void _launchWhatsApp(BuildContext context) async {
    const String phoneNumber = '+6282321490807';
    const String message = 'Mohon Bantuan terkait penggunaan Aplikasi';

    String whatsappUrl() {
      if (Platform.isAndroid) {
        return "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
      } else {
        return "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}";
      }
    }

    final Uri whatsappUri = Uri.parse(whatsappUrl());

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      try {
        const String appId = 'com.whatsapp';
        await StoreLauncher.openWithStore(appId);
      } on MissingPluginException catch (e) {
        _showAlertDialog(context, 'Error',
            'WhatsApp tidak terpasang, dan plugin store launcher tidak ditemukan: $e');
      } catch (e) {
        _showAlertDialog(
            context, 'Error', 'Gagal meluncurkan WhatsApp atau Play Store: $e');
      }
    }
  }

  // Function to launch email app
  void _launchEmailApp() async {
    const String emailAddress = 'reyzabdullah@gmail.com';
    const String subject = 'Help Request';
    const String body = 'Mohon Bantuan terkait penggunaan Aplikasi';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw 'Could not launch email app';
      }
    } catch (e) {
      debugPrint('Failed to launch email app: $e');
    }
  }

  // Function to launch phone app
  void _launchPhone() async {
    const String phoneNumber = '+6282321490807';

    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (!await launchUrl(phoneLaunchUri)) {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      debugPrint('Failed to launch phone app: $e');
    }
  }

  // Function to show alert dialog
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(const HelpCenter());
}
