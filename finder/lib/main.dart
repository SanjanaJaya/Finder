import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support
import 'lecturer_list_page.dart';
import 'study_room_list.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'view_bookings.dart';
import 'student_profile_page.dart';
import 'opening_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return HomePage();
          } else {
            return OpeningPage();
          }
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> newsItems = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  Map<String, dynamic>? studentData; // To store student data

  @override
  void initState() {
    super.initState();
    fetchNews();
    fetchStudentData(); // Fetch student data when the page loads
  }

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://web-scraper-nsbm.onrender.com/'));
    if (response.statusCode == 200) {
      setState(() {
        newsItems = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<void> fetchStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Person')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          studentData = doc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OpeningPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeee7da),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/NSBM_logo.png", width: 130),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, size: 30),
                          onPressed: () => _logout(context),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StudentProfilePage()),
                            );
                          },
                          child: Icon(Icons.person, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/campus_large.png", // Replace with a larger image
                        width: double.infinity,
                        height: 200, // Adjust height to fit the screen
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        studentData != null
                            ? "Welcome,\n${studentData!['First_Name']} ${studentData!['Last_Name']}"
                            : "Welcome,\nLoading...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      context,
                      "assets/location.png",
                      "Meet Your\nLecturer",
                      LecturerListPage(
                        studentUid: FirebaseAuth.instance.currentUser?.uid ?? "",
                      ),
                    ),
                    _buildActionButton(
                      context,
                      "assets/calendar.png",
                      "Book Study\nRoom",
                      StudyRoomListPage(),
                    ),
                    _buildActionButton(
                      context,
                      "assets/list.png",
                      "View\nBookings",
                      ViewBookingsPage(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  "LATEST NEWS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                newsItems.isEmpty
                    ? CircularProgressIndicator()
                    : SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: newsItems.length,
                    itemBuilder: (context, index) {
                      final item = newsItems[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _buildNewsImage(item['image']), // Handle SVG or fallback
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    item['title'],
                                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomButton(
                      context,
                      "assets/contact.png",
                      "Contact Us",
                      ContactUsPage(),
                    ),
                    _buildBottomButton(
                      context,
                      "assets/about.png",
                      "About Us",
                      AboutUsPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsImage(String imageUrl) {
    if (imageUrl.startsWith('data:image/svg+xml')) {
      // Handle SVG data URI
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover, // Make the SVG fill the space
        placeholderBuilder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Handle other image formats (e.g., PNG, JPG)
      return Image.network(
        imageUrl,
        fit: BoxFit.cover, // Make the image fill the space
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }

  Widget _buildActionButton(BuildContext context, String iconPath, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Center(child: Image.asset(iconPath, width: 50, height: 50)),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, String iconPath, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        width: 170,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 24, height: 24),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}