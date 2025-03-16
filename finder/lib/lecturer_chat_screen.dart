import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturerChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const LecturerChatScreen({
    Key? key,
    required this.senderId,
    required this.receiverId,
  }) : super(key: key);

  @override
  _LecturerChatScreenState createState() => _LecturerChatScreenState();
}

class _LecturerChatScreenState extends State<LecturerChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String senderName = "";
  String senderImageUrl = ""; // To store the student's profile photo URL

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchSenderDetails(); // Fetch both name and image URL

    // Initialize animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _fetchSenderDetails() async {
    DocumentSnapshot senderSnapshot =
    await _firestore.collection('Person').doc(widget.senderId).get();
    if (senderSnapshot.exists) {
      setState(() {
        senderName =
        "${senderSnapshot['First_Name']} ${senderSnapshot['Last_Name']}";
        senderImageUrl = senderSnapshot['Image']; // Fetch the image URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EBDD),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3EBDD),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (senderImageUrl.isNotEmpty) // Display profile photo if available
              CircleAvatar(
                backgroundImage: NetworkImage(senderImageUrl),
                radius: 16,
              ),
            SizedBox(width: 8), // Add spacing between image and name
            Text(
              senderName.isNotEmpty ? senderName : "Chat",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
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

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;

                    return SlideTransition(
                      position: _slideAnimation,
                      child: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white : Colors.black, // Sent: white, Received: black
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isMe ? Colors.black : Colors.white, // Sent: black text, Received: white text
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background for the input box
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type Your Message Here',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none, // Remove default border
                        ),
                        style: TextStyle(color: Colors.black), // Black text for typing
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
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('Messages').add({
      'senderId': _auth.currentUser!.uid,
      'receiverId': widget.senderId,
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now(),
      'isRead': false, // Add this line to set isRead to false
    });

    _messageController.clear();

    // Trigger animation for the new message
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}