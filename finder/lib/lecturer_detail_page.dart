import 'package:flutter/material.dart';
import 'student_chat_screen.dart';

class LecturerDetailPage extends StatelessWidget {
  final Map<String, dynamic> lecturer;
  final String studentUid;

  LecturerDetailPage({required this.lecturer, required this.studentUid});

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
              backgroundImage: AssetImage(
                'assets/profile_placeholder.png',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${lecturer['L_First_Name']} ${lecturer['L_Last_Name']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              lecturer['Job_Role'] ?? "Unknown role",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(lecturer['Email'] ?? "No email available"),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(lecturer['Contact No'] ?? "No contact available"),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: Text(lecturer['Faculty_Name'] ?? "No faculty info"),
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
                if (lecturer.containsKey('uid')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentChatScreen(
                        lecturerId: lecturer['uid'],
                        studentUid: studentUid,
                        lecturerFirstName: lecturer['L_First_Name'] ?? '',
                        lecturerLastName: lecturer['L_Last_Name'] ?? '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lecturer details are missing!")),
                  );
                }
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
