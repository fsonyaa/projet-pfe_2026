import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class PerformancePage extends StatefulWidget {
  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  List performanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPerformance();
  }

  Future<void> fetchPerformance() async {
    try {
      // استعملي الـ Route الجديد اللي يحسب الـ Avis
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_performance_v2'));

      if (response.statusCode == 200) {
        setState(() {
          performanceData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Performance des Chauffeurs"),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: performanceData.length,
              itemBuilder: (context, index) {
                final p = performanceData[index];
                double rating = (p['Average_Note'] ?? 0.0).toDouble();
                int totalReviews = p['Total_Avis'] ?? 0;

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: Icon(Icons.person, size: 40, color: Colors.indigo),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['Nom_Chauffeur'] ?? "Inconnu",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 20),
                                  SizedBox(width: 5),
                                  Text(
                                    "${rating.toStringAsFixed(1)} / 5",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "($totalReviews avis)",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Bar de performance (Visual)
                              LinearProgressIndicator(
                                value: rating / 5,
                                backgroundColor: Colors.grey[200],
                                color: rating >= 4 ? Colors.green : (rating >= 2.5 ? Colors.orange : Colors.red),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}