import 'package:flutter/material.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'lecturer_profile_page.dart';
import 'lecturer_availability.dart';
import 'lecturers_appointment.dart';
import 'lecturer_inbox.dart';

class LecturerHomePage extends StatelessWidget {
  final String lecturerUid; // Add lecturerUid to the constructor

  const LecturerHomePage({Key? key, required this.lecturerUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeee7da),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/NSBM_logo.png",
                      width: 130,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 30),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LecturerProfilePage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.person, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Good Morning,\nProf.Chaminda Rthnayake",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      context,
                      "assets/Switch.png",
                      "Availability",
                      LecturerAvailabilityPage(lecturerUid: lecturerUid), // Pass lecturerUid here
                    ),
                    _buildActionButton(
                      context,
                      "assets/appointment.png",
                      "Appointments",
                      LecturersAppointment(),
                    ),
                    _buildActionButton(
                      context,
                      "assets/inbox.png",
                      "Inbox",
                      LecturerInbox(lecturerUid: lecturerUid), // Pass lecturerUid here
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "LATEST NEWS",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/Home.jpg",
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
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
