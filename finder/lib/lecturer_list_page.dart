import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecturer_detail_page.dart';

class LecturerListPage extends StatefulWidget {
  final String studentUid; // Pass the logged-in student UID

  LecturerListPage({required this.studentUid});

  @override
  _LecturerListPageState createState() => _LecturerListPageState();
}

class _LecturerListPageState extends State<LecturerListPage> {
  List<Map<String, dynamic>> lecturers = [];
  List<Map<String, dynamic>> filteredLecturers = []; // For filtered results
  bool isLoading = true;
  String errorMessage = "";
  TextEditingController searchController = TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    fetchLecturers();
  }

  Future<void> fetchLecturers() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
      await firestore.collection('Lecturer').get();

      setState(() {
        lecturers =
            querySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
        filteredLecturers = List.from(lecturers); // Initialize filtered list
        isLoading = false;
        errorMessage = "";
      });
      // Developed By,
// Imesh Sanjana - 30137 - 10953245
// Gaveen Ranasinghe - 29934 - 10952369
// Sehara Gishan - 26041 - 10953243
    } catch (e) {
      print("Error fetching lecturers: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Error loading lecturer data: $e";
      });
    }
  }

  // Function to filter lecturers based on search query
  void filterLecturers(String query) {
    setState(() {
      filteredLecturers = lecturers
          .where((lecturer) =>
      lecturer['L_First_Name']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          lecturer['L_Last_Name']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEE7DA),
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
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Your Lecturer",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                ),
                onChanged: (value) {
                  filterLecturers(value); // Filter lecturers as user types
                },
              ),
            ),
            //Developed By,
//Nethsara Weerasooriya - 29733 - 10953304
//Dinuwara Wijerathne - 30406 - 10953246
//Dihansie Weerasinghe - 30223 - 10952372
//Chaga Kodikara - 30296 - 10952374
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              )
                  : filteredLecturers.isEmpty
                  ? Center(
                child: Text(
                  "No lecturers found.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredLecturers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ListTile(
                      title: Text(
                        "${filteredLecturers[index]['L_First_Name']} ${filteredLecturers[index]['L_Last_Name']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tileColor: Color(0xFFAECBAD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LecturerDetailPage(
                              lecturer: filteredLecturers[index],
                              studentUid: widget.studentUid, // Pass Student UID
                            ),
                          ),
                        );
                      },
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