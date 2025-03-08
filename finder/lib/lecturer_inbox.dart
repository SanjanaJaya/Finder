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
      appBar: AppBar(title: Text('Inbox')),
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
                    return ListTile(title: Text("Loading..."));
                  }

                  if (studentSnapshot.hasError || !studentSnapshot.hasData) {
                    return ListTile(title: Text("Unknown Student"));
                  }

                  String firstName = studentSnapshot.data!['First_Name'] ?? '';
                  String lastName = studentSnapshot.data!['Last_Name'] ?? '';
                  String studentName = '$firstName $lastName';

                  return ListTile(
                    title: Text(studentName),
                    subtitle: Text("Messages: ${messages.length}"),
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
