import 'package:boin/release_page_notification.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const NotificationPage(overdueCount: 3), // Example overdueCount
    );
  }
}

class NotificationPage extends StatelessWidget {
  final int overdueCount;

  const NotificationPage({Key? key, required this.overdueCount})
      : super(key: key);

  void _updateOrderAndRemark(String orderId, BuildContext context) async {
    DateTime newETD = DateTime.now();
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('tb_order')
        .doc(orderId)
        .get();
    String existingRemark = orderSnapshot['remark'] ?? '';

    TextEditingController remarkController =
        TextEditingController(text: existingRemark);

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update ETD and Remark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select new Estimated Time of Delivery (ETD):'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (pickedDate != null) {
                      newETD = pickedDate;
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100, // Adjust the height as needed
                child: TextField(
                  controller: remarkController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter new remark',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrderETDAndRemark(
                    orderId, newETD, remarkController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateOrderETDAndRemark(
      String orderId, DateTime newETD, String newRemark) {
    FirebaseFirestore.instance.collection('tb_order').doc(orderId).update({
      'ETD': newETD,
      'remark': newRemark,
    }).then((_) {
      // Perform any actions after updating ETD and remark if needed
    });
  }

  int calculateETDAge(DateTime orderDate, DateTime etdDate) {
    return etdDate.difference(orderDate).inDays;
  }

  void _navigateToReleasePage(BuildContext context, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReleasePage(orderId: orderId),
      ),
    );
  }

  String getActionMessage(DocumentSnapshot order) {
    DateTime etdDate = order['ETD'].toDate();
    String remark = order['remark'] ?? '';

    if (etdDate.isAtSameMomentAs(DateTime.now()) && remark.isEmpty) {
      return 'Please Check and Update Remark';
    } else if (etdDate.isAtSameMomentAs(DateTime.now())) {
      return 'Please Check Supply Status at GT System';
    } else if (etdDate.isBefore(DateTime.now()) && remark.isEmpty) {
      return 'Please Follow Up to Supplier and Update Remark';
    } else if (etdDate.isBefore(DateTime.now())) {
      return 'Please Follow Up & Update New ETD';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: overdueCount > 0
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tb_order')
                  .where('ETD', isLessThan: DateTime.now())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final List<DocumentSnapshot> overdueOrders =
                      snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: overdueOrders.length,
                    itemBuilder: (context, index) {
                      final order = overdueOrders[index];
                      final orderDate = order['order_date'].toDate();
                      final formattedOrderDate =
                          "${orderDate.day.toString().padLeft(2, '0')}/${orderDate.month.toString().padLeft(2, '0')}/${orderDate.year}";

                      final etdDate = order['ETD'].toDate();
                      final formattedEtdDate =
                          "${etdDate.day.toString().padLeft(2, '0')}/${etdDate.month.toString().padLeft(2, '0')}/${etdDate.year}";

                      final orderAge =
                          DateTime.now().difference(orderDate).inDays;
                      final etdAge = calculateETDAge(orderDate, etdDate);

                      final remark = order['remark'] ??
                          'No remarks'; // Default value if remark is null

                      final actionMessage = getActionMessage(order);

                      return Card(
                        child: ExpansionTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.pink,
                            child:
                                Icon(Icons.shopping_bag, color: Colors.white),
                          ),
                          title: Text(
                            'Order Number: ${order['order_number']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            actionMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                          children: [
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                      'Customer Code', order['cust_code']),
                                  _buildDetailRow(
                                      'Order Date', formattedOrderDate),
                                  _buildDetailRow(
                                      'Quantity', order['bo_qty'].toString()),
                                  _buildDetailRow('ETD', formattedEtdDate),
                                  _buildDetailRow(
                                      'Age to Orders', '$orderAge days'),
                                  _buildDetailRow('Age to ETD', '$etdAge days'),
                                  _buildDetailRowWithExpandableText(
                                      'Remarks/Issue', remark),
                                ],
                              ),
                              trailing: FittedBox(
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Update'),
                                      onPressed: () {
                                        _updateOrderAndRemark(
                                            order.id, context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.pink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 8), // Reduced spacing
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Release Order'),
                                      onPressed: () {
                                        _navigateToReleasePage(
                                            context, order.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            )
          : const Center(
              child: Text(
                'No overdue orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDetailRowWithExpandableText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ExpandableText(
          value,
          expandText: 'show more',
          collapseText: 'show less',
          maxLines: 1,
          linkColor: Colors.blue,
        ),
        const Divider(),
      ],
    );
  }
}
