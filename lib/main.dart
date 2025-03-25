import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import './create_event.dart';
import './screens/dashboard.dart';

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
    return MaterialApp(
      title: 'Flutter Firebase Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthScreen(), // Navigate to login page
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _errorMessage = '';
  String userRole = '';  // ✅ Declare userRole
  bool _showCreateEventButton = false;  // ✅ Declare _showCreateEventButton

Future<void> _signIn() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection("users")
        .doc("User_Roles")
        .collection("Users")
        .where("email", isEqualTo: _emailController.text)
        .get();

    if (userQuery.docs.isNotEmpty) {
      var userDoc = userQuery.docs.first;
      String userRole = userDoc["role"];

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
    setState(() {
      _errorMessage = "Error: ${e.toString()}";
    });
  }
}


  Future<void> _signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _errorMessage = 'Account Created!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
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
            ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
            
            if (_errorMessage.isNotEmpty) 
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

            // ✅ Show "Create Event" button only if the user is Admin
            if (_showCreateEventButton) 
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                    );
                },
                child: const Text('Create Event'),
              ),
          ],
        ),
      ),
    );
  }
}
