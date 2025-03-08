import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting the current user's UID

class StudyRoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> studyRoom;

  StudyRoomDetailPage({required this.studyRoom});

  // Function to check if the user has already booked a room
  Future<bool> _hasUserBookedRoom(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Study_Rooms')
        .where('bookedBy', isEqualTo: uid)
        .get();

    return querySnapshot.docs.isNotEmpty; // Returns true if the user has booked a room
  }

  // Function to book the study room
  Future<void> _bookStudyRoom(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to book a room.')),
      );
      return;
    }

    if (studyRoom['isBooked'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This room is already booked.')),
      );
      return;
    }

    // Check if the user has already booked a room
    final hasBooked = await _hasUserBookedRoom(user.uid);
    if (hasBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only book one room at a time.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Study_Rooms')
          .doc(studyRoom['Name']) // Use the room name as the document ID
          .update({
        'isBooked': true,
        'bookedBy': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room booked successfully!')),
      );

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book the room: $e')),
      );
    }
  }

  // Function to fetch booker's name from the Person collection
  Future<String> _fetchBookerName(String uid) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Person')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return '${data['First_Name']} ${data['Last_Name']}';
    } else {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeee7da), // Beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(studyRoom['Name'], style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Floor: ${studyRoom['Floor']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${studyRoom['Location']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Status: ${studyRoom['isBooked'] ? 'Booked' : 'Available'}',
              style: TextStyle(
                fontSize: 18,
                color: studyRoom['isBooked'] ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 10),
            if (studyRoom['isBooked'])
              FutureBuilder<String>(
                future: _fetchBookerName(studyRoom['bookedBy']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading booker details...', style: TextStyle(fontSize: 18));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 18));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Booked By: Unknown User', style: TextStyle(fontSize: 18));
                  } else {
                    return Text('Booked By: ${snapshot.data!}', style: TextStyle(fontSize: 18));
                  }
                },
              ),
            SizedBox(height: 20),
            if (!studyRoom['isBooked'])
              Center(
                child: ElevatedButton(
                  onPressed: () => _bookStudyRoom(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffa9c6a8), // Greenish button
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Book This Room',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}