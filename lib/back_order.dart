import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BackOrderPage extends StatefulWidget {
  const BackOrderPage({Key? key}) : super(key: key);

  @override
  BackOrderPageState createState() => BackOrderPageState();
}

class BackOrderPageState extends State<BackOrderPage> {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('tb_order');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Back Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Judul
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'DETAILS BACK-ORDER MONITORING',
                style: TextStyle(
                    fontSize: 20, // Sesuaikan ukuran font sesuai kebutuhan
                    fontWeight: FontWeight.bold, // Jadikan teks tebal
                    color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: orders.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                var orderData = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.pink), // Border for the table
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.pink,
                        width: 2,
                      ),
                      columns: const [
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Order Date',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.code, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Cust Code',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.confirmation_number,
                                    color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Order Number',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.build_circle, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Part Number',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.production_quantity_limits,
                                    color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Order Qty',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Supply Qty',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.assignment, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'BO Qty',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Cancel Qty',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'ETD',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.comment, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Remark',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.hourglass_empty, color: Colors.pink),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Order Age',
                                    style: TextStyle(color: Colors.pink),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      rows: orderData.map((doc) {
                        // Menggunakan DateFormat untuk memformat tanggal
                        final DateFormat formatter = DateFormat('dd/MM/yyyy');
                        String formatTimestamp(Timestamp timestamp) {
                          return formatter.format(timestamp.toDate());
                        }

                        // Menghitung usia order
                        int calculateOrderAge(Timestamp orderDate) {
                          final DateTime now = DateTime.now();
                          final DateTime orderDateTime = orderDate.toDate();
                          return now.difference(orderDateTime).inDays;
                        }

                        return DataRow(
                          cells: [
                            DataCell(Text(formatTimestamp(
                                doc['order_date'] as Timestamp))),
                            DataCell(Text(doc['cust_code'])),
                            DataCell(Text(doc['order_number'])),
                            DataCell(Text(doc['part_number'])),
                            DataCell(Text(doc['order_qty'].toString())),
                            DataCell(Text(doc['supply_qty'].toString())),
                            DataCell(Text(doc['bo_qty'].toString())),
                            DataCell(Text(doc['cancel_qty'].toString())),
                            DataCell(
                                Text(formatTimestamp(doc['ETD'] as Timestamp))),
                            DataCell(Text(doc['remark'])),
                            DataCell(Text(calculateOrderAge(
                                    doc['order_date'] as Timestamp)
                                .toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const BackOrderPage(),
    );
  }
}
