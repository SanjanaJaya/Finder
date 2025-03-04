import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lecturer_home.dart'; // Import LecturerHomePage to navigate after successful login

class LecturerLoginPage extends StatefulWidget {
  @override
  _LecturerLoginPageState createState() => _LecturerLoginPageState();
}

class _LecturerLoginPageState extends State<LecturerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // First, authenticate the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // If login is successful, query Firestore to check if the lecturer exists in the "Lecturer" collection
        QuerySnapshot query = await _firestore
            .collection('Lecturer')
            .where('Email', isEqualTo: email)
            .where('Password', isEqualTo: password) // Ensure plaintext passwords aren't stored in production
            .get();

        if (query.docs.isNotEmpty) {
          // Navigate to the LecturerHomePage on successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LecturerHomePage(),
            ),
          );
        } else {
          _showError("No account found with this email.");
        }
      } else {
        _showError("Invalid email or password.");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
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
              Image.asset(
                'assets/NSBM_logo.png',
                height: 120,
              ),
              SizedBox(height: 30),
              _buildTextField("Lecturer’s E-mail", false),
              SizedBox(height: 15),
              _buildTextField("Password", true),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign Up Page (To be implemented)
                },
                child: Text(
                  "Don't Have an Account? Create Account",
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA7B89C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                child: Text(
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

  Widget _buildTextField(String label, bool isPassword) {
    return TextField(
      controller: isPassword ? _passwordController : _emailController,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
