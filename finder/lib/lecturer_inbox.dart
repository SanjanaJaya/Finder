import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lec_chat_screen.dart'; // Import ChatScreen

class LecturerInbox extends StatefulWidget {
  const LecturerInbox({super.key});

  @override
  _LecturerInboxState createState() => _LecturerInboxState();
}

class _LecturerInboxState extends State<LecturerInbox> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String lecturerEmail = "lecturer@example.com"; // Replace with the lecturer's email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0E9DD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inbox",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Messages') // Assuming you have a "Messages" collection
              .where('lecturerEmail', isEqualTo: lecturerEmail) // Filter by the lecturer's email
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No messages available."));
            }

            final messages = snapshot.data!.docs;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final messageData = messages[index].data() as Map<String, dynamic>;
                final studentName = messageData['studentName'] ?? 'Unknown';
                final message = messageData['message'] ?? '';

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        studentName[0], // First letter of student's name
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                      size: 18,
                    ),
                    onTap: () {
                      // Navigate to ChatScreen with the student's name and message
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            studentName: studentName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
