import 'package:boin/back_order.dart';
import 'package:boin/head_overview.dart';
import 'package:boin/history_page.dart';
import 'package:boin/login.dart';
import 'package:boin/notifications_page.dart';
import 'package:boin/trend_analysis.dart';
import 'package:boin/report.dart'; // Import the ReportPage
import 'package:flutter/material.dart';
import 'bo_report.dart'; // Import halaman BOReportPage

class HeadDashboard extends StatefulWidget {
  final String loggedInUser;

  const HeadDashboard({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  HeadDashboardState createState() => HeadDashboardState();
}

class HeadDashboardState extends State<HeadDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // Daftar halaman yang akan ditampilkan pada bottom navigation
    _HomeMenu(), // Menu Home
    const BOReportPage(), // Halaman BOReportPage
    const ReportPage(), // Replace with your ReportPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Head Dashboard - ${widget.loggedInUser}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Colors.pinkAccent, // Pink background color for BottomNavigationBar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'BO Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Report', // Updated label for the ReportPage
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // White color for the selected item
        onTap: (index) {
          if (index == 1) {
            // Jika index BO Monitoring yang dipilih
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('BO Monitoring'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Logic for showing Current Back-Order
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BackOrderPage()),
                          );
                        },
                        child: const Text('Current Back-Order'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Logic for showing History Back-Order
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const HistoryBackOrderPage()),
                          );
                        },
                        child: const Text('History Back-Order'),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            _onItemTapped(index);
          }
        },
      ),
    );
  }
}

class _HomeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Home Menu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuCard(context, 'Overview', Icons.dashboard, () {
              // Logic for showing overview
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OverviewPage()),
              );
            }),
            _buildMenuCard(context, 'Trend Analysis', Icons.trending_up, () {
              // Logic for showing trend analysis
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TrendAnalysisPage()),
              );
              debugPrint('Showing Trend Analysis');
            }),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuCard(context, 'Detail B/O', Icons.list_alt, () {
              // Logic for showing detail Back Order
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackOrderPage()),
              );
              debugPrint('Showing Detail B/O');
            }),
            _buildMenuCard(context, 'Warning B/O', Icons.warning, () {
              // Logic for showing warning Back Order
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage(
                          overdueCount: 3,
                        )),
              );
              debugPrint('Showing Warning B/O');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.4, // Set width to 40% of screen width
      child: Card(
        elevation: 3,
        color: Colors.pinkAccent, // Pink color for the Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.white, // White color for the icon
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white), // White color for the text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
