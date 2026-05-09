import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class AvisAdminPage extends StatefulWidget {
  @override
  _AvisAdminPageState createState() => _AvisAdminPageState();
}

class _AvisAdminPageState extends State<AvisAdminPage> {
  List avisList = [];
  bool isLoading = true;
  // Utiliser l'URL centralisée
  final String baseUrl = ApiConfig.baseUrl; 

  @override
  void initState() {
    super.initState();
    fetchAvis();
  }

  Future<void> fetchAvis() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_avis'));
      if (response.statusCode == 200) {
        setState(() {
          avisList = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur Fetch: $e");
      setState(() => isLoading = false);
    }
  }

  // --- التعديل هوني: نبعثو الزوز مفاتيح ---
  Future<void> deleteAvis(int idAvis) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete_avis/$idAvis')
      );
      
      if (response.statusCode == 200) {
        fetchAvis(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Avis supprimé"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Erreur Delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyse des Avis AI", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[700],
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.refresh, color: Colors.white), onPressed: fetchAvis)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.purple))
          : avisList.isEmpty
              ? Center(child: Text("Aucun avis trouvé", style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: avisList.length,
                  itemBuilder: (context, index) {
                    final item = avisList[index];
                    String sentiment = item['Sentiment_label'] ?? "Neutre";
                    String keywords = item['Keywords'] ?? "";
                    
                    Color sentimentColor = sentiment == "Positif" ? Colors.green 
                                        : (sentiment == "Négatif" ? Colors.red : Colors.orange);
                    
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: sentimentColor.withOpacity(0.1),
                          child: Icon(
                            sentiment == "Positif" ? Icons.sentiment_very_satisfied 
                            : (sentiment == "Négatif" ? Icons.sentiment_very_dissatisfied : Icons.sentiment_neutral),
                            color: sentimentColor,
                          ),
                        ),
                        title: Text(item['Commentaire'] ?? "...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: sentimentColor, borderRadius: BorderRadius.circular(8)),
                                  child: Text(sentiment, style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                SizedBox(width: 8),
                                if (item['Category'] != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.indigo[100], borderRadius: BorderRadius.circular(8)),
                                    child: Text(item['Category'], style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                SizedBox(width: 10),
                                Text("⭐ ${item['Note']}/5", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 10),
                                Text("👤 ${item['Nom_Client'] ?? 'Inconnu'}", style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            if (keywords.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text("IA Mots-clés: $keywords", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.indigo)),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                          onPressed: () {
                            deleteAvis(item['ID_avis']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}