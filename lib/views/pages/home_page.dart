import 'package:admin_app/views/pages/edits/add_catat.dart';
import 'package:admin_app/views/pages/edits/add_gudang.dart';
import 'package:admin_app/views/pages/screens/main_screen.dart';
import 'package:admin_app/views/pages/login_page.dart';
import 'package:admin_app/views/pages/screens/second_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var widgetList = [
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

      // return Scaffold(
      //   body: Center(
      //     child: LinearProgressIndicator(),
      //   ),
      // );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          index == 0 ? 'Daftar Keluaran Obat' : 'Daftar Obat dan BMHP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (index == 0)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => signUserOut(context),
            ),
          if (index == 1)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
              },
            ),
        ],
      ),
      //navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pencil_circle),
            label: 'Catat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square),
            label: 'Data Gudang',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      // Switch layar
      body: widgetList[index],
    );
  }

  Widget _buildFAB() {
    if (index == 0) {
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
    } else if (index == 1) {
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
}
