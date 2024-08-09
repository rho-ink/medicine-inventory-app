import 'package:admin_app/views/pages/edits/add_catat.dart';
import 'package:admin_app/views/pages/edits/add_gudang.dart';
import 'package:admin_app/views/pages/screens/main_screen.dart';
import 'package:admin_app/views/pages/login_page.dart';
import 'package:admin_app/views/pages/screens/second_screen.dart';
import 'package:admin_app/views/pages/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/views/components/my_drawer.dart'; // Import the Drawer file
import 'package:admin_app/views/components/my_excel.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var widgetList = [
    DashboardPage(),
    MainScreen(),
    SecondScreen(),
  ];

  int index = 0;

  // sign user out
  Future<void> signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is null and handle it
    if (user == null) {
      // Redirect to login page if user is not signed in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });

      return Scaffold(
        body: Center(
          child: LinearProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(index),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (index == 0)
            IconButton(
              icon: Icon(Icons.notifications_rounded),
              onPressed: () {},
            ),
          if (index == 2)
            IconButton(
              icon: Icon(Icons.print_rounded),
              onPressed: () async {await exportToExcel(); // Call your export function here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to Excel!')),
              );},
            ),
        ],
      ),
      drawer: AppDrawer(onLogout: () => signUserOut(context)), // Use the Drawer
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pencil_ellipsis_rectangle),
            label: 'Data Distribusi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_outlined),
            label: 'Data Gudang',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      body: widgetList[index],
    );
  }

  Widget _buildFAB() {
    if (index == 1) {
      // FAB MainScreen
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const AddTransaksi(),
            ),
          );
        },
        child: Icon(CupertinoIcons.add),
        backgroundColor: Colors.white,
      );
    } else if (index == 2) {
      // FAB SecondScreen
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const AddGudang(),
            ),
          );
        },
        child: Icon(CupertinoIcons.add),
        backgroundColor: Colors.white,
      );
    }
    return Container(); // Return an empty container if no FAB is needed
  }
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard Gudang';
      case 1:
        return 'Daftar Keluaran Obat';
      case 2:
        return 'Daftar Obat dan BMHP'; // Title for the new screen
      default:
        return 'Default Title';
    }
  }
}
