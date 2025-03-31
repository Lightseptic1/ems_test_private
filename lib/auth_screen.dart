import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './create_event.dart';
import 'screens/admin_dashboard.dart';
import 'screens/event_manager_dashboard.dart';
import 'screens/client_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';
  String? userRole;

Future<void> _signIn() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Get all role documents under "Users"
    QuerySnapshot rolesQuery = await FirebaseFirestore.instance
        .collection("users")
        .doc("User_Roles")
        .collection("Users")
        .get();

    String? userRole;

    for (var doc in rolesQuery.docs) {
      if (doc["email"] == _emailController.text) {
        userRole = doc.id;  // The document ID is the role (e.g., "Admin", "Client")
        break;
      }
      print("Checking role: ${doc.id}, Email: ${doc["email"]}");

    }

    if (userRole != null) {
      print("User Role: $userRole");  // Debugging print

      // Navigate to the correct dashboard based on role
      if (userRole == "Admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else if (userRole == "Event_Manager") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventManagerDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClientDashboard()),
        );
      }
    } else {
      setState(() {
        _errorMessage = "No role found for this user.";
      });
    }
  } catch (e) {
    print("Error fetching user role: $e");
    setState(() {
      _errorMessage = "Error: ${e.toString()}";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: const Text('Login')),

            if (userRole == "Admin" || userRole == "Event_Manager") 
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateEventScreen()),
                  );
                },
                child: const Text("Create Event"),
              ),

            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
