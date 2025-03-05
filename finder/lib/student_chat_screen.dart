import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentChatScreen extends StatefulWidget {
  final String lecturerEmail;
  final String lecturerId;

  StudentChatScreen({required this.lecturerEmail, required this.lecturerId});

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _lecturerName;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _studentId = user.uid;

      // No need to fetch lecturerId here as it's passed from LecturerDetailPage
      var query =
          await _firestore
              .collection('Lecturer')
              .where('Email', isEqualTo: widget.lecturerEmail)
              .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          _lecturerName =
              "${query.docs.first['L_First_Name']} ${query.docs.first['L_Last_Name']}";
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty || _studentId == null) return;

    try {
      await _firestore.collection('messages').add({
        'senderId': _studentId,
        'receiverId': widget.lecturerId, // Use the passed lecturerId
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
        title: Text(
          _lecturerName != null ? "Chat with $_lecturerName" : "Chat",
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  _firestore
                      .collection('messages')
                      .where(
                        'receiverId',
                        isEqualTo: widget.lecturerId,
                      ) // Filter messages by lecturerId
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                // Sort messages by timestamp in descending order
                messages.sort((a, b) {
                  Timestamp timestampA =
                      a.data()?['timestamp'] ??
                      Timestamp.fromMillisecondsSinceEpoch(0);
                  Timestamp timestampB =
                      b.data()?['timestamp'] ??
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
                        title: Text("Error: Message data is missing."),
                      );
                    }

                    bool isMe = message['senderId'] == _studentId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
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
