import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'lecturer_profile_page.dart';
import 'lecturers_appointment.dart';
import 'lecturer_inbox.dart';
import 'opening_page.dart';

class LecturerHomePage extends StatefulWidget {
  final String lecturerUid;

  const LecturerHomePage({Key? key, required this.lecturerUid})
      : super(key: key);

  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  String? lecturerName;
  String? lecturerStatus;
  int unreadMessageCount = 0;
  int pendingAppointmentCount = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _fetchLecturerName();
    _fetchLecturerStatus();
    _setupFCM();
    _fetchUnreadMessageCount();
    _fetchPendingAppointmentCount();
  }

  Future<void> _setupFCM() async {
    // Request permission for notifications (iOS only)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Save the token to Firestore (to send notifications later)
    await FirebaseFirestore.instance
        .collection('Lecturer')
        .doc(widget.lecturerUid)
        .update({'fcmToken': token});

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? 'New notification')),
      );
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Background message: ${message.notification?.title}");
  }

  Future<void> _fetchLecturerName() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
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

  Future<void> _fetchLecturerStatus() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturerUid)
          .get();

      if (lecturerDoc.exists) {
        setState(() {
          lecturerStatus = lecturerDoc['status'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching lecturer status: $e");
    }
  }

  Future<void> _fetchUnreadMessageCount() async {
    try {
      QuerySnapshot unreadMessages = await FirebaseFirestore.instance
          .collection('Messages')
          .where('receiverId', isEqualTo: widget.lecturerUid)
          .where('isRead', isEqualTo: false)
          .get();

      setState(() {
        unreadMessageCount = unreadMessages.docs.length;
      });
    } catch (e) {
      print("Error fetching unread messages: $e");
    }
  }

  Future<void> _fetchPendingAppointmentCount() async {
    try {
      QuerySnapshot pendingAppointments = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('lecturerUid', isEqualTo: widget.lecturerUid)
          .where('status', isEqualTo: 'Pending')
          .get();

      setState(() {
        pendingAppointmentCount = pendingAppointments.docs.length;
      });
    } catch (e) {
      print("Error fetching pending appointments: $e");
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturerUid)
          .update({'status': status});

      setState(() {
        lecturerStatus = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (e) {
      print("Error updating status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // Update the lecturer's login status to false
      await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturerUid)
          .update({'isLoggedIn': false});

      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // Navigate to the opening page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OpeningPage(),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LecturerProfilePage(
                                  lecturerUid: widget.lecturerUid,
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _logout,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
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
                        color: lecturerStatus == 'Inside Cabin' ? Colors.green : Colors.grey,
                        icon: Icons.check_circle,
                        text: 'AVAILABLE',
                        subtitle: 'MY CABIN',
                        onTap: () => _updateStatus('Inside Cabin'),
                      ),
                      const SizedBox(height: 20),
                      _availabilityOption(
                        color: lecturerStatus == 'Outside Cabin' ? Colors.red : Colors.grey,
                        icon: Icons.exit_to_app,
                        text: 'OUTSIDE',
                        subtitle: 'OUTSIDE',
                        onTap: () => _updateStatus('Outside Cabin'),
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
                      unreadMessageCount,
                    ),
                    _buildActionButton(
                      "assets/appointment.png",
                      "Appointments",
                      LecturersAppointment(),
                      pendingAppointmentCount,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2))],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.white),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
    );
  }

  Widget _buildActionButton(String iconPath, String label, Widget page, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Stack(
        children: [
          Column(
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
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
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