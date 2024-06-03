// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReleasePage extends StatefulWidget {
  final String orderId;

  const ReleasePage({Key? key, required this.orderId}) : super(key: key);

  @override
  ReleasePageState createState() => ReleasePageState();
}

class ReleasePageState extends State<ReleasePage> {
  DateTime? supplyDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tb_order')
              .doc(widget.orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const Text('Refresh');
            } else {
              final orderData = snapshot.data!.data() as Map<String, dynamic>;
              final orderNumber = orderData['order_number'];
              return Text('Release Order $orderNumber');
            }
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tb_order')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Order not found'));
          } else {
            final orderData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Order Date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _formatDate(orderData['order_date']),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Customer Code',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['cust_code'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Order Number',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['order_number'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Order Qty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['order_qty'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Supply Qty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['supply_qty'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Backorder Qty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['bo_qty'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Cancel Qty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                orderData['cancel_qty'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDatePicker('Supply Date', (date) {
                      setState(() {
                        supplyDate = date;
                      });
                    }),
                    const SizedBox(height: 20),
                    if (supplyDate != null)
                      _buildOrderInfo(
                          'Supply Date',
                          DateFormat('dd/MM/yyyy').format(
                              supplyDate!)), // Tampilkan Supply Date jika sudah dipilih
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: supplyDate != null ? _releaseOrder : null,
                        child: const Text('Release'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Fungsi untuk melepaskan pesanan
  Future<void> _releaseOrder() async {
    final orderDoc =
        FirebaseFirestore.instance.collection('tb_order').doc(widget.orderId);
    final orderData = (await orderDoc.get()).data() as Map<String, dynamic>;

    // Buat ID baru untuk tb_history
    final historyId =
        '${orderData['cust_code']}_${orderData['order_number']}_${orderData['part_number']}';

    // Periksa apakah ID sudah ada di Firestore
    final existingDoc = await FirebaseFirestore.instance
        .collection('tb_history')
        .doc(historyId)
        .get();

    if (existingDoc.exists) {
      // Hapus data dari tb_order
      await orderDoc.delete();

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Order released and moved to history.'),
      ));

      // Refresh page
      Navigator.pop(context);
    } else {
      // Buat data untuk ditambahkan ke tb_history
      final historyData = {
        ...orderData,
        'supply_date': Timestamp.fromDate(supplyDate!),
      };

      // Tambahkan data ke tb_history
      await FirebaseFirestore.instance
          .collection('tb_history')
          .doc(historyId)
          .set(historyData);

      // Hapus data dari tb_order
      await orderDoc.delete();

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Order already exists, data is deleted.'),
      ));

      // Refresh page
      Navigator.pop(context);
    }
  }

  // Fungsi untuk kembali dan refresh halaman NotificationPage
  Widget _buildDatePicker(String label, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: const Text(
            'Select Date',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildOrderInfo(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
