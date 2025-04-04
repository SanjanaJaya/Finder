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

class _StudentChatScreenState extends State<StudentChatScreen> {
  int _sentMessagesToday = 0;
  final List<String> _predefinedMessages = [
    "Is there a tutorial session for this topic?",
    "Hello Lecturer, are you in your cabin now?",
    "Lecturer, can I book an appointment?",
    "Hello Lecturer!",
  ];

  String lecturerImageUrl = "";

  @override
  void initState() {
    super.initState();
    _checkMessagesToday();
    _fetchLecturerImage();
    _markLecturerMessagesAsRead(); // Mark lecturer's messages as read when the chat is opened
  }

  Future<void> _fetchLecturerImage() async {
    DocumentSnapshot lecturerSnapshot = await FirebaseFirestore.instance
        .collection('Lecturer')
        .doc(widget.lecturerId)
        .get();
    if (lecturerSnapshot.exists) {
      setState(() {
        lecturerImageUrl = lecturerSnapshot['Image'];
      });
    }
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
      'isRead': false, // Default to unread
    });

    setState(() {
      _sentMessagesToday++;
    });
  }

  Future<void> _markLecturerMessagesAsRead() async {
    // Mark all messages from the lecturer as read
    QuerySnapshot messages = await FirebaseFirestore.instance
        .collection('Messages')
        .where('senderId', isEqualTo: widget.lecturerId)
        .where('receiverId', isEqualTo: widget.studentUid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var message in messages.docs) {
      await FirebaseFirestore.instance
          .collection('Messages')
          .doc(message.id)
          .update({'isRead': true});
    }
  }
  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (lecturerImageUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(lecturerImageUrl),
                radius: 16,
              ),
            SizedBox(width: 8),
            Text(
              "${widget.lecturerFirstName} ${widget.lecturerLastName}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F0E6), Color(0xFFE0D7C3)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Messages')
                    .where('senderId', whereIn: [widget.studentUid, widget.lecturerId])
                    .where('receiverId', whereIn: [widget.studentUid, widget.lecturerId])
                    .orderBy('timestamp', descending: false) // Order by timestamp ascending
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;

                  return ListView(
                    reverse: false, // Do not reverse the list
                    children: messages.map((message) {
                      var data = message.data() as Map<String, dynamic>;
                      bool isMe = data['senderId'] == widget.studentUid;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['message'],
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.white,
                                ),
                              ),
                              if (!isMe && !data['isRead']) // Show "Unread" indicator for lecturer's messages
                                Text(
                                  "Unread",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
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
}