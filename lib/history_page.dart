import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoryBackOrderPage extends StatelessWidget {
  const HistoryBackOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Back-Order'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tb_history').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String custCode = data['cust_code'] ?? '';
              final String orderNumber = data['order_number'] ?? '';
              final String partNumber = data['part_number'] ?? '';
              final String orderQty =
                  data['order_qty'].toString(); // Konversi ke string

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: Colors.pink,
                  ),
                ),
                color: Colors.grey[200],
                child: ListTile(
                  leading: const FaIcon(
                    FontAwesomeIcons.history,
                    color: Colors.pink,
                  ),
                  title: const Text(
                    'Customer Code',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person, // Icon customer code
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            custCode,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.format_list_numbered, // Icon order number
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            orderNumber,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.widgets, // Icon part number
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            partNumber,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart, // Icon order quantity
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            orderQty,
                            style: const TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
