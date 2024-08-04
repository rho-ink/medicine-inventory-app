import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final Function()? onTap; //newfunc

  const MyButton({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    //wrapgesture
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "Sign in",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
