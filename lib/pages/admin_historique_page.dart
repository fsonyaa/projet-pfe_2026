import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class AdminHistoriquePage extends StatefulWidget {
  @override
  _AdminHistoriquePageState createState() => _AdminHistoriquePageState();
}

class _AdminHistoriquePageState extends State<AdminHistoriquePage> {
  List historique = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorique();
  }

  Future<void> fetchHistorique() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_all_historique'));
      if (response.statusCode == 200) {
        setState(() {
          historique = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Historique des Trajets", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[700],
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchHistorique),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : historique.isEmpty
              ? Center(child: Text("Aucun historique disponible", style: TextStyle(color: Colors.grey[600], fontSize: 16)))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: historique.length,
                  itemBuilder: (context, index) {
                    final h = historique[index];
                    return _buildHistoriqueCard(h);
                  },
                ),
    );
  }

  Widget _buildHistoriqueCard(Map h) {
    String statut = h['Statut'] ?? 'Inconnu';
    Color statusColor = Colors.grey;
    if (statut == 'Terminé') statusColor = Colors.green;
    if (statut == 'En cours') statusColor = Colors.blue;
    if (statut == 'Annulé') statusColor = Colors.red;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.teal[700]),
                    SizedBox(width: 5),
                    Text(h['Date'] ?? "---", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[900])),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statut,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Divider(height: 25),
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.orange, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ligne: ${h['Nom_Ligne'] ?? 'Non spécifiée'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Chauffeur: ${h['Nom_Chauffeur'] ?? 'Inconnu'}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                _buildLocationPoint(h['Depart'] ?? "---", Icons.radio_button_checked, Colors.green),
                Expanded(child: Container(height: 1, color: Colors.grey[300], margin: EdgeInsets.symmetric(horizontal: 10))),
                _buildLocationPoint(h['Arrivee'] ?? "---", Icons.location_on, Colors.red),
              ],
            ),
            if (h['Performance_IA'] != null) ...[
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.purple, size: 18),
                  SizedBox(width: 5),
                  Text("Score IA: ", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  Text("${h['Performance_IA']}%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPoint(String name, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
