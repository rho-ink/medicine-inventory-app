import 'package:admin_app/views/components/auth_page.dart';
import 'package:admin_app/controllers/user_provider.dart'; // Import the UserProvider
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(), // Provide UserProvider
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(), // Apply Poppins font to entire text theme
          // Other theme customizations if needed
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthPage(),
      ),
    );
  }
}
