import 'package:admin_app/views/pages/edits/add_catat.dart';
import 'package:admin_app/views/pages/edits/add_gudang.dart';
import 'package:admin_app/views/pages/screens/main_screen.dart';
import 'package:admin_app/views/pages/login_page.dart';
import 'package:admin_app/views/pages/screens/second_screen.dart';
import 'package:admin_app/views/pages/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/views/components/my_drawer.dart';
import 'package:admin_app/views/components/my_excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_app/controllers/user_provider.dart'; // Import UserProvider

// Import UserProvider

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController(initialPage: 0);
  int index = 0;
  String userRole = '';
  String userEmail = '';

  final widgetList = [
    DashboardPage(),
    MainScreen(),
    SecondScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      final roleSnapshot = await ref.child('users/${user.uid}/role').get();
      final email = user.email ?? 'Unknown Email';
      final role = roleSnapshot.exists ? roleSnapshot.value as String : 'Unknown Role';

      setState(() {
        userRole = role;
        userEmail = email;
      });
      UserProvider().setRole(userRole); // Set the user role in the provider
    }
  }

  Future<void> signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    UserProvider().clearRole(); // Clear the role in the provider on sign out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      index = pageIndex;
    });
  }

  void onBottomNavTapped(int tappedIndex) {
    _pageController.animateToPage(
      tappedIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
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
        actions: _buildAppBarActions(),
      ),
      drawer: AppDrawer(
        onLogout: () => signUserOut(context),
        userEmail: userEmail,
        userRole: userRole,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: onBottomNavTapped,
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
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: widgetList,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (index == 0 && userRole == 'admin') {
      return [
        IconButton(
          icon: Icon(Icons.notifications_rounded),
          onPressed: () {},
        ),
      ];
    } else if (index == 2 && userRole == 'admin') {
      return [
        IconButton(
          icon: Icon(Icons.print_rounded),
          onPressed: () async {
            await exportToExcel();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exported to Excel!')),
            );
          },
        ),
      ];
    }
    return []; // Empty list for no actions
  }

  Widget _buildFAB() {
    // Show both FABs for admin
    if (userRole == 'admin') {
      if (index == 1) {
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
    }

    // Show "Add Gudang" FAB for apoteker
    if (userRole == 'apoteker' && index == 2) {
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

    // Show "Add Transaksi" FAB for assistant
    if (userRole == 'assistant' && index == 1) {
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
    }

    // Return an empty container if no FAB is needed
    return Container();
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Daftar Keluaran Obat';
      case 2:
        return 'Daftar Obat dan BMHP';
      default:
        return 'Default Title';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
