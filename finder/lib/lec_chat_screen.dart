import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LecturerChatScreen extends StatefulWidget {
  final String studentEmail; // Changed from lecturerEmail to studentEmail
  final String studentId;

  const LecturerChatScreen(
      {Key? key, required this.studentEmail, required this.studentId})
      : super(key: key);

  @override
  _LecturerChatScreenState createState() => _LecturerChatScreenState();
}

class _LecturerChatScreenState extends State<LecturerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _studentName; // Changed from _lecturerName to _studentName
  String? _lecturerId; // Changed from _studentId to _lecturerId

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _lecturerId = user.uid; // Changed from _studentId to _lecturerId

      var query = await _firestore
          .collection('Person') // Changed from 'Lecturer' to 'Person'
          .where('Email', isEqualTo: widget.studentEmail) // Changed from widget.lecturerEmail to widget.studentEmail
          .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          _studentName = // Changed from _lecturerName to _studentName
          "${query.docs.first['First_Name']} ${query.docs.first['Last_Name']}";
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty || _lecturerId == null) {
      return;
    }

    try {
      await _firestore.collection('messages').add({
        'senderId': _lecturerId, // Changed from _studentId to _lecturerId
        'receiverId': widget.studentId, // Changed from widget.lecturerId to widget.studentId
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_studentName != null ? "Chat with $_studentName" : "Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('messages')
                  .where('receiverId',
                  isEqualTo: widget.studentId) // Changed from widget.lecturerId to widget.studentId
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                messages.sort((a, b) {
                  Timestamp timestampA = a.data()?['timestamp'] ??
                      Timestamp.fromMillisecondsSinceEpoch(0);
                  Timestamp timestampB = b.data()?['timestamp'] ??
                      Timestamp.fromMillisecondsSinceEpoch(0);
                  return timestampB.compareTo(timestampA);
                });

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index].data();

                    if (message == null) {
                      return const ListTile(
                          title: Text("Error: Message data is missing."));
                    }

                    bool isMe = message['senderId'] ==
                        _lecturerId; // Changed from _studentId to _lecturerId

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
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