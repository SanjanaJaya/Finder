import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lec_chat_screen.dart';

class LecturerInbox extends StatefulWidget {
  final String lecturerUid;

  const LecturerInbox({Key? key, required this.lecturerUid}) : super(key: key);

  @override
  _LecturerInboxState createState() => _LecturerInboxState();
}

class _LecturerInboxState extends State<LecturerInbox> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0E9DD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inbox",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Messages')
              .where('lecturerUid', isEqualTo: widget.lecturerUid) // Use lecturerUid
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No messages available."));
            }

            final messages = snapshot.data!.docs;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final messageData =
                messages[index].data() as Map<String, dynamic>;
                final studentId = messageData['studentId'] ?? '';
                final message = messageData['message'] ?? '';

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('Person').doc(studentId).get(),
                  builder: (context, studentSnapshot) {
                    if (studentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (studentSnapshot.hasError) {
                      return ListTile(title: Text("Error: ${studentSnapshot.error}"));
                    }

                    if (!studentSnapshot.hasData) {
                      return const ListTile(
                          title: Text("Error: Student data not found."));
                    }

                    final studentData = studentSnapshot.data!.data()
                    as Map<String, dynamic>;
                    final studentName =
                        "${studentData['First_Name']} ${studentData['Last_Name']}";
                    final studentEmail = studentData['Email'];

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            studentName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black54,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LecturerChatScreen(
                                studentEmail: studentEmail,
                                studentId: studentId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}