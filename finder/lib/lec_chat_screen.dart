import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String studentName; // Pass student name from inbox

  const ChatScreen({super.key, required this.studentName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String lecturerEmail; // Assuming we will get this from authentication context

  @override
  void initState() {
    super.initState();
    // Assuming lecturer's email is fetched from FirebaseAuth or passed into the screen
    lecturerEmail = "lecturer@example.com"; // Replace with actual lecturer email
  }

  // Send message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text.trim();
      String studentName = widget.studentName;

      // Add the message to Firestore under a "Chats" collection
      await _firestore.collection('Chats').add({
        'studentName': studentName,
        'lecturerEmail': lecturerEmail,
        'message': messageText,
        'isSentByLecturer': true, // Message sent by lecturer
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear message field after sending
      _messageController.clear();
    }
  }

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
        title: Text(
          widget.studentName, // Display student's name
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Chats')
                  .where('studentName', isEqualTo: widget.studentName)
                  .where('lecturerEmail', isEqualTo: lecturerEmail)
                  .orderBy('timestamp') // Order messages by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isSentByLecturer = messageData['isSentByLecturer'];
                    String messageText = messageData['message'];

                    return Align(
                      alignment: isSentByLecturer
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSentByLecturer ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(
                            color: isSentByLecturer ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
