import 'package:flutter/material.dart';

class LecturerListPage extends StatefulWidget {
  @override
  _LecturerListPageState createState() => _LecturerListPageState();
}

class _LecturerListPageState extends State<LecturerListPage> {
  final List<String> lecturers = [
    "Prof. Chaminda Rathnayake",
    "Prof. Baratha Dodankotuwa",
    "Prof. Shanthi Segarajasingham",
    "Prof. Noel Fernando",
    "Prof. Dushar Dayarathna",
    "Prof. Chaminda Wijesinghe",
    "Ms. Thilini De Silva",
    "Dr. Chandana Perera",
    "Prof. Chaminda Wijesinghe",
    "Dr. Rasika Ranaweera",
    "Dr. Mohamed Shafraz"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEE7DA), // Background color
      appBar: AppBar(
        backgroundColor: Color(0xFFEEE7DA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Your Lecturer",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Lecturer List
            Expanded(
              child: ListView.builder(
                itemCount: lecturers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFFAECBAD), // Greenish button color
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        lecturers[index],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
