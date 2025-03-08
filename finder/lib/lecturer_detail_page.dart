import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_chat_screen.dart';

class LecturerDetailPage extends StatefulWidget {
  final Map<String, dynamic> lecturer;
  final String studentUid;

  LecturerDetailPage({required this.lecturer, required this.studentUid});

  @override
  _LecturerDetailPageState createState() => _LecturerDetailPageState();
}

class _LecturerDetailPageState extends State<LecturerDetailPage> {
  String availabilityStatus = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchLecturerAvailability();
  }

  Future<void> _fetchLecturerAvailability() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturer['uid'])
          .get();

      if (lecturerDoc.exists && lecturerDoc['status'] != null) {
        setState(() {
          availabilityStatus = lecturerDoc['status'] == 'Inside Cabin'
              ? 'Available in Cabin'
              : 'Outside Cabin';
        });
      } else {
        setState(() {
          availabilityStatus = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching lecturer availability: $e");
      setState(() {
        availabilityStatus = 'Error fetching status';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE7DA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEE7DA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 10),
            Text(
              "${widget.lecturer['L_First_Name']} ${widget.lecturer['L_Last_Name']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.lecturer['Job_Role'] ?? "Unknown role",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(widget.lecturer['Email'] ?? "No email available"),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(widget.lecturer['Contact No'] ?? "No contact available"),
            ),
            ListTile(
              leading: const Icon(Icons.business, color: Colors.orange),
              title: Text(widget.lecturer['Faculty_Name'] ?? "No faculty info"),
            ),
            const SizedBox(height: 20),
            // Availability Status Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: availabilityStatus.contains('Available')
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: availabilityStatus.contains('Available')
                      ? Colors.green
                      : Colors.red,
                  width: 2,
                ),
              ),
              child: Text(
                'Availability: $availabilityStatus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: availabilityStatus.contains('Available')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.lecturer.containsKey('uid')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentChatScreen(
                        lecturerId: widget.lecturer['uid'],
                        studentUid: widget.studentUid,
                        lecturerFirstName: widget.lecturer['L_First_Name'] ?? '',
                        lecturerLastName: widget.lecturer['L_Last_Name'] ?? '',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}