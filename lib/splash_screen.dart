import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resolvehub/signin_screen.dart';
import 'package:resolvehub/dashboard_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/signIn');
      }
    });
    return Scaffold(
      backgroundColor: Colors.purple[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title: "ResolveHub"
            Text(
              'ResolveHub',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold, // Bold for prominence
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10), // Add some space between title and slogan
            // Slogan: "Uniting for Solutions"
            Text(
              'Uniting for Solutions',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic, // Italic for emphasis
                color: Colors.white
                    .withOpacity(0.7), // Slight transparency for the slogan
              ),
            ),
          ],
        ),
      ),
    );
  }
}
