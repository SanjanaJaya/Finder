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

class _LecturerChatScreenState extends State<LecturerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String senderName = "";

  @override
  void initState() {
    super.initState();
    _fetchSenderName();
  }

  void _fetchSenderName() async {
    DocumentSnapshot senderSnapshot =
        await _firestore.collection('Person').doc(widget.senderId).get();
    if (senderSnapshot.exists) {
      setState(() {
        senderName =
            "${senderSnapshot['First_Name']} ${senderSnapshot['Last_Name']}";
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
        title: Text(
          senderName.isNotEmpty ? senderName : "Chat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
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

          // Message input field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type Your Message Here',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('Messages').add({
      'senderId': _auth.currentUser!.uid,
      'receiverId': widget.senderId,
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now(),
    });

    _messageController.clear();
  }
}
