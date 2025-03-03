import 'package:flutter/material.dart';
import 'lecturer_list.dart'; // Lecturer List Page
import 'study_room_list.dart'; // Study Room List Page
import 'contact_us.dart'; // Contact Us Page
import 'about_us.dart'; // About Us Page ✅
import 'view_bookings.dart'; // Import the View Bookings Page
import 'student_profile_page.dart'; // Import the Student Profile Page
import 'lecturer_home.dart'; // Import Lecturer Home Page
import 'opening_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LecturerHomePage(), // Set LecturerHomePage as the start
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeee7da), // Beige Background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: Logo, Back & Profile Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/NSBM_logo.png",
                      width: 130,
                    ), // University Logo
                    Row(
                      children: [
                        Icon(Icons.arrow_back, size: 30),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentProfilePage(),
                              ),
                            );
                          },
                          child: Icon(Icons.person, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Welcome Banner
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/campus.png",
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Good Morning,\nSanjana Jayasooriya",
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

                // Quick Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      context,
                      "assets/location.png",
                      "Meet Your\nLecturer",
                      LecturerListPage(),
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
                    ), // Updated to navigate to ViewBookingsPage
                  ],
                ),
                SizedBox(height: 20),

                // Latest News Section
                Text(
                  "LATEST NEWS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/classroom.png",
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),

                // Bottom Buttons: Contact Us & About Us
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
                    ), // ✅ Navigates to About Us Page
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Quick Action Button Widget (Supports Navigation)
  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    Widget? page,
  ) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
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

  // 🔹 Bottom Button Widget (Supports Navigation)
  Widget _buildBottomButton(
    BuildContext context,
    String iconPath,
    String label,
    Widget? page,
  ) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
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
