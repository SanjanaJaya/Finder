import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentChatScreen extends StatefulWidget {
  final String lecturerId;
  final String studentUid;
  final String lecturerFirstName;
  final String lecturerLastName;

  StudentChatScreen({
    required this.lecturerId,
    required this.studentUid,
    required this.lecturerFirstName,
    required this.lecturerLastName,
  });

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen>
    with SingleTickerProviderStateMixin {
  int _sentMessagesToday = 0;
  final List<String> _predefinedMessages = [
    "Is there a tutorial session for this topic?",
    "Hello Sir, are you in your cabin now?",
    "Sir, can I book an appointment?",
    "Hello sir!",
  ];

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _checkMessagesToday();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> _checkMessagesToday() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    QuerySnapshot sentMessages = await FirebaseFirestore.instance
        .collection('Messages')
        .where('senderId', isEqualTo: widget.studentUid)
        .where('receiverId', isEqualTo: widget.lecturerId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    setState(() {
      _sentMessagesToday = sentMessages.docs.length;
    });
  }

  Future<void> _sendMessage(String message) async {
    if (_sentMessagesToday >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message limit reached (4 messages per day).")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Messages').add({
      'senderId': widget.studentUid,
      'receiverId': widget.lecturerId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _sentMessagesToday++;
    });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.lecturerFirstName} ${widget.lecturerLastName}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Color(0xFFF5F0E6),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Messages')
                    .where('senderId', whereIn: [widget.studentUid, widget.lecturerId])
                    .where('receiverId', whereIn: [widget.studentUid, widget.lecturerId])
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
                      var message = messages[index].data() as Map<String, dynamic>;
                      bool isMe = message['senderId'] == widget.studentUid;

                      return SlideTransition(
                        position: _animation,
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Click anything What you need to send",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ..._predefinedMessages.map(
                        (msg) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.black),
                        ),
                        onPressed: () => _sendMessage(msg),
                        child: Text(msg),
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
