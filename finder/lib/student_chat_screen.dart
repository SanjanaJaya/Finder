import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentChatScreen extends StatefulWidget {
  final String lecturerEmail;
  final String lecturerId;
  final String studentUid;

  StudentChatScreen({
    required this.lecturerEmail,
    required this.lecturerId,
    required this.studentUid,
  });

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  int _sentMessages = 0; // Track sent messages

  @override
  void initState() {
    super.initState();
    _checkSentMessages(); // Check message count on load
  }

  // Check how many messages the student has sent
  Future<void> _checkSentMessages() async {
    QuerySnapshot sentMessages =
        await FirebaseFirestore.instance
            .collection('Messages')
            .where('senderId', isEqualTo: widget.studentUid)
            .where('receiverId', isEqualTo: widget.lecturerId)
            .get();

    setState(() {
      _sentMessages = sentMessages.docs.length;
    });
  }

  // Send message function
  Future<void> _sendMessage() async {
    if (_sentMessages >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message limit reached (4 messages).")),
      );
      return;
    }

    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance.collection('Messages').add({
      'senderId': widget.studentUid,
      'receiverId': widget.lecturerId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _sentMessages++;
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.lecturerEmail}")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Messages')
                      .where(
                        'senderId',
                        whereIn: [widget.studentUid, widget.lecturerId],
                      )
                      .where(
                        'receiverId',
                        whereIn: [widget.studentUid, widget.lecturerId],
                      )
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;

                    // Safely handle null timestamp
                    var timestamp =
                        message['timestamp'] != null
                            ? (message['timestamp'] as Timestamp).toDate()
                            : DateTime.now();

                    // Check if the message is from the student or lecturer
                    bool isMe = message['senderId'] == widget.studentUid;

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                    ),
                    enabled: _sentMessages < 4, // Disable if limit reached
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
