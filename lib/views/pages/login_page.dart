import 'package:admin_app/views/components/my_button.dart';
import 'package:admin_app/views/components/my_textfield.dart';
import 'package:admin_app/views/pages/home_page.dart'; // Import your home page here
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUserIn() async {
    setState(() {
      isLoading = true;
    });

    User? user = await _authController.signIn(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username or Password incorrect, or check internet connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  const Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.purple,
                    size: 100,
                  ),
                  const Text(
                    'E-Gudang Puskemas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21.5,
                    ),
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    onTap: signUserIn,
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: const Color.fromARGB(255, 208, 0, 255).withOpacity(0.5),
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: LinearProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
