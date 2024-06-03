// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  UploadPageState createState() => UploadPageState();
}

class UploadPageState extends State<UploadPage> {
  String _selectedFilePath = '';
  String _uploadMessage = '';
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload File',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.pink, Colors.purple],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add logic for icon here
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                icon: const Icon(
                  Icons.attach_file,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                label: const Text(
                  'Pick a CSV File',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Press this button to pick a CSV file from your device.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Selected File Path: $_selectedFilePath',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _showDataDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                icon: const Icon(
                  Icons.table_chart,
                  color: Color.fromARGB(255, 253, 253, 253),
                ),
                label: const Text(
                  'Show Data',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                icon: const Icon(
                  Icons.cloud_upload,
                  color: Color.fromARGB(255, 253, 253, 253),
                ),
                label: const Text(
                  'Upload File to Firestore',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_uploadProgress > 0.0 && _uploadProgress < 1.0)
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            const SizedBox(height: 10),
            Text(
              _uploadMessage,
              style: TextStyle(
                fontSize: 14,
                color: _uploadMessage.startsWith('Error')
                    ? Colors.red
                    : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            _selectedFilePath = result.files.first.path ?? '';
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File selection canceled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath.isEmpty) {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _uploadMessage = 'Please pick a file first';
        });
      }
      return;
    }

    try {
      if (mounted) {
        // Check if widget is still mounted
        // Memulai proses upload
        setState(() {
          _isUploading = true;
          _uploadMessage = 'Uploading file...';
          _uploadProgress = 0.0;
        });
      }

      final file = File(_selectedFilePath);
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Memproses data CSV
      await _processCSVData(fields);

      if (mounted) {
        // Check if widget is still mounted
        // Memberikan sinyal bahwa proses selesai
        setState(() {
          _isUploading = false;
          _uploadMessage = 'File uploaded successfully';
          _uploadProgress = 1.0;
        });
      }

      // Sinyal bahwa proses upload selesai, Anda dapat menambahkan logika tambahan di sini
      debugPrint('Upload process completed');
    } catch (e) {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _isUploading = false;
          _uploadMessage = 'Error uploading file: $e';
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _processCSVData(List<List<dynamic>> csvData) async {
    final CollectionReference orders =
        FirebaseFirestore.instance.collection('tb_order');

    Set<String> uniqueCombinationSet = <String>{};
    List<String> duplicatedData = [];

    for (int i = 1; i < csvData.length; i++) {
      var rowData = csvData[i];

      try {
        debugPrint('Row Data: ${rowData[0].toString()}');

        // Periksa apakah jumlah kolom dalam rowData sesuai dengan yang diharapkan
        if (rowData.length != 10) {
          debugPrint('Error uploading row $i: Invalid row data');
          setState(() {
            _uploadMessage = 'Error uploading row $i: Invalid row data';
          });
          continue;
        }

        // Map kolom CSV ke field Firestore
        var orderDate = _parseDate(rowData[0]);
        var custCode = rowData[1].toString();
        var orderNumber = rowData[2].toString();
        var partNumber = rowData[3].toString();
        var orderQty = int.parse(rowData[4].toString());
        var supplyQty = int.parse(rowData[5].toString());
        var boQty = int.parse(rowData[6].toString());
        var cancelQty = int.parse(rowData[7].toString());
        var etd = _parseDate(rowData[8]);
        var remark = rowData[9].toString();

        // Check for duplicate data
        String combinationKey = '$custCode$orderNumber$partNumber';
        if (uniqueCombinationSet.contains(combinationKey)) {
          // Duplicate data found
          duplicatedData.add(
              'Row $i: cust_code: $custCode, order_number: $orderNumber, part_number: $partNumber');
          continue;
        }

        // Check if the combination already exists in Firestore
        var querySnapshot = await orders
            .where('cust_code', isEqualTo: custCode)
            .where('order_number', isEqualTo: orderNumber)
            .where('part_number', isEqualTo: partNumber)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Duplicate data found in Firestore
          duplicatedData.add(
              'Row $i: cust_code: $custCode, order_number: $orderNumber, part_number: $partNumber');
          continue;
        }

        // Add the combination to the unique set
        uniqueCombinationSet.add(combinationKey);

        // Input data ke Firestore
        await orders.add({
          'order_date': orderDate,
          'cust_code': custCode,
          'order_number': orderNumber,
          'part_number': partNumber,
          'order_qty': orderQty,
          'supply_qty': supplyQty,
          'bo_qty': boQty,
          'cancel_qty': cancelQty,
          'ETD': etd,
          'remark': remark,
        });

        setState(() {
          _uploadMessage = 'File uploaded successfully';
        });

        debugPrint('Uploaded data to Firestore...');
      } catch (e) {
        debugPrint('Error uploading row $i: $e');
        setState(() {
          _uploadMessage = 'Error uploading row $i: $e';
        });
      }
    }

    // Show duplicated data
    if (duplicatedData.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Duplicate Data'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer Code')),
                  DataColumn(label: Text('Order Number')),
                  DataColumn(label: Text('Part Number')),
                ],
                rows: List<DataRow>.generate(
                  duplicatedData.length,
                  (index) {
                    List<String> rowData = duplicatedData[index].split(', ');
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            rowData[0],
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        DataCell(
                          Text(
                            rowData[1],
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        DataCell(
                          Text(
                            rowData[2],
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  DateTime _parseDate(dynamic dateValue) {
    // Konversi format tanggal DD/MM/YYYY menjadi YYYY-MM-DD
    List<String> parts = dateValue.toString().split('/');
    String formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
    return DateTime.parse(formattedDate);
  }

  Future<void> _showDataDialog() async {
    final File file = File(_selectedFilePath);
    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data from CSV File'),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order Date')),
                  DataColumn(label: Text('Customer Code')),
                  DataColumn(label: Text('Order Number')),
                  DataColumn(label: Text('Part Number')),
                  DataColumn(label: Text('Order Quantity')),
                  DataColumn(label: Text('Supply Quantity')),
                  DataColumn(label: Text('BO Quantity')),
                  DataColumn(label: Text('Cancel Quantity')),
                  DataColumn(label: Text('ETD')),
                  DataColumn(label: Text('Remark')),
                ],
                rows: List<DataRow>.generate(
                  fields.length,
                  (int index) {
                    var rowData = fields[index];
                    // Mengecek apakah indeks kolom yang diambil valid
                    if (rowData.length == 10) {
                      return DataRow(
                        cells: [
                          DataCell(Text('${rowData[0]}')),
                          DataCell(Text('${rowData[1]}')),
                          DataCell(Text('${rowData[2]}')),
                          DataCell(Text('${rowData[3]}')),
                          DataCell(Text('${rowData[4]}')),
                          DataCell(Text('${rowData[5]}')),
                          DataCell(Text('${rowData[6]}')),
                          DataCell(Text('${rowData[7]}')),
                          DataCell(Text('${rowData[8]}')),
                          DataCell(Text('${rowData[9]}')),
                        ],
                      );
                    } else {
                      // Jika indeks kolom tidak valid, maka baris tidak ditampilkan
                      return const DataRow(cells: []);
                    }
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up subscriptions, timers, etc. here
    super.dispose();
  }

  void main() {
    runApp(const MaterialApp(
      home: UploadPage(),
    ));
  }
}
