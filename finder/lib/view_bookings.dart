import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting the current user's UID

class ViewBookingsPage extends StatelessWidget {
  // Function to fetch booked rooms for the current user
  Future<List<Map<String, dynamic>>> _fetchBookedRooms(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Study_Rooms')
        .where('bookedBy', isEqualTo: uid)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

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
                  return _buildBookingCard(room['Name'], 'Booked');
                },
              );
            }
          },
        ),
      ),
    );
  }

  // Widget to build a booking card
  Widget _buildBookingCard(String roomName, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xffA9C6A0), // Light green background
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            roomName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Dark text
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}