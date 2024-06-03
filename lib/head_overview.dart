import 'package:boin/analisys.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  OverviewPageState createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  int _totalUsers = 0;
  int _totalAdmins = 0;
  int _totalHeadUsers = 0;
  int _totalOrders = 0;
  int _totalSupply = 0;
  int _totalBO = 0;
  int _totalCanceledOrders = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchOrderData();
  }

  Future<void> _fetchUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('tb_users').get();

      int totalUsers = snapshot.size;
      int totalAdmins = 0;
      int totalHeadUsers = 0;

      for (var doc in snapshot.docs) {
        String role = doc.data()['role'];
        if (role == 'admin') {
          totalAdmins++;
        } else if (role == 'head') {
          totalHeadUsers++;
        }
      }

      setState(() {
        _totalUsers = totalUsers;
        _totalAdmins = totalAdmins;
        _totalHeadUsers = totalHeadUsers;
      });
    } catch (error) {
      debugPrint('Error fetching user data: $error');
    }
  }

  Future<void> _fetchOrderData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('tb_order').get();

      int totalOrders = 0;
      int totalSupply = 0;
      int totalBO = 0;
      int totalCanceledOrders = 0;

      for (var doc in snapshot.docs) {
        int orderQty = doc.data()['order_qty'];
        int supplyQty = doc.data()['supply_qty'];
        int boQty = doc.data()['bo_qty'];
        int cancelQty = doc.data()['cancel_qty'];

        totalOrders += orderQty;

        // Adding quantities to each category
        totalSupply += supplyQty;
        totalBO += boQty;
        totalCanceledOrders += cancelQty;
      }

      setState(() {
        _totalOrders = totalOrders;
        _totalSupply = totalSupply;
        _totalBO = totalBO;
        _totalCanceledOrders = totalCanceledOrders;
      });
    } catch (error) {
      debugPrint('Error fetching order data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalysisPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 4.0, backgroundColor: Colors.pink,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                side: BorderSide(color: Colors.white), // Border color
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0), // Button color
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.white,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Analysis',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white), // Set text color to white
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary Information',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 20.0),
            _buildInfoCard(
              title: 'Order Data',
              children: [
                _buildInfoRow('Total Orders', '$_totalOrders'),
                _buildInfoRow('Total Order Qty', '$_totalOrders'),
                _buildInfoRow('Total Supply Qty', '$_totalSupply'),
                _buildInfoRow('Total BO Qty', '$_totalBO'),
                _buildInfoRow('Total Cancel Qty', '$_totalCanceledOrders'),
              ],
            ),
            const SizedBox(height: 20.0),
            _buildInfoCard(
              title: 'User Statistics',
              children: [
                _buildInfoRow('Total Users', '$_totalUsers'),
                _buildInfoRow('Total Admins', '$_totalAdmins'),
                _buildInfoRow('Total Head Users', '$_totalHeadUsers'),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.pink,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.pink),
                const SizedBox(width: 10.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Column(
              children: [
                for (int i = 0; i < children.length; i++)
                  Column(
                    children: [
                      children[i],
                      if (i != children.length - 1)
                        const Divider(), // Tambahkan garis pemisah kecuali untuk baris terakhir
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
