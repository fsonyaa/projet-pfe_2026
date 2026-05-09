import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';


class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      // ثبتي إن السيرفر بايثون يخدم على بورت 8000
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/get_my_reviews/1"));

      if (response.statusCode == 200) {
        setState(() {
          reviews = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Notes & Avis"), 
        backgroundColor: Colors.teal
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : reviews.isEmpty 
          ? Center(child: Text("Aucun avis trouvé"))
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStars(review['note'] ?? 0),
                            _buildSentimentBadge(review['sentiment'] ?? "Neutre"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          review['commentaire'] ?? "",
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        Divider(),
                        Text(
                          "Date: ${review['date'] ?? 'Récent'}", 
                          style: TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget لرسم النجوم
  Widget _buildStars(int note) {
    return Row(
      children: List.generate(5, (i) => Icon(
        Icons.star, 
        color: i < note ? Colors.amber : Colors.grey[300], 
        size: 20
      )),
    );
  }

  // Widget لخانة الـ IA (Sentiment)
  Widget _buildSentimentBadge(String sentiment) {
    Color col = sentiment == "Positif" ? Colors.green : (sentiment == "Négatif" ? Colors.red : Colors.blueGrey);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: col)
      ),
      child: Text(
        sentiment, 
        style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)
      ),
    );
  }
}