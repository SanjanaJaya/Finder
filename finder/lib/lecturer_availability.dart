import 'package:flutter/material.dart';
import 'lecturer_home.dart';

class LecturerAvailabilityPage extends StatelessWidget {
  final String lecturerUid;

  const LecturerAvailabilityPage({Key? key, required this.lecturerUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE7DA), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hi,',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Replace with your font
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Prof. Chaminda Rathnayake',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto', // Replace with your font
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Select Your Availability Here!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LecturerHomePage(
                        lecturerUid: lecturerUid,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'DONE',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
                    fontFamily: 'Roboto', // Replace with your font
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto', // Replace with your font
          ),
        ),
      ],
    );
  }
}