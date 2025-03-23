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
        stream: FirebaseFirestore.instance
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

          // Group messages by senderId and count unread messages
          Map<String, List<DocumentSnapshot>> groupedMessages = {};
          Map<String, int> unreadCounts = {};
          for (var message in snapshot.data!.docs) {
            String senderId = message['senderId'];
            if (!groupedMessages.containsKey(senderId)) {
              groupedMessages[senderId] = [];
              unreadCounts[senderId] = 0;
            }
            groupedMessages[senderId]!.add(message);

            // Count unread messages
            if (message['isRead'] == false) {
              unreadCounts[senderId] = unreadCounts[senderId]! + 1;
            }
          }

          return ListView.builder(
            itemCount: groupedMessages.length,
            itemBuilder: (context, index) {
              String senderId = groupedMessages.keys.elementAt(index);
              List<DocumentSnapshot> messages = groupedMessages[senderId]!;
              int unreadCount = unreadCounts[senderId] ?? 0;

              // Fetch student details (First_Name, Last_Name, and Image)
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
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
                  String imageUrl = studentSnapshot.data!['Image'] ?? ''; // Fetch the image URL

                  // Get the latest message
                  String latestMessage = messages.first['message'];

                  return Dismissible(
                    key: Key(senderId), // Unique key for each chat
                    direction: DismissDirection.endToStart, // Swipe from right to left
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red, // Red background for delete
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      // Show a custom confirmation dialog before deleting
                      return await showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.all(16),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFF3E8DC), // Match inbox background
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Delete Chat",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Are you sure you want to delete this chat?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      // Delete all messages with this senderId
                      for (var message in messages) {
                        FirebaseFirestore.instance
                            .collection('Messages')
                            .doc(message.id)
                            .delete();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Chat deleted"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
                    child: GestureDetector(
                      onTap: () async {
                        // Mark all messages from this sender as read
                        for (var message in messages) {
                          if (message['isRead'] == false) {
                            await FirebaseFirestore.instance
                                .collection('Messages')
                                .doc(message.id)
                                .update({'isRead': true});
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LecturerChatScreen(
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
                            // Display profile image if available, otherwise show initials
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? Text(
                                firstName.isNotEmpty ? firstName[0] : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )
                                  : null,
                              backgroundColor: imageUrl.isEmpty ? Colors.black : null,
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
                            // Show unread message count
                            if (unreadCount > 0)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
                          ],
                        ),
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