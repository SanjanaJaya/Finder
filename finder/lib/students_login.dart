import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // Import your HomePage to navigate after successful login

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true; // To toggle password visibility
  bool _isLoading = false; // To track login loading state

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // First, authenticate the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // If login is successful, query Firestore to check if the user exists in the "Person" collection
        QuerySnapshot query = await _firestore
            .collection('Person')
            .where('Email', isEqualTo: email)
            .where(
          'Password',
          isEqualTo: password,
        ) // Ensure plaintext passwords aren't stored in production
            .get();

        if (query.docs.isNotEmpty) {
          // Navigate to the HomePage on successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ), // Make sure HomePage is in your main.dart
          );
        } else {
          _showError("No account found with this email.");
        }
      } else {
        _showError("Invalid email or password.");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEDA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/NSBM_logo.png', height: 120),
              SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Student’s E-mail",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Use _obscurePassword to toggle visibility
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Toggle password visibility
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA7B89C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}