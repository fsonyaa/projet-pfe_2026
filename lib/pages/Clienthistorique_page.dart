import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class HistoriquePage extends StatefulWidget {
  final int clientId; // 👈 هنا

  const HistoriquePage({
    Key? key,
    required this.clientId, // 👈 مهم
  }) : super(key: key);

  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List avis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvis();
  }

  // =======================
  // GET AVIS
  // =======================
  Future<void> fetchAvis() async {
    final url = "${ApiConfig.baseUrl}/get_avis_by_client/${widget.clientId}";


    try {
      final res = await http.get(Uri.parse(url));

      print(res.body); // debug

      if (res.statusCode == 200) {
        setState(() {
          avis = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  // =======================
  // DELETE AVIS
  // =======================
  Future<void> deleteAvis(int id) async {
    final url = "${ApiConfig.baseUrl}/delete_avis/$id";


    await http.delete(Uri.parse(url));

    fetchAvis(); // refresh
  }

  // =======================
  // UPDATE AVIS
  // =======================
  void showEditDialog(Map avisItem) {
    TextEditingController ctrl =
        TextEditingController(text: avisItem['Commentaire'] ?? "");
    int rating = avisItem['Note'] ?? 3;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Modifier avis"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // commentaire
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 15),

                // rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: i < rating ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          rating = i + 1;
                        });
                      },
                    );
                  }),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler"),
              ),

              ElevatedButton(
                onPressed: () async {
                  final url = "${ApiConfig.baseUrl}/update_avis/${avisItem['ID_avis']}";


                  await http.put(
                    Uri.parse(url),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "commentaire": ctrl.text,
                      "note": rating,
                    }),
                  );

                  Navigator.pop(context);
                  fetchAvis();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text("Modifier"),
              ),
            ],
          );
        },
      ),
    );
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique des avis"),
        backgroundColor: Colors.teal,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())

          : avis.isEmpty
              ? Center(
                  child: Text(
                    "Aucun avis",
                    style: TextStyle(color: Colors.grey),
                  ),
                )

              : ListView.builder(
                  itemCount: avis.length,
                  itemBuilder: (context, index) {
                    final a = avis[index];

                    return Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),

                        // parcours
                        title: Text(
                          "${a['Depart']} ➜ ${a['Arrivee']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        // commentaire
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(a['Commentaire'] ?? ""),
                            SizedBox(height: 5),

                            // stars display
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  Icons.star,
                                  size: 18,
                                  color: i < (a['Note'] ?? 0)
                                      ? Colors.orange
                                      : Colors.grey,
                                );
                              }),
                            ),
                          ],
                        ),

                        // actions
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // edit
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () {
                                showEditDialog(a);
                              },
                            ),

                            // delete
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                deleteAvis(a['ID_avis']);
                              },
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