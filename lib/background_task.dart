import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void backgroundTask() {
  // Inisialisasi flutter_local_notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi flutter_local_notifications hanya untuk Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Gunakan Timer untuk memanggil fungsi yang ingin dijalankan secara berkala
  Timer.periodic(const Duration(hours: 10), (timer) async {
    DateTime now = DateTime.now();

    // Periksa apakah saat ini berada dalam rentang waktu yang diinginkan (senin-jumat, jam 8 pagi)
    if (now.weekday >= 1 &&
        now.weekday <= 5 &&
        now.hour >= 8 &&
        now.hour < 17) {
      // Dapatkan daftar pesanan yang terlambat dari Firestore
      QuerySnapshot<Map<String, dynamic>> ordersSnapshot =
          await FirebaseFirestore.instance.collection('tb_order').get();

      // Hitung jumlah pesanan yang terlambat
      int overdueOrders = 0;

      // Iterasi setiap dokumen dalam koleksi "orders"
      for (var orderDoc in ordersSnapshot.docs) {
        // Dapatkan nilai ETD dari dokumen
        Timestamp etdTimestamp = orderDoc['ETD'];
        DateTime etd = etdTimestamp.toDate();

        // Periksa apakah ETD telah terlampaui
        if (etd.isBefore(now)) {
          overdueOrders++;
        }
      }

      // Tampilkan notifikasi jika ada pesanan yang terlambat
      if (overdueOrders > 0) {
        showOverdueNotification(overdueOrders);
      }
    }
  });
}

void showOverdueNotification(int overdueCount) async {
  // Konfigurasi notifikasi
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'overdue_orders_channel',
    'Overdue Orders',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Inisialisasi flutter_local_notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Tampilkan notifikasi
  await flutterLocalNotificationsPlugin.show(
    0,
    'Overdue Orders',
    'You have $overdueCount overdue orders.',
    platformChannelSpecifics,
    payload: 'overdue_orders',
  );
}
