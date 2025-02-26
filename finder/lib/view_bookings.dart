import 'package:flutter/material.dart';

class ViewBookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingCard("Library - 203", "Booked"),
            SizedBox(height: 12),
            _buildBookingCard("FOC B1 - 02", "Booked"),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(String roomName, String status) {
    return Container(
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
