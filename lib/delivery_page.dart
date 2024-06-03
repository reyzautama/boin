import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// Enum untuk jenis filter
// ignore: constant_identifier_names
enum FilterField { CustomerCode, OrderNumber, PartNumber }

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({Key? key, required this.loggedInUser}) : super(key: key);

  final String loggedInUser;

  @override
  DeliveryPageState createState() => DeliveryPageState();
}

class DeliveryPageState extends State<DeliveryPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _ordersStream;

  // Tambahkan StreamController
  late StreamController<bool> _refreshController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _ordersStream =
        FirebaseFirestore.instance.collection('tb_order').snapshots();

    // Inisialisasi StreamController
    _refreshController = StreamController<bool>.broadcast();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Tutup StreamController
    _refreshController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<bool>(
        stream: _refreshController.stream,
        builder: (context, snapshot) {
          // Bangun kembali tampilan DeliveryPage saat menerima sinyal refresh
          return _buildDeliveryPage();
        },
      ),
    );
  }

  Widget _buildDeliveryPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (searchText) {
              _filterOrders(searchText.toLowerCase());
            },
            decoration: InputDecoration(
              labelText:
                  'Search by Customer Code, Order Number, or Part Number',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterOrders('');
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.pink),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.pink),
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.pink),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final orderData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return OrderCard(
                      orderData: orderData,
                      docId: snapshot.data!.docs[index].id,
                      searchText: _searchController.text.toLowerCase(),
                      // Tambahkan fungsi refresh ke OrderCard
                      onRefresh: _refreshController.add,
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _filterOrders(String searchText) {
    setState(() {
      _ordersStream =
          FirebaseFirestore.instance.collection('tb_order').snapshots();
    });
  }
}

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String docId;
  final String searchText;
  final Function(bool) onRefresh; // Fungsi refresh

  const OrderCard({
    Key? key,
    required this.orderData,
    required this.docId,
    required this.searchText,
    required this.onRefresh, // Tambahkan parameter fungsi refresh
  }) : super(key: key);

  @override
  OrderCardState createState() => OrderCardState();
}

class OrderCardState extends State<OrderCard> {
  bool isExpanded = false;
  DateTime? supplyDate;

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _releaseOrder() async {
    final orderDoc =
        FirebaseFirestore.instance.collection('tb_order').doc(widget.docId);
    final orderData = (await orderDoc.get()).data() as Map<String, dynamic>;

    // Buat kunci unik berdasarkan kombinasi cust_code, order_number, dan part_number
    final uniqueKey =
        "${orderData['cust_code']}_${orderData['order_number']}_${orderData['part_number']}";

    // Cek apakah data dengan kunci unik tersebut sudah ada di tb_history
    final historySnapshot = await FirebaseFirestore.instance
        .collection('tb_history')
        .doc(uniqueKey)
        .get();
    if (historySnapshot.exists) {
      // Jika sudah ada, hapus order dari tb_order dan refresh page
      await orderDoc.delete();
      widget.onRefresh(
          true); // Panggil fungsi refresh dengan true sebagai argumen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order already exists in history.'),
        ));
      }
      return;
    }

    // Jika belum ada, pindahkan data ke tb_history
    orderData['supply_date'] = Timestamp.fromDate(supplyDate!);
    final historyDoc =
        FirebaseFirestore.instance.collection('tb_history').doc(uniqueKey);
    await historyDoc.set(orderData);

    // Hapus data dari tb_order
    await orderDoc.delete();

    // Ketika proses selesai, panggil fungsi refresh
    widget.onRefresh(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Order released and moved to history.'),
      ));
    }
  }

  void _confirmReleaseOrder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Release'),
          content: const Text('Are you sure you want to release this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) {
                  _releaseOrder();
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderInfoWithIcon(
      String label, dynamic value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            iconData,
            color: Colors.pink,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
              if (mounted) {
                setState(() {
                  supplyDate = pickedDate;
                });
              }
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
          ),
          child: Text(
            supplyDate != null
                ? DateFormat('dd/MM/yyyy').format(supplyDate!)
                : 'Select Date',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderData = widget.orderData;

    final customerCode = orderData['cust_code'].toString().toLowerCase();
    final orderNumber = orderData['order_number'].toString().toLowerCase();
    final partNumber = orderData['part_number'].toString().toLowerCase();

    // Lakukan filter berdasarkan data yang ditampilkan di card view
    if (customerCode.contains(widget.searchText) ||
        orderNumber.contains(widget.searchText) ||
        partNumber.contains(widget.searchText)) {
      return Card(
        color: Colors.white,
        elevation: 2.0,
        shadowColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ExpansionTile(
          title: Text(
            'Order Number: ${orderData['order_number']}',
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfoWithIcon(
                    'Order Date',
                    _formatDate(orderData['order_date']),
                    Icons.calendar_today,
                  ),
                  _buildOrderInfoWithIcon(
                      'Customer Code', orderData['cust_code'], Icons.person),
                  _buildOrderInfoWithIcon(
                    'Order Number',
                    orderData['order_number'],
                    Icons.confirmation_number,
                  ),
                  _buildOrderInfoWithIcon(
                    'Part Number',
                    orderData['part_number'],
                    Icons.widgets,
                  ),
                  _buildOrderInfoWithIcon(
                    'Order Qty',
                    orderData['order_qty'],
                    Icons.add_shopping_cart,
                  ),
                  _buildOrderInfoWithIcon(
                    'Supply Qty',
                    orderData['supply_qty'],
                    Icons.inventory,
                  ),
                  _buildOrderInfoWithIcon(
                    'Backorder Qty',
                    orderData['bo_qty'],
                    Icons.repeat,
                  ),
                  _buildOrderInfoWithIcon(
                    'Cancel Qty',
                    orderData['cancel_qty'],
                    Icons.cancel,
                  ),
                  _buildOrderInfoWithIcon(
                    'Remark',
                    orderData['remark'],
                    Icons.info,
                  ),
                  _buildOrderInfoWithIcon(
                    'ETD',
                    _formatDate(orderData['ETD']),
                    Icons.date_range,
                  ),
                  _buildDatePicker('Supply Date', (date) {
                    if (mounted) {
                      setState(() {
                        supplyDate = date;
                      });
                    }
                  }),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed:
                          supplyDate != null ? _confirmReleaseOrder : null,
                      icon: const Icon(Icons.send),
                      label: const Text('Release Order'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.pink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Jika tidak ada kecocokan, tampilkan widget kosong
      return const SizedBox.shrink();
    }
  }
}
