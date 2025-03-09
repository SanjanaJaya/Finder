import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lecturer_home.dart';

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

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Fetch lecturer data from Firestore using the email
        QuerySnapshot lecturerQuery = await _firestore
            .collection('Lecturer')
            .where('Email', isEqualTo: email)
            .get();

        if (lecturerQuery.docs.isNotEmpty) {
          // Fetch the lecturer's UID from the 'uid' field
          String lecturerUid = lecturerQuery.docs.first['uid']; // Use the 'uid' field
          print("Lecturer UID: $lecturerUid"); // Debugging: Print the lecturer UID

          // Update the lecturer's login status to true
          await _firestore
              .collection('Lecturer')
              .doc(lecturerUid)
              .update({'isLoggedIn': true});

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LecturerHomePage(lecturerUid: lecturerUid),
            ),
          );
        } else {
          _showError("Lecturer not found in the database.");
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
      backgroundColor: const Color(0xFFF5EEDA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/NSBM_logo.png', height: 120),
              const SizedBox(height: 30),
              _buildTextField("Lecturer’s E-mail", false),
              const SizedBox(height: 15),
              _buildTextField("Password", true),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign Up Page (To be implemented)
                },
                child: const Text(
                  "",
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA7B89C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                child: const Text(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }
}