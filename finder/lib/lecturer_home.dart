import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'lecturer_profile_page.dart'; // Ensure this is imported
import 'lecturers_appointment.dart';
import 'lecturer_inbox.dart';
import 'opening_page.dart'; // Import the opening page

class LecturerHomePage extends StatefulWidget {
  final String lecturerUid;

  const LecturerHomePage({Key? key, required this.lecturerUid})
    : super(key: key);

  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  String? lecturerName;

  @override
  void initState() {
    super.initState();
    _fetchLecturerName();
  }

  Future<void> _fetchLecturerName() async {
    try {
      DocumentSnapshot lecturerDoc =
          await FirebaseFirestore.instance
              .collection('Lecturer')
              .doc(widget.lecturerUid)
              .get();

      if (lecturerDoc.exists) {
        String firstName = lecturerDoc['L_First_Name'] ?? '';
        String lastName = lecturerDoc['L_Last_Name'] ?? '';
        setState(() {
          lecturerName = '$firstName $lastName';
        });
      }
    } catch (e) {
      print("Error fetching lecturer name: $e");
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OpeningPage(), // Navigate to the opening page
        ),
      );
    } catch (e) {
      print("Error during logout: $e");
    }
  }

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
                    Image.asset("assets/NSBM_logo.png", width: 130),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LecturerProfilePage(
                                      lecturerUid: widget.lecturerUid,
                                    ), // Pass lecturerUid
                              ),
                            );
                          },
                          child: const Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _logout, // Logout functionality
                          child: const Icon(Icons.logout, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  lecturerName != null
                      ? "Good Morning,\n$lecturerName"
                      : "Good Morning,\nLoading...",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // No navigation needed since availability is now on the home page
                    },
                    child: const Text(
                      "Select Your Availability Here",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      _availabilityOption(
                        color: Colors.green,
                        icon: Icons.check_circle,
                        text: 'AVAILABLE',
                        subtitle: 'MY CABIN',
                      ),
                      const SizedBox(height: 20),
                      _availabilityOption(
                        color: Colors.red,
                        icon: Icons.exit_to_app,
                        text: 'OUTSIDE',
                        subtitle: 'OUTSIDE',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      "assets/inbox.png",
                      "Inbox",
                      LecturerInboxScreen(lecturerUid: widget.lecturerUid),
                    ),
                    _buildActionButton(
                      "assets/appointment.png",
                      "Appointments",
                      LecturersAppointment(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButton(
                      "assets/contact.png",
                      "Contact Us",
                      ContactUsPage(),
                    ),
                    _buildBottomButton(
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

  Widget _availabilityOption({
    required Color color,
    required IconData icon,
    required String text,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButton(String iconPath, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Column(
        children: [
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Center(child: Image.asset(iconPath, width: 50, height: 50)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String iconPath, String label, Widget page) {
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
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
