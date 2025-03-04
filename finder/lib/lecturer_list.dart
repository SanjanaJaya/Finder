import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecturer_detail_page.dart';

class LecturerListPage extends StatefulWidget {
  @override
  _LecturerListPageState createState() => _LecturerListPageState();
}

class _LecturerListPageState extends State<LecturerListPage> {
  List<Map<String, dynamic>> lecturers = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchLecturers();
  }

  Future<void> fetchLecturers() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('Lecturer').get();

      setState(() {
        lecturers = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false;
        errorMessage = "";
      });
    } catch (e) {
      print("Error fetching lecturers: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Error loading lecturer data: $e";
      });
    }
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
                  : ListView.builder(
                itemCount: lecturers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ListTile(
                      title: Text(
                        "${lecturers[index]['L_First_Name']} ${lecturers[index]['L_Last_Name']}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      tileColor: Color(0xFFAECBAD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LecturerDetailPage(lecturer: lecturers[index]),
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
