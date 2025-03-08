import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturerChatScreen extends StatefulWidget {
  final String senderId; // Student's UID
  final String receiverId; // Lecturer's UID

  const LecturerChatScreen({
    Key? key,
    required this.senderId,
    required this.receiverId,
  }) : super(key: key);

  @override
  _LecturerChatScreenState createState() => _LecturerChatScreenState();
}

class _LecturerChatScreenState extends State<LecturerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Student'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Display messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('Messages')
                      .where(
                        'senderId',
                        whereIn: [widget.senderId, widget.receiverId],
                      )
                      .where(
                        'receiverId',
                        whereIn: [widget.senderId, widget.receiverId],
                      )
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to send a message
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('Messages').add({
      'senderId': _auth.currentUser!.uid, // Lecturer's UID
      'receiverId': widget.senderId, // Student's UID
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now(),
    });

    _messageController.clear();
  }
}
