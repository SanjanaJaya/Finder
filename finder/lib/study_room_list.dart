import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'study_room_detail_page.dart'; // Import the details page

// Define fetchStudyRooms function
Future<List<Map<String, dynamic>>> fetchStudyRooms() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Study_Rooms').get();
  return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

class StudyRoomListPage extends StatefulWidget {
  @override
  _StudyRoomListPageState createState() => _StudyRoomListPageState();
}

class _StudyRoomListPageState extends State<StudyRoomListPage> {
  final Future<List<Map<String, dynamic>>> studyRoomsFuture = fetchStudyRooms();
  String searchQuery = ""; // Track the search query

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
        title: Text("Book Your Study Room", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search study rooms...",
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update search query
                });
              },
            ),
            SizedBox(height: 16), // Spacing between search bar and list
            // Study Rooms List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: studyRoomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No study rooms available.'));
                  } else {
                    List<Map<String, dynamic>> studyRooms = snapshot.data!;

                    // Sort study rooms alphabetically by name
                    studyRooms.sort((a, b) => a['Name'].compareTo(b['Name']));

                    // Filter study rooms based on search query
                    List<Map<String, dynamic>> filteredRooms = studyRooms
                        .where((room) =>
                        room['Name'].toLowerCase().contains(searchQuery))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        var studyRoom = filteredRooms[index];
                        return _buildRoomCategory(context, studyRoom['Name'], studyRoom);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCategory(BuildContext context, String title, Map<String, dynamic> studyRoom) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudyRoomDetailPage(studyRoom: studyRoom),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffa9c6a8), // Greenish button
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}