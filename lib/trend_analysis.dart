import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import package untuk formatting tanggal
import 'package:syncfusion_flutter_charts/charts.dart';

class TrendAnalysisPage extends StatelessWidget {
  const TrendAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'Trend Analysis',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('tb_order').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }
          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSalesChart(snapshot.data!.docs),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index].data();
                    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('tb_customers')
                          .where('customer_code', isEqualTo: order['cust_code'])
                          .get(),
                      builder: (context, customerSnapshot) {
                        if (customerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (customerSnapshot.hasError) {
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cust Code: ${order['cust_code']}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Error: ${customerSnapshot.error}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (!customerSnapshot.hasData ||
                            customerSnapshot.data!.docs.isEmpty) {
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cust Code: ${order['cust_code']}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const Text(
                                    'Customer Name: Customer Name Not Found',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Order Number: ${order['order_number']}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Order Date: ${_getOrderDate(order['order_date'])}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'ETD: ${_getOrderDate(order['ETD'])}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'BO Quantity: ${order['bo_qty'].toString()}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Cancelled Quantity: ${order['cancel_qty'].toString()}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        var customerData =
                            customerSnapshot.data!.docs.first.data();
                        String customerName = customerData['customer_name'] ??
                            'Customer Name Not Found';

                        return Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cust Code: ${order['cust_code']}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Customer Name: $customerName',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Order Number: ${order['order_number']}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Order Date: ${_getOrderDate(order['order_date'])}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'ETD: ${_getOrderDate(order['ETD'])}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'BO Quantity: ${order['bo_qty'].toString()}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  'Cancelled Quantity: ${order['cancel_qty'].toString()}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSalesChart(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> documents) {
    List<_SalesData> salesData =
        List.generate(7, (index) => _SalesData(0, _getWeekday(index + 1)));

    for (var document in documents) {
      DateTime orderDate =
          (document.data()['order_date'] as Timestamp).toDate();
      int weekday = orderDate.weekday;
      salesData[weekday - 1].quantity +=
          (document.data()['bo_qty'] as int).toDouble();
    }

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      series: <CartesianSeries<dynamic, dynamic>>[
        LineSeries<_SalesData, String>(
          dataSource: salesData,
          xValueMapper: (_SalesData sales, _) => sales.weekday,
          yValueMapper: (_SalesData sales, _) => sales.quantity,
          name: 'BO Quantity',
          color: Colors.pink,
        ),
      ],
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }

  String _getOrderDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}

class _SalesData {
  _SalesData(this.quantity, this.weekday);

  double quantity;
  String weekday;
}
