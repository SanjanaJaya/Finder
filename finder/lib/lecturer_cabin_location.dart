import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LecturerCabinLocationPage extends StatefulWidget {
  final Map<String, dynamic> lecturer;

  LecturerCabinLocationPage({required this.lecturer});

  @override
  _LecturerCabinLocationPageState createState() => _LecturerCabinLocationPageState();
}

class _LecturerCabinLocationPageState extends State<LecturerCabinLocationPage> {
  GoogleMapController? _mapController;
  LatLng? _cabinLocation;
  LatLng? _userLocation;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLocationData();
    _getUserLocation();
  }

  Future<void> _fetchLocationData() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturer['uid'])
          .get();

      if (lecturerDoc.exists) {
        final locationData = lecturerDoc.data() as Map<String, dynamic>;
        final latitude = locationData['latitude'];
        final longitude = locationData['longitude'];

        if (latitude != null && longitude != null) {
          setState(() {
            _cabinLocation = LatLng(latitude, longitude);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Cabin location not available for this lecturer.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Lecturer data not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching location data: $e");
      setState(() {
        _errorMessage = 'Failed to fetch location data.';
        _isLoading = false;
      });
    }
  }

  // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting user location: $e");
      setState(() {
        _errorMessage = 'Failed to get user location.';
      });
    }
  }

  Future<void> _showDirections() async {
    if (_cabinLocation == null || _userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location data is incomplete.')),
      );
      return;
    }

    //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=${_cabinLocation!.latitude},${_cabinLocation!.longitude}&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lecturer Cabin Location"),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        color: Color(0xFFEEE7DA),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(fontSize: 18, color: Colors.red)))
            : SingleChildScrollView(
          child: Column(
            children: [
              // Google Map
              Container(
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 490,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _cabinLocation ?? LatLng(0, 0),
                        zoom: 15,
                      ),
                      markers: {
                        if (_cabinLocation != null)
                          Marker(
                            markerId: MarkerId("cabin_location"),
                            position: _cabinLocation!,
                            infoWindow: InfoWindow(title: "Lecturer's Cabin"),
                          ),
                        if (_userLocation != null)
                          Marker(
                            markerId: MarkerId("user_location"),
                            position: _userLocation!,
                            infoWindow: InfoWindow(title: "Your Location"),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                          ),
                      },
                    ),
                  ),
                ),
              ),
              // Lecturer Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${widget.lecturer['L_First_Name']} ${widget.lecturer['L_Last_Name']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Position: ${widget.lecturer['Job_Role']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Contact No: ${widget.lecturer['Contact No']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Building and Floor Details
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Building: ${widget.lecturer['building'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Floor: ${widget.lecturer['floor'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    // Directions Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _showDirections,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black, width: 2),
                          ),
                          elevation: 5,
                        ),
                        // Developed By,
                        // Imesh Sanjana - 30137 - 10953245
                        // Gaveen Ranasinghe - 29934 - 10952369
                        // Sehara Gishan - 26041 - 10953243
                        child: Text(
                          "Show Directions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}