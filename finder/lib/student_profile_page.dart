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
  String imageUrl = ""; // Add this variable to store the image URL

  bool isLoading = true;
  String errorMessage = "";

  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243

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
          imageUrl = userData['Image'] ?? ""; // Fetch the image URL
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
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Loading Profile...",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
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
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo Container with Background Image
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/campus_large.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.black54,
                        ); // Fallback for errors
                      },
                    )
                        : Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.black54,
                    ), // Fallback icon
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
            // Student Name
            Text(
              "$firstName $lastName",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            // Student ID
            Text(
              "ID: $id",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30),
            // Profile Info Cards
            _buildInfoCard('Intake', intake),
            _buildInfoCard('Faculty', faculty),
            _buildInfoCard('Email', email),
            _buildInfoCard('Degree', degree),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
          ],
        ),
      ),
    );
  }
}