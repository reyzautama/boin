// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  final String loggedInUser;

  const ManageUsersPage({Key? key, required this.loggedInUser})
      : super(key: key);

  @override
  ManageUsersPageState createState() => ManageUsersPageState();
}

class ManageUsersPageState extends State<ManageUsersPage> {
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late List<DocumentSnapshot> usersData = [];

  final List<String> userRoles = ['user', 'admin', 'head'];
  final List<String> approvalStatuses = ['approved', 'reject', 'Wait Approval'];

  late String selectedRole;
  late String selectedApproval;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRole = userRoles[0];
    selectedApproval = approvalStatuses[2]; // Default to 'Wait Approval'
    loadData();
  }

  Future<void> loadData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('tb_users').get();
    setState(() {
      usersData = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome, ${widget.loggedInUser}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.purple),
                headingTextStyle: const TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Password')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Approval')),
                  DataColumn(label: Text('Actions')),
                ],
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                rows: List<DataRow>.generate(
                  usersData.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text(usersData[index]['username'])),
                      DataCell(Text(usersData[index]['password'])),
                      DataCell(Text(usersData[index]['role'])),
                      DataCell(Text(usersData[index]['approval'])),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteUser(usersData[index].id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateUserDialog(
                                    usersData[index].id,
                                    usersData[index]['username'],
                                    usersData[index]['role'],
                                    usersData[index]['approval']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Tambah User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUser() async {
    await _showAddUserDialog();
  }

  Future<void> _showAddUserDialog() async {
    showDialog(
      context: scaffoldMessengerKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    DropdownButton<String>(
                      value: selectedRole,
                      onChanged: (newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                      items: userRoles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (usernameController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kolom harus diisi.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (isUsernameExists(usernameController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username sudah digunakan.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('tb_users')
                          .add({
                        'username': usernameController.text,
                        'password': passwordController.text,
                        'role': selectedRole,
                        'approval': selectedApproval,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User ditambahkan dengan sukses.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      loadData();
                      Navigator.of(context).pop();
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menambahkan user: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool isUsernameExists(String username) {
    for (var user in usersData) {
      final userData = user.data() as Map<String, dynamic>;
      final existingUsername = userData['username'];
      if (existingUsername == username) {
        return true;
      }
    }
    return false;
  }

  Future<void> _deleteUser(String userId) async {
    showDialog(
      context: scaffoldMessengerKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content:
              const Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('tb_users')
                      .doc(userId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  loadData();
                  Navigator.of(context).pop();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete user: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateUserDialog(
      String userId, String username, String role, String approval) async {
    TextEditingController usernameController =
        TextEditingController(text: username);
    TextEditingController roleController = TextEditingController(text: role);
    TextEditingController approvalController =
        TextEditingController(text: approval);

    showDialog(
      context: scaffoldMessengerKey.currentContext!,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                  DropdownButton<String>(
                    value: role,
                    onChanged: (newValue) {
                      setState(() {
                        roleController.text = newValue!;
                      });
                    },
                    items: userRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: approval,
                    onChanged: (newValue) {
                      setState(() {
                        approvalController.text = newValue!;
                      });
                    },
                    items: approvalStatuses.map((approval) {
                      return DropdownMenuItem<String>(
                        value: approval,
                        child: Text(approval),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('tb_users')
                          .doc(userId)
                          .update({
                        'username': usernameController.text,
                        'role': roleController.text,
                        'approval': approvalController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User $username updated successfully.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      loadData();
                      Navigator.of(context).pop();
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update user: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ManageUsersPage(loggedInUser: 'Admin'),
  ));
}
