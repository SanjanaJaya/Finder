import 'package:flutter/material.dart';

class StudentLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEDA), // Light beige background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // University Logo
              Image.asset(
                'assets/NSBM_logo.png', // Ensure this image is in the assets folder
                height: 120,
              ),
              SizedBox(height: 30),

              // Student's Email Field
              _buildTextField("Student’s E-mail", false),

              SizedBox(height: 15),

              // Password Field
              _buildTextField("Password", true),

              SizedBox(height: 10),

              // Sign Up Link
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

              // Login Button
              ElevatedButton(
                onPressed: () {
                  // Handle Login (To be implemented)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA7B89C), // Greenish button color
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

  // Function to build text fields
  Widget _buildTextField(String label, bool isPassword) {
    return TextField(
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
