// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputOrderPage extends StatefulWidget {
  final String loggedInUser;

  const InputOrderPage({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  InputOrderPageState createState() => InputOrderPageState();
}

class InputOrderPageState extends State<InputOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final TextEditingController custCodeController = TextEditingController();
  final TextEditingController orderNumberController = TextEditingController();
  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController supplyQtyController = TextEditingController();
  final TextEditingController boQtyController = TextEditingController();
  final TextEditingController cancelQtyController = TextEditingController();
  final TextEditingController etdController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  late TextEditingController orderDateController;
  late TextEditingController etdDateController;
  TextEditingController orderQtyController = TextEditingController(); // Added

  DateTime? selectedOrderDate;
  DateTime? selectedEtdDate;

  @override
  void initState() {
    super.initState();
    orderDateController = TextEditingController();
    etdDateController = TextEditingController();
    orderQtyController.text = '0'; // Added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _selectDate(context, orderDateController, (pickedDate) {
                      setState(() {
                        selectedOrderDate = pickedDate;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Order Date',
                        suffixIcon: Icon(
                          FontAwesomeIcons.calendarAlt,
                          color: Colors.pink, // Pink color for icon
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.pink), // Pink color for border
                        ),
                      ),
                      controller: orderDateController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select order date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                TextFormField(
                  controller: custCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Code',
                    prefixIcon: Icon(
                      FontAwesomeIcons.addressCard,
                      color: Color.fromARGB(255, 17, 0, 255),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer code';
                    }
                    if (value.length != 5) {
                      return 'Customer code must be exactly 5 characters';
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        5), // Membatasi input menjadi 5 karakter
                  ],
                ),
                TextFormField(
                  controller: orderNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Order Number',
                    prefixIcon: Icon(
                      FontAwesomeIcons.receipt,
                      color: Color.fromARGB(
                          255, 0, 17, 255), // Pink color for icon
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink), // Pink color for border
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter order number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: partNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Part Number',
                    prefixIcon: Icon(
                      FontAwesomeIcons.cogs,
                      color: Color.fromARGB(
                          255, 45, 0, 248), // Pink color for icon
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink), // Pink color for border
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter part number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: supplyQtyController,
                  decoration: const InputDecoration(
                    labelText: 'Supply Quantity',
                    prefixIcon: Icon(
                      FontAwesomeIcons.archive,
                      color: Color.fromARGB(255, 0, 155, 24),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 247, 0, 0)), // Pink color for border
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateOrderQuantity();
                  },
                ),
                TextFormField(
                  controller: boQtyController,
                  decoration: const InputDecoration(
                    labelText: 'BO Quantity',
                    prefixIcon: Icon(
                      FontAwesomeIcons.hourglassHalf,
                      color: Colors.pink, // Pink color for icon
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink), // Pink color for border
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateOrderQuantity();
                  },
                ),
                TextFormField(
                  controller: cancelQtyController,
                  decoration: const InputDecoration(
                    labelText: 'Cancel Quantity',
                    prefixIcon: Icon(
                      FontAwesomeIcons.minusCircle,
                      color: Color.fromARGB(
                          255, 90, 90, 90), // Pink color for icon
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink), // Pink color for border
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateOrderQuantity();
                  },
                ),
                TextFormField(
                  controller: orderQtyController,
                  decoration: const InputDecoration(
                    labelText: 'Order Quantity',
                    prefixIcon: Icon(
                      FontAwesomeIcons.shoppingCart,
                      color: Colors.pink, // Pink color for icon
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink), // Pink color for border
                    ),
                  ),
                  enabled: false, // Disable user input
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context, etdDateController, (pickedDate) {
                      setState(() {
                        selectedEtdDate = pickedDate;
                      });
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'ETD',
                        suffixIcon: Icon(
                          FontAwesomeIcons.calendarAlt,
                          color: Colors.pink, // Pink color for icon
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.pink), // Pink color for border
                        ),
                      ),
                      controller: etdDateController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select ETD';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitOrder(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Background color pink
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white, // Text color white
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to update order quantity
  void updateOrderQuantity() {
    int supplyQty = int.tryParse(supplyQtyController.text) ?? 0;
    int boQty = int.tryParse(boQtyController.text) ?? 0;
    int cancelQty = int.tryParse(cancelQtyController.text) ?? 0;

    int orderQty = supplyQty + boQty + cancelQty;
    orderQtyController.text = orderQty.toString();
  }

  // Function to select date
  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      Function(DateTime) onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2999, 1, 1),
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      controller.text = formattedDate;
      onDateSelected(pickedDate);
    }
  }

  // Function to submit order
  Future<void> _submitOrder(BuildContext context) async {
    // Prepare order data
    Map<String, dynamic> orderData = {
      'order_date': selectedOrderDate,
      'cust_code': custCodeController.text,
      'order_number': orderNumberController.text,
      'part_number': partNumberController.text,
      'order_qty': int.tryParse(orderQtyController.text) ?? 0,
      'supply_qty': int.tryParse(supplyQtyController.text) ?? 0,
      'bo_qty': int.tryParse(boQtyController.text) ?? 0,
      'cancel_qty': int.tryParse(cancelQtyController.text) ?? 0,
      'ETD':
          selectedEtdDate != null ? Timestamp.fromDate(selectedEtdDate!) : null,
      'remark': remarkController.text,
    };

    try {
      // Check if the combination of cust_code, order_number, and part_number already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tb_order')
          .where('cust_code', isEqualTo: custCodeController.text)
          .where('order_number', isEqualTo: orderNumberController.text)
          .where('part_number', isEqualTo: partNumberController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Combination already exists, show error message and clear all fields
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Combination of customer, order number, and part number already exists.'),
            backgroundColor: Colors.red,
          ),
        );

        // Clear all fields
        custCodeController.clear();
        orderNumberController.clear();
        partNumberController.clear();
        supplyQtyController.clear();
        boQtyController.clear();
        cancelQtyController.clear();
        etdDateController.clear();
        remarkController.clear();
        selectedOrderDate = null;
        selectedEtdDate = null;
        orderQtyController.text = '0';

        return; // Stop further execution
      }

      // Add order data to Firestore
      await FirebaseFirestore.instance.collection('tb_order').add(orderData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order added successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to previous page
      Navigator.pop(context);
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
