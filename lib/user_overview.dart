import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserOverviewPage extends StatelessWidget {
  const UserOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.pink), // Icon di judul
            SizedBox(width: 8), // Spasi antara ikon dan teks
            Text(
              'Overview',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle('Summary of Orders', Icons.shopping_cart),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('tb_order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found'));
                } else {
                  // Hitung total jumlah pesanan
                  int totalOrders = snapshot.data!.docs.length;

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total Orders: $totalOrders',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Customer Code')),
                              DataColumn(label: Text('Order Number')),
                              DataColumn(label: Text('Part Number')),
                              DataColumn(label: Text('BO Quantity')),
                            ],
                            rows: snapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    data['cust_code'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['order_number'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['part_number'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['bo_qty'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Summary of History', Icons.history),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tb_history')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No history found'));
                } else {
                  // Hitung total jumlah history
                  int totalHistory = snapshot.data!.docs.length;

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total History: $totalHistory',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Customer Code')),
                              DataColumn(label: Text('Order Number')),
                              DataColumn(label: Text('Part Number')),
                              DataColumn(label: Text('Order Quantity')),
                            ],
                            rows: snapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    data['cust_code'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['order_number'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['part_number'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['order_qty'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Summary of Customers', Icons.people),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tb_customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No customers found'));
                } else {
                  // Hitung total jumlah pelanggan
                  int totalCustomers = snapshot.data!.docs.length;

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total Customers: $totalCustomers',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Customer Code')),
                              DataColumn(label: Text('Customer Name')),
                              DataColumn(label: Text('Address')),
                              DataColumn(label: Text('Customer Type')),
                            ],
                            rows: snapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    data['customer_code'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['customer_name'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['address'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['customer_type'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.pink), // Icon di judul
        const SizedBox(width: 8), // Spasi antara ikon dan teks
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
      ],
    );
  }
}
