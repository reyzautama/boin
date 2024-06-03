import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BOReportPage extends StatefulWidget {
  const BOReportPage({Key? key}) : super(key: key);

  @override
  BOReportPageState createState() => BOReportPageState();
}

class BOReportPageState extends State<BOReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back Order Monitoring Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('back_order_reports')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var report = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(report['product_name']),
                    subtitle: Text(
                        'Back Order Quantity: ${report['back_order_quantity']}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
