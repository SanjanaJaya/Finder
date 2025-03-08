import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecturer_chat_screen.dart';

class LecturerInboxScreen extends StatefulWidget {
  final String lecturerUid;

  const LecturerInboxScreen({Key? key, required this.lecturerUid})
    : super(key: key);

  @override
  _LecturerInboxScreenState createState() => _LecturerInboxScreenState();
}

class _LecturerInboxScreenState extends State<LecturerInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E8DC), // Light beige background
      appBar: AppBar(
        backgroundColor: Color(0xFFF3E8DC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inbox',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Messages')
                .where('receiverId', isEqualTo: widget.lecturerUid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages found.'));
          }

          // Group messages by senderId
          Map<String, List<DocumentSnapshot>> groupedMessages = {};
          for (var message in snapshot.data!.docs) {
            String senderId = message['senderId'];
            if (!groupedMessages.containsKey(senderId)) {
              groupedMessages[senderId] = [];
            }
            groupedMessages[senderId]!.add(message);
          }

          return ListView.builder(
            itemCount: groupedMessages.length,
            itemBuilder: (context, index) {
              String senderId = groupedMessages.keys.elementAt(index);
              List<DocumentSnapshot> messages = groupedMessages[senderId]!;

              // Fetch student details (First_Name and Last_Name)
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('Person')
                        .doc(senderId)
                        .get(),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox.shrink(); // Hide loading items
                  }

                  if (studentSnapshot.hasError || !studentSnapshot.hasData) {
                    return ListTile(title: Text("Unknown Student"));
                  }

                  String firstName = studentSnapshot.data!['First_Name'] ?? '';
                  String lastName = studentSnapshot.data!['Last_Name'] ?? '';
                  String studentName = '$firstName $lastName';

                  // Get the latest message
                  String latestMessage = messages.first['message'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LecturerChatScreen(
                                senderId: senderId,
                                receiverId: widget.lecturerUid,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Text(
                              firstName.isNotEmpty ? firstName[0] : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  latestMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
