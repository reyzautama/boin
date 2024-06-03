// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary BO Report'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showDateFilterDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tb_order').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData) {
              final documents = snapshot.data!.docs;

              // Calculate total orders
              int totalOrders = documents.length;

              // Calculate late orders
              DateTime currentDate = DateTime.now();
              int lateOrders = documents.where((doc) {
                Timestamp? etdTimestamp = doc['ETD'];
                if (etdTimestamp != null) {
                  DateTime etdDate = etdTimestamp.toDate();
                  return etdDate.isBefore(currentDate);
                }
                return false;
              }).length;

              // Calculate total ETD terlambat
              int totalLateETD = documents.where((doc) {
                Timestamp? etdTimestamp = doc['ETD'];
                if (etdTimestamp != null) {
                  DateTime etdDate = etdTimestamp.toDate();
                  return etdDate.isBefore(currentDate);
                }
                return false;
              }).length;

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Order Summary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildOrderCard(
                              title: 'Total Orders',
                              value: '$totalOrders',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildOrderCard(
                              title: 'Late Orders',
                              value: '$lateOrders',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                    Column(
                      children: [
                        const Text(
                          'Back Order Data by Cust Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildBOChart(documents),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total ETD Terlambat: $totalLateETD',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 10,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBOChart(List<DocumentSnapshot> documents) {
    // Calculate total orders and late orders per cust_code
    Map<String, int> totalOrdersPerCust = {};
    Map<String, int> lateOrdersPerCust = {};

    DateTime currentDate = DateTime.now();

    for (var doc in documents) {
      String custCode = doc['cust_code'];

      // Increment total orders count for this customer
      if (totalOrdersPerCust.containsKey(custCode)) {
        totalOrdersPerCust[custCode] = totalOrdersPerCust[custCode]! + 1;
      } else {
        totalOrdersPerCust[custCode] = 1;
      }

      // Check if the order is late and increment late orders count for this customer
      Timestamp? etdTimestamp = doc['ETD'];
      if (etdTimestamp != null) {
        DateTime etdDate = etdTimestamp.toDate();
        if (etdDate.isBefore(currentDate)) {
          if (lateOrdersPerCust.containsKey(custCode)) {
            lateOrdersPerCust[custCode] = lateOrdersPerCust[custCode]! + 1;
          } else {
            lateOrdersPerCust[custCode] = 1;
          }
        }
      }
    }

    // Prepare chart data
    final List<ChartData> totalOrdersChartData = [];
    final List<ChartData> lateOrdersChartData = [];

    totalOrdersPerCust.forEach((custCode, count) {
      totalOrdersChartData.add(ChartData(custCode, count));
      lateOrdersChartData
          .add(ChartData(custCode, lateOrdersPerCust[custCode] ?? 0));
    });

    return SizedBox(
      width: 600, // Width of the chart to make it scrollable horizontally
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            name: 'Total Orders',
            dataSource: totalOrdersChartData,
            xValueMapper: (ChartData data, _) => data.custCode,
            yValueMapper: (ChartData data, _) => data.count,
            color: Colors.green,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
          ColumnSeries<ChartData, String>(
            name: 'Late Orders',
            dataSource: lateOrdersChartData,
            xValueMapper: (ChartData data, _) => data.custCode,
            yValueMapper: (ChartData data, _) => data.count,
            color: Colors.red,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
        legend: const Legend(isVisible: true),
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Date Range',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Select start date:'),
                    SizedBox(
                      height: 200,
                      child: CalendarDatePicker(
                        initialDate: _selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (selectedDate) {
                          setState(() {
                            _selectedStartDate = selectedDate;
                          });
                        },
                      ),
                    ),
                    const Text('Select end date:'),
                    SizedBox(
                      height: 200,
                      child: CalendarDatePicker(
                        initialDate: _selectedEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (selectedDate) {
                          setState(() {
                            _selectedEndDate = selectedDate;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.pink)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply',
                        style: TextStyle(color: Colors.pink)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.custCode, this.count);
  final String custCode;
  final int count;
}
