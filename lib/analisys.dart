import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'bo_leadtime_avg.dart'; // Import halaman bo_leadtime_avg.dart

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  AnalysisPageState createState() => AnalysisPageState();
}

class AnalysisPageState extends State<AnalysisPage> {
  late Stream<List<DocumentSnapshot>> _lateETDOrdersStream;
  late Stream<List<DocumentSnapshot>> _totalOrdersStream;

  @override
  void initState() {
    super.initState();
    _lateETDOrdersStream = _getLateETDOrdersStream();
    _totalOrdersStream = _getTotalOrdersStream();
  }

  Stream<List<DocumentSnapshot>> _getLateETDOrdersStream() {
    return FirebaseFirestore.instance
        .collection('tb_order')
        .where('ETD', isLessThan: Timestamp.now())
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Stream<List<DocumentSnapshot>> _getTotalOrdersStream() {
    return FirebaseFirestore.instance
        .collection('tb_order')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('          Late ETD Analysis'),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _lateETDOrdersStream,
        builder: (context, lateSnapshot) {
          return StreamBuilder<List<DocumentSnapshot>>(
            stream: _totalOrdersStream,
            builder: (context, totalSnapshot) {
              if (lateSnapshot.connectionState == ConnectionState.waiting ||
                  totalSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (lateSnapshot.hasError || totalSnapshot.hasError) {
                debugPrint(lateSnapshot.error
                    as String?); // Print error message for debugging
                debugPrint(totalSnapshot.error
                    as String?); // Print error message for debugging
                return Center(
                  child: Text(
                      'Error: ${lateSnapshot.error ?? totalSnapshot.error}'),
                );
              } else if (lateSnapshot.hasData && totalSnapshot.hasData) {
                // Extract data for chart
                List<ChartData> lateETDChartData =
                    _extractLateETDChartData(lateSnapshot.data!);
                List<ChartData> totalOrderChartData =
                    _extractTotalOrderChartData(totalSnapshot.data!);

                // Calculate category counts
                Map<String, int> categoryCounts =
                    _calculateCategoryCounts(lateSnapshot.data!);

                return Column(
                  children: [
                    // Display chart
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          title: AxisTitle(text: 'Month'),
                          labelRotation: 90, // Rotate labels vertically
                        ),
                        primaryYAxis: const NumericAxis(
                          title: AxisTitle(text: 'Number of Orders'),
                        ),
                        legend: const Legend(isVisible: true),
                        series: <CartesianSeries>[
                          // Late ETD Orders series
                          ColumnSeries<ChartData, String>(
                            name: 'Late Orders',
                            dataSource: lateETDChartData,
                            xValueMapper: (ChartData data, _) => data.month,
                            yValueMapper: (ChartData data, _) => data.count,
                            color: const Color.fromARGB(255, 255, 0, 0),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                          // Total Orders series
                          ColumnSeries<ChartData, String>(
                            name: 'Total Orders',
                            dataSource: totalOrderChartData,
                            xValueMapper: (ChartData data, _) => data.month,
                            yValueMapper: (ChartData data, _) => data.count,
                            color: const Color.fromARGB(255, 0, 26, 255),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Analysis BO LT Average button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BOLTAnalysisPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.pink, // Set button color to pink
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Colors.white, // Set icon color to white
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Analysis BO LT Average',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.blue,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Slightly Late: ${categoryCounts["Slightly Late"]}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  color: Colors.orange,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Moderately Late: ${categoryCounts["Moderately Late"]}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.exclamationCircle,
                                  color: Colors.red,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Severely Late: ${categoryCounts["Severely Late"]}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add Recommendations
                    Expanded(
                      child: ListView(
                        children: _generateRecommendations(lateSnapshot.data!),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text('No orders found.'),
                );
              }
            },
          );
        },
      ),
    );
  }

  bool isLateOrder(Timestamp etdTimestamp) {
    DateTime etdDate = etdTimestamp.toDate();
    return etdDate.isBefore(DateTime.now());
  }

  String getLateCategory(Timestamp etdTimestamp) {
    DateTime etdDate = etdTimestamp.toDate();
    int daysLate = DateTime.now().difference(etdDate).inDays;

    if (daysLate <= 7) {
      return "Slightly Late";
    } else if (daysLate <= 14) {
      return "Moderately Late";
    } else {
      return "Severely Late";
    }
  }

  List<ChartData> _extractLateETDChartData(List<DocumentSnapshot> data) {
    Map<String, int> lateETDCounts = {
      for (int i = 1; i <= 12; i++)
        DateFormat.MMMM().format(DateTime(2022, i)): 0
    };

    // Loop through each document to count late ETD orders for each month
    for (var order in data) {
      DateTime orderDate = (order['order_date'] as Timestamp).toDate();
      Timestamp? etdTimestamp = order['ETD'] as Timestamp?;

      if (etdTimestamp != null) {
        if (isLateOrder(etdTimestamp)) {
          String month = DateFormat.MMMM().format(
              orderDate); // Menggunakan tanggal order untuk menentukan bulan
          lateETDCounts[month] = lateETDCounts[month]! + 1;
        }
      }
    }

    // Convert map to list of ChartData
    return lateETDCounts.entries.map((entry) {
      return ChartData(entry.key, entry.value);
    }).toList();
  }

  List<ChartData> _extractTotalOrderChartData(List<DocumentSnapshot> data) {
    Map<String, int> totalOrderCounts = {
      for (int i = 1; i <= 12; i++)
        DateFormat.MMMM().format(DateTime(2022, i)): 0
    };

    // Loop through each document to count total orders for each month
    for (var order in data) {
      DateTime orderDate = (order['order_date'] as Timestamp).toDate();
      String month = DateFormat.MMMM().format(orderDate);

      // Increase total order count for the respective month
      totalOrderCounts[month] = totalOrderCounts[month]! + 1;
    }

    // Convert map to list of ChartData
    return totalOrderCounts.entries.map((entry) {
      return ChartData(entry.key, entry.value);
    }).toList();
  }

  Map<String, int> _calculateCategoryCounts(List<DocumentSnapshot> data) {
    Map<String, int> categoryCounts = {
      "Slightly Late": 0,
      "Moderately Late": 0,
      "Severely Late": 0,
    };

    for (var order in data) {
      Timestamp? etdTimestamp = order['ETD'] as Timestamp?;
      if (etdTimestamp != null && isLateOrder(etdTimestamp)) {
        String category = getLateCategory(etdTimestamp);
        categoryCounts[category] = categoryCounts[category]! + 1;
      }
    }

    return categoryCounts;
  }

  List<Widget> _generateRecommendations(List<DocumentSnapshot> data) {
    List<Widget> recommendations = [];

    for (var order in data) {
      Timestamp? etdTimestamp = order['ETD'] as Timestamp?;
      if (etdTimestamp != null && isLateOrder(etdTimestamp)) {
        String category = getLateCategory(etdTimestamp);
        String recommendation = getRecommendation(category);
        String orderNumber = order['order_number'] as String? ?? 'Unknown';
        recommendations.add(
          Card(
            color: Colors.pink,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Number: $orderNumber',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Recommendation: $recommendation',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return recommendations;
  }

  String getRecommendation(String category) {
    switch (category) {
      case "Severely Late":
        return "Send a reminder email to the customer.";
      case "Moderately Late":
        return "Call the customer to update them on the delay.";
      case "Slightly Late":
        return "Consider exploring alternative part number for timely fulfillment.";
      default:
        return "No recommendation available.";
    }
  }
}

class ChartData {
  final String month;
  final int count;

  ChartData(this.month, this.count);
}
