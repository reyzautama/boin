import 'package:boin/edit_order.dart';
import 'package:boin/input_order.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersPage extends StatelessWidget {
  final String loggedInUser;

  const ManageOrdersPage({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sentiment_satisfied_alt_rounded,
                        size: 100,
                        color:
                            Color.fromARGB(255, 255, 0, 204)), // Icon welcome
                    const SizedBox(width: 10), // Spacer
                    Text(
                      'Welcome, $loggedInUser!',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Text(
                'Manage Orders Page',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GWButton(
                          text: 'Add Order',
                          icon: Icons.add,
                          iconColor: Colors.yellow,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InputOrderPage(
                                  loggedInUser: '',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GWButton(
                          text: 'Clean Orders',
                          icon: Icons.delete_forever,
                          iconColor: Colors.yellow,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete All Orders'),
                                  content: const Text(
                                      'Are you sure you want to delete all orders?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('tb_order')
                                            .get()
                                            .then((snapshot) {
                                          for (DocumentSnapshot doc
                                              in snapshot.docs) {
                                            doc.reference.delete();
                                          }
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GWButton(
                text: 'Edit Orders',
                icon: Icons.edit,
                iconColor: Colors.yellow,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditOrderPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GWButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const GWButton(
      {Key? key,
      required this.text,
      required this.icon,
      required this.iconColor,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor,
      ),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        minimumSize: const Size(double.infinity, 0), // Ukuran minimal tombol
      ),
    );
  }
}
