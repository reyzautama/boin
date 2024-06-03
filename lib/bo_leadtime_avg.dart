import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum to represent order categories based on lead time
enum OrderStatus {
  slightlyLate,
  moderatelyLate,
  severelyLate,
}

class Order {
  late DateTime orderDate;

  Order({required this.orderDate});

  // Function to get the order status based on lead time
  OrderStatus getOrderStatus() {
    DateTime now = DateTime.now();
    int leadTime = now.difference(orderDate).inDays;

    // Determine order status based on lead time
    if (leadTime <= 3) {
      return OrderStatus.slightlyLate;
    } else if (leadTime <= 7) {
      return OrderStatus.moderatelyLate;
    } else {
      return OrderStatus.severelyLate;
    }
  }
}

class BOLTAnalysisPage extends StatefulWidget {
  const BOLTAnalysisPage({Key? key}) : super(key: key);

  @override
  BOLTAnalysisPageState createState() => BOLTAnalysisPageState();
}

class BOLTAnalysisPageState extends State<BOLTAnalysisPage> {
  late Future<double> _boLeadTimeAverage;

  @override
  void initState() {
    super.initState();
    _boLeadTimeAverage = _calculateBOLTAverage();
  }

  // Function to calculate the average lead time of orders
  Future<double> _calculateBOLTAverage() async {
    // Fetch orders data from Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('tb_order').get();

    int totalOrders = snapshot.docs.length;
    int totalLeadTime = 0;

    // Calculate total lead time
    for (var doc in snapshot.docs) {
      Timestamp orderTimestamp = doc['order_date'] as Timestamp;
      DateTime orderDate = orderTimestamp.toDate();
      DateTime now = DateTime.now(); // Get today's date
      int leadTime = now.difference(orderDate).inDays;
      totalLeadTime += leadTime;
    }

    // Calculate average lead time
    if (totalOrders == 0) {
      return 0;
    } else {
      return totalLeadTime / totalOrders;
    }
  }

  // Function to simulate lead time for the next few days
  Future<List<double>> _simulateBOLT() async {
    DateTime now = DateTime.now(); // Get today's date
    List<double> simulatedAverages = [];
    for (int i = 0; i < 5; i++) {
      DateTime nextDate = now.add(Duration(days: i + 1));
      double boLTAverage = await _calculateBOLTAverageForDate(nextDate);
      simulatedAverages.add(boLTAverage);
    }
    return simulatedAverages;
  }

  // Function to calculate the average lead time of orders for a specific date
  Future<double> _calculateBOLTAverageForDate(DateTime date) async {
    // Fetch orders data from Firestore for the specified date
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tb_order')
        .where('order_date', isLessThanOrEqualTo: date)
        .get();

    int totalOrders = snapshot.docs.length;
    int totalLeadTime = 0;

    // Calculate total lead time
    for (var doc in snapshot.docs) {
      Timestamp orderTimestamp = doc['order_date'] as Timestamp;
      DateTime orderDate = orderTimestamp.toDate();
      int leadTime = date.difference(orderDate).inDays;
      totalLeadTime += leadTime;
    }

    // Calculate average lead time
    if (totalOrders == 0) {
      return 0;
    } else {
      return totalLeadTime / totalOrders;
    }
  }

  // Function to determine the order status based on lead time
  OrderStatus _getStatusFromLeadTime(double leadTime) {
    // Determine order status based on lead time
    if (leadTime <= 3) {
      return OrderStatus.slightlyLate;
    } else if (leadTime <= 7) {
      return OrderStatus.moderatelyLate;
    } else {
      return OrderStatus.severelyLate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BO LT Avg. Analysis'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<double>(
              future: _boLeadTimeAverage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                } else {
                  double boLTAverage = snapshot.data ?? 0;
                  String formattedAverage = boLTAverage.toStringAsFixed(2);
                  return Card(
                    elevation: 5,
                    color: Colors.pink, // Color can be customized
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'BO LT Average: $formattedAverage days',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder<List<double>>(
                future: _simulateBOLT(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  } else if (!snapshot.hasData) {
                    return const Text(
                      'No data available',
                      style: TextStyle(color: Colors.black87),
                    );
                  } else {
                    List<double> simulatedAverages = snapshot.data!;
                    return ListView.builder(
                      itemCount: simulatedAverages.length,
                      itemBuilder: (context, index) {
                        DateTime simulatedDate =
                            DateTime.now().add(Duration(days: index + 1));
                        String formattedDate =
                            simulatedDate.toString().split(' ')[0];
                        OrderStatus status =
                            _getStatusFromLeadTime(simulatedAverages[index]);
                        IconData icon;
                        Color iconColor;
                        String statusMessage = '';

                        switch (status) {
                          case OrderStatus.slightlyLate:
                            icon = Icons.warning;
                            iconColor = Colors.amber;
                            statusMessage = 'Your order is slightly late.';
                            break;
                          case OrderStatus.moderatelyLate:
                            icon = Icons.error;
                            iconColor = Colors.orange;
                            statusMessage = 'Your order is moderately late.';
                            break;
                          case OrderStatus.severelyLate:
                            icon = Icons.error_outline;
                            iconColor = Colors.red;
                            statusMessage = 'Your order is severely late.';
                            break;
                        }

                        return Card(
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(
                              icon,
                              color: iconColor,
                            ),
                            title: Text(
                              'Day ${index + 1}: $formattedDate',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BO LT Average: ${simulatedAverages[index].toStringAsFixed(2)} days',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  statusMessage,
                                  style: TextStyle(
                                    color: iconColor, // Match status icon color
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BOLTAnalysisPage(),
  ));
}
