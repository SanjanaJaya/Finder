import 'package:flutter/material.dart';
import 'lec_chat_screen.dart'; // Import ChatScreen

class LecturerInbox extends StatelessWidget {
  const LecturerInbox({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of messages
    final List<Map<String, String>> messages = [
      {"name": "Sanjana Jayasooriya", "message": "Hello, Professor!"},
      {
        "name": "Diuwara Wijerathne",
        "message": "Can we discuss the assignment?",
      },
      {
        "name": "Gaveen Ranasinghe",
        "message": "I have a question about the lecture.",
      },
      {"name": "Shehara", "message": "When is your next available slot?"},
    ];

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
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
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
                    messages[index]['name']![0], // First letter of name
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  messages[index]['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  messages[index]['message']!,
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
                  // Navigate to ChatScreen with the student's name
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ChatScreen(studentName: messages[index]['name']!),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
