import 'package:flutter/material.dart';
import 'students_login.dart'; // Import the student login page
import 'lecturer_login.dart'; // Import the lecturer login page

class OpeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EEDA), // Light beige background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // University Logo
              Image.asset(
                'assets/NSBM_logo.png', // Ensure this image is inside assets/
                height: 120,
              ),
              SizedBox(height: 30),

              // Welcome Text
              Text(
                "WELCOME",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // User Selection Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUserSelection(context, "assets/student.png", "Student", StudentLoginPage()),
                  SizedBox(width: 20),
                  _buildUserSelection(context, "assets/lecturer.png", "Lecturer", LecturerLoginPage()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create user selection buttons
  Widget _buildUserSelection(BuildContext context, String imagePath, String label, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Center(child: Image.asset(imagePath, width: 70, height: 70)),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}