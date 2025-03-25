import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../create_event.dart';
import '../auth_screen.dart'; // Import your SignIn screen

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()), // Ensure SignInScreen exists
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome, Admin!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                );
              },
              child: const Text("Create Event"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context), // Sign out button
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
