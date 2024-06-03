import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomersPage extends StatefulWidget {
  const EditCustomersPage({Key? key}) : super(key: key);

  @override
  EditCustomersPageState createState() => EditCustomersPageState();
}

class EditCustomersPageState extends State<EditCustomersPage> {
  late List<DocumentSnapshot> customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomersData();
  }

  Future<void> _fetchCustomersData() async {
    try {
      final QuerySnapshot customersSnapshot =
          await FirebaseFirestore.instance.collection('tb_customers').get();

      if (customersSnapshot.docs.isNotEmpty) {
        setState(() {
          customers = customersSnapshot.docs;
        });
      } else {
        // Handle case when no customers exist
        // For example, show an error message
        debugPrint('No customers found');
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error fetching customers data: $e');
    }
  }

  Future<void> _updateCustomerData(
      String customerCode, String newCustomerName, String newAddress) async {
    try {
      final Map<String, dynamic> updatedData = {
        'customer_name': newCustomerName,
        'address': newAddress,
      };

      await FirebaseFirestore.instance
          .collection('tb_customers')
          .doc(customerCode)
          .update(updatedData);

      // Show success message
      _showMessage('Customer data updated successfully');
    } catch (e) {
      // Handle any errors
      _showMessage('Error updating customer data: $e');
    }
  }

  Future<void> _deleteCustomer(String customerCode) async {
    try {
      await FirebaseFirestore.instance
          .collection('tb_customers')
          .doc(customerCode)
          .delete();

      // Show success message
      _showMessage('Customer deleted successfully');
    } catch (e) {
      // Handle any errors
      _showMessage('Error deleting customer: $e');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customers'),
        backgroundColor: Colors.pink,
      ),
      body: customers.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer Code')),
                  DataColumn(label: Text('Customer Name')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: customers.map((customer) {
                  final customerData = customer.data() as Map<String, dynamic>;
                  final customerCode = customerData['customer_code'];
                  var customerName = customerData['customer_name'];
                  var address = customerData['address'];

                  return DataRow(
                    cells: [
                      DataCell(Text(customerCode)),
                      DataCell(TextField(
                        controller: TextEditingController(text: customerName),
                        onChanged: (newValue) {
                          customerName = newValue;
                        },
                      )),
                      DataCell(TextField(
                        controller: TextEditingController(text: address),
                        onChanged: (newValue) {
                          address = newValue;
                        },
                      )),
                      DataCell(Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Update'),
                                    content:
                                        const Text('Are you sure to update?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _updateCustomerData(customerCode,
                                              customerName, address);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Update'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content:
                                        const Text('Are you sure to delete?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteCustomer(customerCode);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
