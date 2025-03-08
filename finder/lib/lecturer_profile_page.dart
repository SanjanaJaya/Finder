import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerProfilePage extends StatefulWidget {
  final String lecturerUid;

  const LecturerProfilePage({Key? key, required this.lecturerUid})
      : super(key: key);

  @override
  _LecturerProfilePageState createState() => _LecturerProfilePageState();
}

class _LecturerProfilePageState extends State<LecturerProfilePage> {
  String? firstName;
  String? lastName;
  String? email;
  String? jobRole;
  String? city;
  String? facultyName;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchLecturerData();
  }

  Future<void> _fetchLecturerData() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturerUid)
          .get();

      if (lecturerDoc.exists) {
        setState(() {
          firstName = lecturerDoc['L_First_Name'];
          lastName = lecturerDoc['L_Last_Name'];
          email = lecturerDoc['Email'];
          jobRole = lecturerDoc['Job_Role'];
          city = lecturerDoc['City'];
          facultyName = lecturerDoc['Faculty_Name'];
          imageUrl = lecturerDoc['Image'];
        });
      }
    } catch (e) {
      print("Error fetching lecturer data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4EEDD), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Larger Lecturer Image
              Container(
                width: 150, // Increased size
                height: 150, // Increased size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black87,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey[600],
                      );
                    },
                  )
                      : Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Lecturer Name
              Text(
                firstName != null && lastName != null
                    ? '$firstName $lastName'
                    : 'Loading...',
                style: TextStyle(
                  fontSize: 28, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              // Job Role
              Text(
                jobRole ?? 'Unknown Role',
                style: TextStyle(
                  fontSize: 20, // Increased font size
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              // Profile Info Cards
              if (email != null) ProfileInfoCard('Email: $email'),
              if (city != null) ProfileInfoCard('City: $city'),
              if (facultyName != null) ProfileInfoCard('Faculty: $facultyName'),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String text;
  ProfileInfoCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF87A98F), // Greenish shade
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.black87), // Increased font size
        ),
      ),
    );
  }
}