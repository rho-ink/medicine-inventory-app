import 'package:admin_app/views/pages/home_page.dart';
import 'package:admin_app/views/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is loged
          if (snapshot.hasData) {
            return HomePage();
          }

          // user is not logged
          else {
            return LoginPage();
          }

        },
      ),
    );
  }
}
