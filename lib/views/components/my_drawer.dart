import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  AppDrawer({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // decoration: BoxDecoration(
            //   color: Colors.blue,
            // ),
            child: Text(
              'Menu',
              style: TextStyle(
                // color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // ListTile(
          //   title: Text('Home'),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => HomePage()),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onLogout(); // Trigger the logout function
            },
          ),
        ],
      ),
    );
  }
}
