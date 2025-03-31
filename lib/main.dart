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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> _isDarkMode = ValueNotifier(true); // ✅ Default to dark mode

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Flutter Firebase Login',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // ✅ Toggle theme
          home: AuthScreen(toggleTheme: () => _isDarkMode.value = !_isDarkMode.value),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const AuthScreen({super.key, required this.toggleTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _errorMessage = '';
  String userRole = '';
  bool _showCreateEventButton = false;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      QuerySnapshot rolesQuery = await FirebaseFirestore.instance
          .collection("users")
          .doc("User_Roles")
          .collection("Users")
          .get();

      String? userRole;
      for (var doc in rolesQuery.docs) {
        if (doc["email"] == _emailController.text) {
          userRole = doc.id; 
          break;
        }
      }

      if (userRole != null) {
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
      appBar: AppBar(
        title: const Text('Login Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6), // ✅ Toggle button icon
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
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
              onSubmitted: (_) => _signIn(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: const Text('Login')),
            ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
            
            if (_errorMessage.isNotEmpty) 
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),

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
