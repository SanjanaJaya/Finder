import 'package:flutter/material.dart';

class LibraryStudyRoomsPage extends StatelessWidget {
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
        title: Text("Library", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoomButton(context, "201"),
            _buildRoomButton(context, "202"),
            _buildRoomButton(context, "203"),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomButton(BuildContext context, String roomNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Add navigation to booking details if needed
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffa9c6a8), // Greenish button
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roomNumber,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
