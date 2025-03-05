import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'lec_chat_screen.dart';

class LecturerInboxScreen extends StatefulWidget {
  final String lecturerUid; // Receive lecturerUid here

  const LecturerInboxScreen({Key? key, required this.lecturerUid})
    : super(key: key);

  @override
  _LecturerInboxScreenState createState() => _LecturerInboxScreenState();
}

class _LecturerInboxScreenState extends State<LecturerInboxScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _lecturerId;

  @override
  void initState() {
    super.initState();
    _lecturerId = widget.lecturerUid; // Use lecturerUid passed to the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inbox"), backgroundColor: Colors.blue),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('messages')
                .where('receiverId', isEqualTo: _lecturerId)
                .snapshots(),
        builder: (context, messageSnapshot) {
          if (messageSnapshot.hasError) {
            return const Center(child: Text("Error loading messages."));
          }

          if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No messages received."));
          }

          // Log to check the messages being fetched
          print('Fetched messages: ${messageSnapshot.data!.docs.length}');

          // Get the student IDs who sent messages
          Set<String> studentIds = Set();
          messageSnapshot.data!.docs.forEach((doc) {
            studentIds.add(doc['senderId']);
            print('Message from senderId: ${doc['senderId']}');
          });

          return StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection('Person')
                    .where(FieldPath.documentId, whereIn: studentIds.toList())
                    .snapshots(),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.hasError) {
                return const Center(child: Text("Error loading students."));
              }

              if (!studentSnapshot.hasData ||
                  studentSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No students found."));
              }

              List<DocumentSnapshot> students = studentSnapshot.data!.docs;

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  var studentData = students[index];
                  String studentId = studentData.id;
                  String studentEmail = studentData['Email'];
                  String studentName =
                      "${studentData['First_Name']} ${studentData['Last_Name']}";

                  // Log student details
                  print('Student found: $studentName with ID: $studentId');

                  // Find the most recent message sent by the student
                  String latestMessage = "No messages yet.";
                  var studentMessages =
                      messageSnapshot.data!.docs
                          .where(
                            (doc) =>
                                doc['senderId'] == studentId &&
                                doc['receiverId'] == _lecturerId,
                          )
                          .toList();
                  if (studentMessages.isNotEmpty) {
                    studentMessages.sort((a, b) {
                      // Ensure that the timestamp is not null before comparing
                      Timestamp? timestampA = a['timestamp'] as Timestamp?;
                      Timestamp? timestampB = b['timestamp'] as Timestamp?;

                      if (timestampA == null || timestampB == null) {
                        return 0; // Return 0 if either timestamp is null
                      }

                      return timestampB.compareTo(timestampA);
                    });
                    latestMessage = studentMessages.first['message'];
                  }

                  // Log the latest message
                  print('Latest message for $studentName: $latestMessage');

                  return ListTile(
                    title: Text(studentName),
                    subtitle: Text(latestMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LecturerChatScreen(
                                studentEmail: studentEmail,
                                studentId: studentId,
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
