import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyRoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> studyRoom;

  StudyRoomDetailPage({required this.studyRoom});

  Future<bool> _hasUserBookedRoom(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Study_Rooms')
        .where('bookedBy', isEqualTo: uid)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243

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
          .doc(studyRoom['Name'])
          .update({
        'isBooked': true,
        'bookedBy': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room booked successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book the room: $e')),
      );
    }
  }

  Future<String> _fetchBookerName(String? uid) async {
    if (uid == null) return 'Unknown User';

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
  //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374

  @override
  Widget build(BuildContext context) {
    final bool isBooked = studyRoom['isBooked'] ?? false;
    final String? bookedByUid = studyRoom['bookedBy'];

    return Scaffold(
      backgroundColor: Color(0xffeee7da), // Beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          studyRoom['Name'] ?? 'Study Room',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Color(0xfff4f1eb), // Light beige card background
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            studyRoom['Image'] ?? 'https://via.placeholder.com/150',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          studyRoom['Name'] ?? 'Study Room',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildDetailRow('Floor', studyRoom['Floor'] ?? 'N/A'),
                        _buildDetailRow('Location', studyRoom['Location'] ?? 'N/A'),
                        _buildDetailRow('Seating Capacity', studyRoom['Seating_Capacity'] ?? 'N/A'),
                        _buildDetailRow('Plug Count', studyRoom['Plug_Count'].toString()),
                        _buildDetailRow(
                          'Status',
                          isBooked ? 'Booked' : 'Available',
                          textColor: isBooked ? Colors.red : Colors.green,
                        ),
                        if (isBooked && bookedByUid != null)
                          FutureBuilder<String>(
                            future: _fetchBookerName(bookedByUid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildDetailRow('Booked By', 'Loading...');
                              } else if (snapshot.hasError) {
                                return _buildDetailRow('Booked By', 'Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return _buildDetailRow('Booked By', 'Unknown User');
                              } else {
                                return _buildDetailRow('Booked By', snapshot.data!);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (!isBooked)
                  ElevatedButton(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}