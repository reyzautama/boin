// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOrderPage extends StatefulWidget {
  const EditOrderPage({super.key});

  @override
  EditOrderPageState createState() => EditOrderPageState();
}

class EditOrderPageState extends State<EditOrderPage> {
  late Map<String, bool> editedFields = {};
  Map<String, Map<String, dynamic>> updatedData = {};
  Map<String, Map<String, TextEditingController>> controllers = {};

  @override
  void dispose() {
    controllers.forEach((key, value) {
      value.forEach((key, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Orders'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tb_order').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 50.0, // Minimum tinggi baris data
                dataRowMaxHeight: 50.0, // Maksimum tinggi baris data
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.pink), // Warna latar belakang header
                headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold), // Gaya teks header
                columns: const [
                  DataColumn(label: Text('Order Date')),
                  DataColumn(label: Text('Cust. Code')),
                  DataColumn(label: Text('Order Number')),
                  DataColumn(label: Text('Part Number')),
                  DataColumn(label: Text('Order Qty')),
                  DataColumn(label: Text('Supply Qty')),
                  DataColumn(label: Text('BO Qty')),
                  DataColumn(label: Text('Cancel Qty')),
                  DataColumn(label: Text('Remark')),
                  DataColumn(label: Text('ETD')),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String documentId = document.id;
                  Timestamp orderDate = data['order_date'];
                  Timestamp etd = data['ETD'];
                  String formattedOrderDate =
                      orderDate != null ? orderDate.toDate().toString() : '';
                  String formattedEtd =
                      etd != null ? etd.toDate().toString() : '';

                  // Initialize controllers if not already initialized
                  if (!controllers.containsKey(documentId)) {
                    controllers[documentId] = {
                      'cust_code':
                          TextEditingController(text: data['cust_code'] ?? ''),
                      'order_number': TextEditingController(
                          text: data['order_number'] ?? ''),
                      'part_number': TextEditingController(
                          text: data['part_number'] ?? ''),
                      'order_qty': TextEditingController(
                          text: data['order_qty'].toString()),
                      'supply_qty': TextEditingController(
                          text: data['supply_qty'].toString()),
                      'bo_qty': TextEditingController(
                          text: data['bo_qty'].toString()),
                      'cancel_qty': TextEditingController(
                          text: data['cancel_qty'].toString()),
                      'remark':
                          TextEditingController(text: data['remark'] ?? ''),
                    };
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(formattedOrderDate),
                        onTap: () {},
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['cust_code'],
                          decoration: InputDecoration(
                            hintText: 'Cust. Code',
                            fillColor: editedFields
                                    .containsKey('${document.id}_cust_code')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['order_number'],
                          decoration: InputDecoration(
                            hintText: 'Order Number',
                            fillColor: editedFields
                                    .containsKey('${document.id}_order_number')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['part_number'],
                          decoration: InputDecoration(
                            hintText: 'Part Number',
                            fillColor: editedFields
                                    .containsKey('${document.id}_part_number')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['order_qty'],
                          decoration: InputDecoration(
                            hintText: 'Order Qty',
                            fillColor: editedFields
                                    .containsKey('${document.id}_order_qty')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['supply_qty'],
                          decoration: InputDecoration(
                            hintText: 'Supply Qty',
                            fillColor: editedFields
                                    .containsKey('${document.id}_supply_qty')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['bo_qty'],
                          decoration: InputDecoration(
                            hintText: 'BO Qty',
                            fillColor: editedFields
                                    .containsKey('${document.id}_bo_qty')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['cancel_qty'],
                          decoration: InputDecoration(
                            hintText: 'Cancel Qty',
                            fillColor: editedFields
                                    .containsKey('${document.id}_cancel_qty')
                                ? Colors.yellow.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextField(
                          controller: controllers[documentId]!['remark'],
                          decoration: InputDecoration(
                            hintText: 'Remark',
                            fillColor: editedFields
                                    .containsKey('${document.id}_remark')
                                ? const Color.fromARGB(255, 255, 230, 0)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: formattedEtd),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  etd != null ? etd.toDate() : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                editedFields['${document.id}_etd'] = true;
                                updatedData[documentId] =
                                    updatedData[documentId] ?? {};
                                updatedData[documentId]!['ETD'] = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges,
        backgroundColor: Colors
            .pink, // Mengatur warna latar belakang floating button menjadi pink
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveChanges() async {
    for (var documentId in updatedData.keys) {
      await FirebaseFirestore.instance
          .collection('tb_order')
          .doc(documentId)
          .update(updatedData[documentId]!);
    }
    setState(() {
      editedFields.clear();
      updatedData.clear();
    });
  }
}
