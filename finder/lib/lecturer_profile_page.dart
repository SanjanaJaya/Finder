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

  // Cabin details
  String? building;
  String? floor;
  double? latitude;
  double? longitude;

  // Controllers for editing cabin details
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

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

          // Fetch cabin details (ensure fields exist and handle null values)
          building = lecturerDoc['building'] ?? 'Not specified';
          floor = lecturerDoc['floor'] ?? 'Not specified';
          latitude = lecturerDoc['latitude'] ?? 0.0;
          longitude = lecturerDoc['longitude'] ?? 0.0;

          // Set initial values for controllers
          _buildingController.text = building!;
          _floorController.text = floor!;
          _latitudeController.text = latitude?.toString() ?? '0.0';
          _longitudeController.text = longitude?.toString() ?? '0.0';

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

  Future<void> _updateCabinDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturerUid)
          .update({
        'building': _buildingController.text,
        'floor': _floorController.text,
        'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
      });

      // Update local state
      setState(() {
        building = _buildingController.text;
        floor = _floorController.text;
        latitude = double.tryParse(_latitudeController.text);
        longitude = double.tryParse(_longitudeController.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cabin details updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update cabin details: $e')),
      );
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
                    child: imageUrl != null
                        ? Image.network(
                      imageUrl!,
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
            // Lecturer Name
            Text(
              firstName != null && lastName != null
                  ? '$firstName $lastName'
                  : 'Unknown Lecturer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            // Job Role
            //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
            Text(
              jobRole ?? 'Unknown Role',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            // Profile Info Cards
            if (email != null) _buildInfoCard('Email', email!),
            if (city != null) _buildInfoCard('City', city!),
            if (facultyName != null)
              _buildInfoCard('Faculty', facultyName!),
            if (building != null) _buildInfoCard('Building', building!),
            if (floor != null) _buildInfoCard('Floor', floor!),
            if (latitude != null && longitude != null)
              _buildInfoCard(
                  'Location',
                  'Lat: ${latitude!.toStringAsFixed(4)}, '
                      'Lng: ${longitude!.toStringAsFixed(4)}'),
            SizedBox(height: 20),
            // Edit Cabin Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Cabin Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildEditField('Building', _buildingController),
                  _buildEditField('Floor', _floorController),
                  _buildEditField('Latitude', _latitudeController),
                  _buildEditField('Longitude', _longitudeController),
                  SizedBox(height: 10),
                  // Add the new text here
                  Text(
                    'You can get Latitude & Longitude from Google Maps Mobile Application',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateCabinDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C8E7D),
                        padding: EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
                      child: Text(
                        'Update Cabin Details',
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}