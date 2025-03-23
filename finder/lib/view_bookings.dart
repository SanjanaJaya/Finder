import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewBookingsPage extends StatelessWidget {
  // Function to fetch booked rooms for the current user
  Future<List<Map<String, dynamic>>> _fetchBookedRooms(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Study_Rooms')
        .where('bookedBy', isEqualTo: uid)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Function to fetch booker's name from the Person collection
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

  // Function to cancel a booking
  Future<void> _cancelBooking(String roomName, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('Study_Rooms')
          .doc(roomName)
          .update({
        'isBooked': false,
        'bookedBy': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking canceled successfully!')),
      );

      // Refresh the page to reflect changes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewBookingsPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: $e')),
      );
    }
  }
  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Bookings"),
          backgroundColor: Color(0xffeee7da), // Beige background
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Color(0xffeee7da), // Beige background
        body: Center(
          child: Text('You must be logged in to view bookings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: Color(0xffeee7da), // Beige background
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Color(0xffeee7da), // Beige background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchBookedRooms(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No bookings found.'));
            } else {
              final bookedRooms = snapshot.data!;
              return ListView.builder(
                itemCount: bookedRooms.length,
                itemBuilder: (context, index) {
                  final room = bookedRooms[index];
                  return _buildBookingCard(room, context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  // Widget to build a booking card with more details
  Widget _buildBookingCard(Map<String, dynamic> room, BuildContext context) {
    final bool isBooked = room['isBooked'] ?? false;
    final String? bookedByUid = room['bookedBy'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Color(0xfff4f1eb), // Light beige card background
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room['Name'] ?? 'Study Room',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            _buildDetailRow('Floor', room['Floor'] ?? 'N/A'),
            _buildDetailRow('Location', room['Location'] ?? 'N/A'),
            _buildDetailRow('Seating Capacity', room['Seating_Capacity'] ?? 'N/A'),
            _buildDetailRow('Plug Count', room['Plug_Count'].toString()),
            _buildDetailRow(
              'Status',
              isBooked ? 'Booked' : 'Available',
              textColor: isBooked ? Colors.green : Colors.red, // Green for Booked
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
            SizedBox(height: 10),
            if (isBooked)
              Center(
                child: ElevatedButton(
                  onPressed: () => _cancelBooking(room['Name'], context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffa9c6a8), // Greenish button
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a detail row
  Widget _buildDetailRow(String label, String value, {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}