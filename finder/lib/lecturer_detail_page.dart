import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'student_chat_screen.dart';

class LecturerDetailPage extends StatefulWidget {
  final Map<String, dynamic> lecturer;
  final String studentUid;

  LecturerDetailPage({required this.lecturer, required this.studentUid});

  @override
  _LecturerDetailPageState createState() => _LecturerDetailPageState();
}

class _LecturerDetailPageState extends State<LecturerDetailPage> {
  String availabilityStatus = "Loading...";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePickers = false; // Controls visibility of date/time pickers

  @override
  void initState() {
    super.initState();
    _fetchLecturerAvailability();
  }

  Future<void> _fetchLecturerAvailability() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('Lecturer')
          .doc(widget.lecturer['uid'])
          .get();

      if (lecturerDoc.exists && lecturerDoc['status'] != null) {
        setState(() {
          availabilityStatus = lecturerDoc['status'] == 'Inside Cabin'
              ? 'Available in Cabin'
              : 'Outside Cabin';
        });
      } else {
        setState(() {
          availabilityStatus = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching lecturer availability: $e");
      setState(() {
        availabilityStatus = 'Error fetching status';
      });
    }
  }

  // Function to book an appointment
  Future<void> _bookAppointment(BuildContext context) async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Appointments').add({
        'lecturerUid': widget.lecturer['uid'],
        'studentUid': widget.studentUid,
        'date': Timestamp.fromDate(selectedDate!),
        'time': '${selectedTime!.hour}:${selectedTime!.minute}',
        'status': 'Pending', // Initial status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );

      // Reset the state after booking
      setState(() {
        selectedDate = null;
        selectedTime = null;
        showDateTimePickers = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to select a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE7DA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEE7DA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lecturer Details",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Larger Lecturer Image
            Container(
              width: 150, // Increased size
              height: 150, // Increased size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black87,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: widget.lecturer['Image'] != null
                    ? Image.network(
                  widget.lecturer['Image'],
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.grey[600],
                    );
                  },
                )
                    : Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${widget.lecturer['L_First_Name']} ${widget.lecturer['L_Last_Name']}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.lecturer['Job_Role'] ?? "Unknown role",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(widget.lecturer['Email'] ?? "No email available"),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(widget.lecturer['Contact No'] ?? "No contact available"),
            ),
            ListTile(
              leading: const Icon(Icons.business, color: Colors.orange),
              title: Text(widget.lecturer['Faculty_Name'] ?? "No faculty info"),
            ),
            const SizedBox(height: 20),
            // Availability Status Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: availabilityStatus.contains('Available')
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: availabilityStatus.contains('Available')
                      ? Colors.green
                      : Colors.red,
                  width: 2,
                ),
              ),
              child: Text(
                'Availability: $availabilityStatus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: availabilityStatus.contains('Available')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Book Appointment Button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showDateTimePickers = true; // Show date/time pickers
                });
              },
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text("Book Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            if (showDateTimePickers) ...[
              const SizedBox(height: 20),
              // Date Picker
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                ),
              ),
              const SizedBox(height: 10),
              // Time Picker
              ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  selectedTime == null
                      ? 'Select Time'
                      : 'Time: ${selectedTime!.format(context)}',
                ),
              ),
              const SizedBox(height: 20),
              // Confirm Button
              ElevatedButton.icon(
                onPressed: () => _bookAppointment(context),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Confirm Appointment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Chat Button
            ElevatedButton.icon(
              onPressed: () {
                if (widget.lecturer.containsKey('uid')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentChatScreen(
                        lecturerId: widget.lecturer['uid'],
                        studentUid: widget.studentUid,
                        lecturerFirstName: widget.lecturer['L_First_Name'] ?? '',
                        lecturerLastName: widget.lecturer['L_Last_Name'] ?? '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lecturer details are missing!")),
                  );
                }
              },
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text("Chat with Lecturer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 40),
            // Sent Appointments Section
            const Text(
              "Sent Appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Appointments')
                  .where('studentUid', isEqualTo: widget.studentUid)
                  .where('lecturerUid', isEqualTo: widget.lecturer['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No sent appointments.'));
                } else {
                  final appointments = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index].data() as Map<String, dynamic>;
                      final date = (appointment['date'] as Timestamp).toDate();
                      final time = appointment['time'];
                      final status = appointment['status'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lecturer: ${widget.lecturer['L_First_Name']} ${widget.lecturer['L_Last_Name']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Time: $time',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: status == 'Accepted'
                                      ? Colors.green
                                      : status == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}