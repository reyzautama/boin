// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance Back Orders',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MaintenanceBackOrderPage(),
    );
  }
}

class MaintenanceBackOrderPage extends StatefulWidget {
  const MaintenanceBackOrderPage({Key? key}) : super(key: key);

  @override
  MaintenanceBackOrderPageState createState() =>
      MaintenanceBackOrderPageState();
}

class MaintenanceBackOrderPageState extends State<MaintenanceBackOrderPage> {
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    remarkController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Back Orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Enter customer code, order number or part number',
                prefixIcon: Icon(Icons.search, color: Colors.pink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('tb_order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    documents = snapshot.data!.docs;
                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    filteredDocuments = documents.where((doc) {
                  final data = doc.data();
                  final String custCode = data['cust_code'] as String;
                  final String orderNumber = data['order_number'] as String;
                  final String partNumber = data['part_number'] as String;

                  return custCode
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      orderNumber
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      partNumber
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data =
                        filteredDocuments[index].data();
                    final String documentId = filteredDocuments[index].id;
                    final Timestamp orderDate = data['order_date'] as Timestamp;
                    final String custCode = data['cust_code'] as String;
                    final String orderNumber = data['order_number'] as String;
                    final String partNumber = data['part_number'] as String;
                    final int orderQty = data['order_qty'] as int;
                    final int supplyQty = data['supply_qty'] as int;
                    final int boQty = data['bo_qty'] as int;
                    final int cancelQty = data['cancel_qty'] as int;
                    final String remark = data['remark'] as String;
                    final Timestamp etd = data['ETD'] as Timestamp;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        leading: const Icon(Icons.info, color: Colors.pink),
                        title: Text('Order Number: $orderNumber'),
                        subtitle: Text('Customer Code: $custCode'),
                        children: [
                          ListTile(
                            title:
                                Text('Order Date: ${_formatDate(orderDate)}'),
                          ),
                          ListTile(
                            title: Text('Part Number: $partNumber'),
                          ),
                          ListTile(
                            title: Text('Order Quantity: $orderQty'),
                          ),
                          ListTile(
                            title: Text('Supply Quantity: $supplyQty'),
                          ),
                          ListTile(
                            title: Text('Back Order Quantity: $boQty'),
                          ),
                          ListTile(
                            title: Text('Cancelled Quantity: $cancelQty'),
                          ),
                          ListTile(
                            title: Text('Remark: $remark'),
                          ),
                          ListTile(
                            title: Text('ETD: ${_formatDate(etd)}'),
                          ),
                          ListTile(
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.pink),
                              onPressed: () {
                                _showUpdateDialog(context, documentId, data);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  Future<void> _showUpdateDialog(BuildContext context, String documentId,
      Map<String, dynamic> data) async {
    String orderNumber = data['order_number'] as String;
    int orderQty = data['order_qty'] as int;
    int supplyQty = data['supply_qty'] as int;
    int boQty = data['bo_qty'] as int;
    int cancelQty = data['cancel_qty'] as int;
    String remark = data['remark'] as String;
    DateTime etd = (data['ETD'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Order Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  readOnly: true, // Make the TextFormField read-only
                  initialValue: orderNumber.toString(),
                  decoration: const InputDecoration(labelText: 'Order Number'),
                  onChanged: (value) {
                    orderNumber = value;
                  },
                ),
                TextFormField(
                  initialValue: orderQty.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Order Quantity'),
                  onChanged: (value) {
                    orderQty = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: supplyQty.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Supply Quantity'),
                  onChanged: (value) {
                    supplyQty = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: boQty.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Back Order Quantity'),
                  onChanged: (value) {
                    boQty = int.parse(value);
                  },
                ),
                TextFormField(
                  initialValue: cancelQty.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Cancelled Quantity'),
                  onChanged: (value) {
                    cancelQty = int.parse(value);
                  },
                ),
                TextFormField(
                  controller: remarkController,
                  decoration: const InputDecoration(labelText: 'Remark'),
                  maxLines:
                      null, // Setting maxLines to null allows the TextField to wrap text
                  onChanged: (value) {
                    remark = value;
                  },
                ),
                TextFormField(
                  initialValue: _formatDate(Timestamp.fromDate(etd)),
                  decoration: const InputDecoration(labelText: 'ETD'),
                  onChanged: (value) {
                    etd = DateFormat('dd/MM/yyyy').parse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                remark =
                    remarkController.text; // Get the text from the controller
                await FirebaseFirestore.instance
                    .collection('tb_order')
                    .doc(documentId)
                    .update({
                  'order_qty': orderQty,
                  'supply_qty': supplyQty,
                  'bo_qty': boQty,
                  'cancel_qty': cancelQty,
                  'remark': remark,
                  'ETD': etd,
                });
                Navigator.pop(context);
                _showSuccessDialog(context); // Show success dialog
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Data successfully updated!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
