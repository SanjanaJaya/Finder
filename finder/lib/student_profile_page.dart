import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String firstName = "Loading...";
  String lastName = "";
  String id = "";
  String intake = "";
  String faculty = "";
  String email = "";
  String degree = "";

  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("Fetching user data...");

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in.");
      setState(() {
        firstName = "User Not Found";
        isLoading = false;
        errorMessage = "No user logged in.";
      });
      return;
    }

    print("Logged in user UID: ${user.uid}");

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('Person')
          .where('uid', isEqualTo: user.uid)
          .get();

      print("Query executed. Found documents: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        print("User data retrieved: $userData");

        setState(() {
          firstName = userData['First_Name'] ?? "Unknown";
          lastName = userData['Last_Name'] ?? "Unknown";
          id = userData['ID']?.toString() ?? "Unknown";
          intake = userData['Intake'] ?? "Unknown";
          faculty = userData['Faculty'] ?? "Unknown";
          email = userData['Email'] ?? "Unknown";
          degree = userData['Degree'] ?? "Unknown";
          isLoading = false;
          errorMessage = "";
        });
      } else {
        print("No document found in Firestore for UID: ${user.uid}");
        setState(() {
          firstName = "No Data Found";
          isLoading = false;
          errorMessage = "No data found for this user.";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        firstName = "Error loading data";
        isLoading = false;
        errorMessage = "Error loading data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4EEDD),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$firstName $lastName",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.person, size: 80, color: Colors.black54),
              ),
              SizedBox(height: 20),
              ProfileInfoCard('Student ID: $id'),
              ProfileInfoCard('Intake: $intake'),
              ProfileInfoCard('Faculty: $faculty'),
              ProfileInfoCard('Email: $email'),
              ProfileInfoCard('Degree: $degree'),
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
          color: Color(0xFF87A98F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}