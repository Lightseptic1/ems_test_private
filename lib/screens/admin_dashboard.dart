import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../create_event.dart';
import '../auth_screen.dart';
import '../../functionality/view_event_screen.dart'; // Corrected import path
import '../../main.dart'; // Navigate back to Main after sign-out

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()), // Navigate back to main.dart
      (route) => false, // Remove all previous routes
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
                );
              },
              child: const Text("View Events"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
