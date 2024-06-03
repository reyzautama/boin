import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import library for date formatting

// Enum to represent ETD status
enum ETDStatus {
  onTime,
  arrived,
  slightlyLate,
  moderatelyLate,
  severelyLate,
}

class DetailsPage extends StatefulWidget {
  final String loggedInUser;

  const DetailsPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  GenerateReportsPageState createState() => GenerateReportsPageState();
}

class GenerateReportsPageState extends State<DetailsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  // Function to fetch and display customer names
  Future<String> _getCustomerName(String custCode) async {
    QuerySnapshot<Map<String, dynamic>> customerSnapshot =
        await FirebaseFirestore.instance
            .collection('tb_customers')
            .where('customer_code', isEqualTo: custCode)
            .get();

    if (customerSnapshot.docs.isNotEmpty) {
      var customerData = customerSnapshot.docs.first.data();
      return customerData['customer_name'] ?? 'Customer Name Not Found';
    } else {
      return 'Customer Name Not Found';
    }
  }

  // Function to determine ETD status
  ETDStatus _getETDStatus(DateTime etd) {
    DateTime now = DateTime.now();
    int leadTime = etd.difference(now).inDays;

    if (leadTime >= 0) {
      if (leadTime == 0) {
        return ETDStatus.arrived;
      } else {
        return ETDStatus.onTime;
      }
    } else if (leadTime >= -3) {
      return ETDStatus.slightlyLate;
    } else if (leadTime >= -7) {
      return ETDStatus.moderatelyLate;
    } else {
      return ETDStatus.severelyLate;
    }
  }

  // Function to display action based on ETD status
  String _getActionFromETDStatus(ETDStatus status) {
    switch (status) {
      case ETDStatus.onTime:
        return 'No action required. ETD is on time.';
      case ETDStatus.arrived:
        return 'Please Check GT System. ETD has arrived today.';
      case ETDStatus.slightlyLate:
        return 'Monitor closely. ETD is slightly late.';
      case ETDStatus.moderatelyLate:
        return 'Take action. ETD is moderately late.';
      case ETDStatus.severelyLate:
        return 'Urgent action required! ETD is severely late.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        // Define futuristic theme properties
        primaryColor: Colors.pinkAccent, // Set primary color to pink
        scaffoldBackgroundColor: Colors.white, // Set background color to white
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.black87), // Set text color to black
          titleMedium:
              TextStyle(color: Colors.blue), // Set subtitle color to blue
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details Pages'),
          backgroundColor: Colors.pink, // Set app bar background color to pink
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search (Cust Code, Order Number, Part Number)',
                    prefixIcon: Icon(Icons.search,
                        color: Colors.pink), // Set search icon color to pink
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Trigger rebuild when text changes
                    });
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tb_order')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Show loading indicator while waiting for data
                  }

                  // Filter the data based on search query
                  final filteredData = snapshot.data!.docs.where((document) {
                    final data = document.data() as Map<String, dynamic>;
                    final searchQuery = _searchController.text.toLowerCase();
                    final custCode = data['cust_code'].toString().toLowerCase();
                    final orderNumber =
                        data['order_number'].toString().toLowerCase();
                    final partNumber =
                        data['part_number'].toString().toLowerCase();
                    return custCode.contains(searchQuery) ||
                        orderNumber.contains(searchQuery) ||
                        partNumber.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredData[index].data() as Map<String, dynamic>;
                      final DateFormat formatter =
                          DateFormat('MMM dd, yyyy hh:mm a');
                      final String etdFormatted =
                          formatter.format(data['ETD'].toDate());
                      final String orderDateFormatted =
                          formatter.format(data['order_date'].toDate());
                      final Duration ageDuration = data['ETD']
                          .toDate()
                          .difference(data['order_date'].toDate());
                      final String age = '${ageDuration.inDays} days';

                      // Determine ETD status
                      ETDStatus etdStatus = _getETDStatus(data['ETD'].toDate());
                      // Get action based on ETD status
                      String action = _getActionFromETDStatus(etdStatus);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(10),
                        child: ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.article_outlined,
                                      color:
                                          Colors.pink), // Icon for Order Number
                                  const SizedBox(width: 5),
                                  Text('Order Number: ${data['order_number']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.pink), // Icon for Cust Code
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: FutureBuilder<String>(
                                      future:
                                          _getCustomerName(data['cust_code']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(
                                            'Customer Code: ${data['cust_code']}',
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Customer Code: ${data['cust_code']}',
                                              style: TextStyle(
                                                fontSize:
                                                    12, // adjust the font size as needed
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Customer Name: ${snapshot.data}',
                                              style: TextStyle(
                                                fontSize:
                                                    12, // adjust the font size as needed
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.build_circle,
                                      color:
                                          Colors.pink), // Icon for Part Number
                                  const SizedBox(width: 5),
                                  Text('Part Number: ${data['part_number']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            ListTile(
                              title: Text('Order Qty: ${data['order_qty']}'),
                            ),
                            ListTile(
                              title: Text('Supply Qty: ${data['supply_qty']}'),
                            ),
                            ListTile(
                              title: Text('BO Qty: ${data['bo_qty']}'),
                            ),
                            ListTile(
                              title: Text('Cancel Qty: ${data['cancel_qty']}'),
                            ),
                            ListTile(
                              title: Text('Remark: ${data['remark']}'),
                            ),
                            ListTile(
                              title: Text('Order Date: $orderDateFormatted'),
                            ),
                            ListTile(
                              title: Text('ETD: $etdFormatted'),
                            ),
                            ListTile(
                              title: Text('Age: $age'),
                            ),
                            ListTile(
                              title: Text('Action: $action'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
