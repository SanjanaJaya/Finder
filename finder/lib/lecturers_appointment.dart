import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class LecturersAppointment extends StatefulWidget {
  const LecturersAppointment({super.key});

  @override
  _LecturersAppointmentState createState() => _LecturersAppointmentState();
}

class _LecturersAppointmentState extends State<LecturersAppointment> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String lecturerName = "Loading..."; // To store the lecturer's name

  @override
  void initState() {
    super.initState();
    _fetchLecturerName(); // Fetch lecturer's name when the page loads
  }

  // Function to fetch the lecturer's name
  Future<void> _fetchLecturerName() async {
    final lecturerUid = _auth.currentUser?.uid;
    if (lecturerUid == null) return;

    // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
    try {
      final lecturerDoc = await _firestore
          .collection('Lecturer')
          .doc(lecturerUid)
          .get();

      if (lecturerDoc.exists) {
        final lecturerData = lecturerDoc.data() as Map<String, dynamic>;
        setState(() {
          lecturerName =
          "${lecturerData['L_First_Name']} ${lecturerData['L_Last_Name']}";
        });
      } else {
        setState(() {
          lecturerName = "Unknown Lecturer";
        });
      }
    } catch (e) {
      setState(() {
        lecturerName = "Error fetching name";
      });
    }
  }

  // Function to fetch appointments for the logged-in lecturer
  Stream<QuerySnapshot> _fetchAppointments() {
    final lecturerUid = _auth.currentUser?.uid;
    if (lecturerUid == null) {
      return const Stream.empty(); // Return an empty stream if no user is logged in
    }

    return _firestore
        .collection('Appointments')
        .where('lecturerUid', isEqualTo: lecturerUid)
        .snapshots();
  }

  // Function to update the status of an appointment
  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore
          .collection('Appointments')
          .doc(appointmentId)
          .update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0E9DD), // Light beige background
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hi,",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              lecturerName, // Display fetched lecturer name
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  } else {
                    final appointments = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index].data() as Map<String, dynamic>;
                        final appointmentId = appointments[index].id;
                        final studentUid = appointment['studentUid'];
                        final date = (appointment['date'] as Timestamp).toDate();
                        final time = appointment['time'];
                        final status = appointment['status'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('Person').doc(studentUid).get(),
                          builder: (context, studentSnapshot) {
                            if (studentSnapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                title: Text('Loading student details...'),
                              );
                            } else if (studentSnapshot.hasError) {
                              return ListTile(
                                title: Text('Error: ${studentSnapshot.error}'),
                              );
                            } else if (!studentSnapshot.hasData || !studentSnapshot.data!.exists) {
                              return const ListTile(
                                title: Text('Unknown Student'),
                              );
                            } else {
                              final studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                              final studentName = '${studentData['First_Name']} ${studentData['Last_Name']}';

                              //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Time: $time',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Status: $status',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: status == 'Accepted'
                                              ? Colors.green
                                              : status == 'Rejected'
                                              ? Colors.red
                                              : Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (status == 'Pending')
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => _updateAppointmentStatus(appointmentId, 'Accepted'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Accept'),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () => _updateAppointmentStatus(appointmentId, 'Rejected'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Reject'),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
              // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
            ),
          ],
        ),
      ),
    );
  }
}