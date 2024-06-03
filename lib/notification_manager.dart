import 'dart:async'; // Import library dart:async untuk menggunakan Timer
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void init(BuildContext context) async {
    _firebaseMessaging.getToken().then((token) {
      debugPrint("Firebase Messaging Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: $message");
      // Handle your message when the app is in foreground
      _showNotification(context, message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp: $message");
      // Handle your message when the app is terminated or in background
      _showNotification(context, message.data);
    });

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for notification');
    }

    // Schedule background task to check tb_order every 2 seconds
    // Note: This is just a placeholder, you may need to use background task scheduling packages
    // ignore: use_build_context_synchronously
    _scheduleBackgroundTask(context);
  }

  void _scheduleBackgroundTask(BuildContext context) {
    // Schedule background task to run every 2 seconds
    // For demonstration purpose, you can use Timer.periodic
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkOrdersAndSendNotifications(context);
    });
  }

  Future<void> _checkOrdersAndSendNotifications(BuildContext context) async {
    // Get current date
    DateTime now = DateTime.now();

    // Format current date to match Firestore format
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Query Firestore to get orders with ETD less than or equal to today's date
    QuerySnapshot ordersSnapshot = await _firestore
        .collection('tb_order')
        .where('ETD', isLessThanOrEqualTo: formattedDate)
        .get();

    // Iterate through orders
    for (var orderDoc in ordersSnapshot.docs) {
      // Extract order data
      String orderDate = orderDoc['order_date'];
      String etd = orderDoc['ETD'];
      String custCode = orderDoc['cust_code'];
      String orderNumber = orderDoc['order_number'];
      int orderQty = orderDoc['order_qty'];

      // Show notification if ETD is today or before
      if (etd == formattedDate) {
        // Show the notification
        // ignore: use_build_context_synchronously
        _showNotification(context, {
          'data': {
            'order_date': orderDate,
            'ETD': etd,
            'cust_code': custCode,
            'order_number': orderNumber,
            'order_qty': orderQty.toString(),
          }
        });
      }
    }
  }

  void _showNotification(BuildContext context, Map<String, dynamic> message) {
    // Parse the message and extract necessary data
    String orderDate = message['data']['order_date'];
    String etd = message['data']['ETD'];
    String custCode = message['data']['cust_code'];
    String orderNumber = message['data']['order_number'];
    int orderQty = int.parse(message['data']['order_qty']);

    // Show the notification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Alert!'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Order Details:'),
            Text('Date: $orderDate'),
            Text('ETD: $etd'),
            Text('Customer Code: $custCode'),
            Text('Order Number: $orderNumber'),
            Text('Order Quantity: $orderQty'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
