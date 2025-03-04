import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentChatScreen extends StatefulWidget {
  final String lecturerId;
  final String lecturerName;

  StudentChatScreen({required this.lecturerId, required this.lecturerName});

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user role (student or lecturer)
  Future<String> getUserRole(String uid) async {
    print("getUserRole called with UID: $uid"); // Debugging

    try {
      var personQuery = await _firestore.collection('Person').where('uid', isEqualTo: uid).get();
      if (personQuery.docs.isNotEmpty) {
        print("User found in Person collection."); // Debugging
        return 'student';
      }

      var lecturerQuery = await _firestore.collection('Lecturer').where('uid', isEqualTo: uid).get();
      if (lecturerQuery.docs.isNotEmpty) {
        print("User found in Lecturer collection."); // Debugging
        return 'lecturer';
      }

      print("User role not found for UID: $uid");
      return '';
    } catch (e) {
      print("Error getting user role: $e");
      return '';
    }
  }

  // Send message to Firestore
  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      print("User is not authenticated."); // Debugging
      return;
    }

    String senderId = user.uid;
    String receiverId = widget.lecturerId;

    String senderRole = await getUserRole(senderId);

    print("Sending message - Sender ID: $senderId, Receiver ID: $receiverId, Sender Role: $senderRole"); // Debugging

    try {
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'senderRole': senderRole,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      print("Message sent successfully."); // Debugging
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building StudentChatScreen - Current User UID: ${_auth.currentUser?.uid}, Lecturer ID: ${widget.lecturerId}"); // Debugging

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.lecturerName}"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', whereIn: [_auth.currentUser?.uid, widget.lecturerId])
                  .where('receiverId', whereIn: [widget.lecturerId, _auth.currentUser?.uid])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("StreamBuilder Error: ${snapshot.error}"); // Debugging
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  print("StreamBuilder - No data."); // Debugging
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  print("StreamBuilder - No messages found."); // Debugging
                  return Center(child: Text("No messages yet."));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data();
                    bool isMe = message['senderId'] == _auth.currentUser?.uid;
                    String senderRole = message['senderRole'];

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                            Text(
                              senderRole,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}