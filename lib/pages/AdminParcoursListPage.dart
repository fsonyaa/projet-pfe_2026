import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'AdminAddParcoursPage.dart';

class AdminParcoursListPage extends StatefulWidget {
  @override
  _AdminParcoursListPageState createState() => _AdminParcoursListPageState();
}

class _AdminParcoursListPageState extends State<AdminParcoursListPage> {
  List parcoursList = [];
  List lignes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParcours();
    fetchLignes();
  }

  Future<void> fetchParcours() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_all_parcours'));
      if (response.statusCode == 200) {
        setState(() {
          parcoursList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Erreur fetch parcours: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLignes() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_lignes'));
      if (response.statusCode == 200) {
        setState(() {
          lignes = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Erreur fetch lignes: $e");
    }
  }

  Future<void> deleteParcours(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/delete_parcours/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Parcours supprimé ✅"), backgroundColor: Colors.green),
        );
        fetchParcours();
      }
    } catch (e) {
      print("Erreur delete: $e");
    }
  }

  void _showEditDialog(Map p) {
    TextEditingController departCtrl = TextEditingController(text: p['Depart']);
    TextEditingController arriveeCtrl = TextEditingController(text: p['Arrivee']);
    TextEditingController hDepartCtrl = TextEditingController(text: p['Heure_depart']);
    TextEditingController hArriveeCtrl = TextEditingController(text: p['Heure_arrivee']);
    String? selectedLigne = p['Code_Ligne'].toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Modifier le Parcours", style: TextStyle(color: Colors.teal[800])),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLigne,
                  decoration: InputDecoration(labelText: "Ligne"),
                  items: lignes.map((l) => DropdownMenuItem<String>(
                    value: l['Code_Ligne'].toString(),
                    child: Text(l['Libelle'] ?? "Ligne"),
                  )).toList(),
                  onChanged: (val) => setStateDialog(() => selectedLigne = val),
                ),
                TextField(controller: departCtrl, decoration: InputDecoration(labelText: "Départ")),
                TextField(controller: arriveeCtrl, decoration: InputDecoration(labelText: "Arrivée")),
                TextField(
                  controller: hDepartCtrl, 
                  decoration: InputDecoration(labelText: "Heure Départ (HH:mm)"),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      hDepartCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                TextField(
                  controller: hArriveeCtrl, 
                  decoration: InputDecoration(labelText: "Heure Arrivée (HH:mm)"),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      hArriveeCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('${ApiConfig.baseUrl}/update_parcours/${p['ID_parcours']}'),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "Depart": departCtrl.text,
                    "Arrivee": arriveeCtrl.text,
                    "Heure_depart": hDepartCtrl.text,
                    "Heure_arrivee": hArriveeCtrl.text,
                    "Code_Ligne": selectedLigne,
                  }),
                );
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  fetchParcours();
                }
              },
              child: Text("Enregistrer", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des Parcours"),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchParcours),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : parcoursList.isEmpty
              ? Center(child: Text("Aucun parcours programmé"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: parcoursList.length,
                  itemBuilder: (context, index) {
                    final p = parcoursList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[50],
                          child: Icon(Icons.route, color: Colors.teal),
                        ),
                        title: Text("${p['Depart']} ➔ ${p['Arrivee']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Ligne: ${p['Nom_Ligne']}\nHeure: ${p['Heure_depart']} - ${p['Heure_arrivee']}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(p),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Supprimer ?"),
                                    content: Text("Voulez-vous vraiment supprimer ce parcours ?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Non")),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteParcours(p['ID_parcours']);
                                        },
                                        child: Text("Oui", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddParcoursPage())).then((_) => fetchParcours());
        },
        backgroundColor: Colors.teal[700],
        child: Icon(Icons.add),
      ),
    );
  }
}
