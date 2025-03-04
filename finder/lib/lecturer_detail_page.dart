import 'package:flutter/material.dart';
import 'student_chat_screen.dart'; // Import the StudentChatScreen

class LecturerDetailPage extends StatelessWidget {
  final Map<String, dynamic> lecturer;

  LecturerDetailPage({required this.lecturer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE7DA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEE7DA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Lecturer Details",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'), // Change as needed
            ),
            const SizedBox(height: 10),
            Text(
              "${lecturer['L_First_Name']} ${lecturer['L_Last_Name']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              lecturer['Job_Role'],
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(lecturer['Email']),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(lecturer['Contact No']),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: Text(lecturer['Faculty_Name']),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Available"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to StudentChatScreen with Lecturer's Email
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentChatScreen(
                      lecturerEmail: lecturer['Email'], // Pass lecturer's email
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text("Chat with Lecturer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
