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

  bool isLoading = true;
  String errorMessage = "";

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
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Lecturer data not found.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching lecturer data: $e";
        isLoading = false;
      });
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
      body: Center(
        child: isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Loading Profile...",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        )
            : errorMessage.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Bigger Lecturer Image with Rounded Corners and Shadow
              Container(
                width: 250, // Increased size
                height: 250, // Increased size
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error,
                        size: 80,
                        color: Colors.red,
                      ); // Fallback for errors
                    },
                  )
                      : Icon(
                    Icons.person,
                    size: 120,
                    color: Colors.black54,
                  ), // Fallback icon
                ),
              ),
              SizedBox(height: 20),
              // Lecturer Name
              Text(
                firstName != null && lastName != null
                    ? '$firstName $lastName'
                    : 'Unknown Lecturer',
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
              if (facultyName != null)
                ProfileInfoCard('Faculty: $facultyName'),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87A98F), Color(0xFF6C8E7D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}