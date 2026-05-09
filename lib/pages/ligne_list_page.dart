import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class LigneListPage extends StatefulWidget {
  @override
  _LigneListPageState createState() => _LigneListPageState();
}

class _LigneListPageState extends State<LigneListPage> {
  List lignesList = [];
  List busesList = [];
  bool isLoading = true;

  // Utiliser l'URL centralisée
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    getLignes();
    getBuses();
  }

  // 1. جلب الخطوط مع اسم الشوفير (اللي يجي مالـ Flask عبر JOIN)
  Future<void> getLignes() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_all_lignes"));
      if (response.statusCode == 200) {
        setState(() {
          lignesList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Erreur lignes: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 2. جلب قائمة الحافلات للـ Dropdown
  Future<void> getBuses() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_buses"));
      if (response.statusCode == 200) {
        setState(() {
          busesList = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Erreur buses: $e");
    }
  }

  // 3. حذف خط
  Future<void> deleteLigne(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete_ligne/$id"));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ligne supprimée")));
        getLignes();
      }
    } catch (e) {
      print(e);
    }
  }

  // 4. الـ Dialog مصلح (فيه كان 3 خانات)
  void _showLigneDialog({Map? ligne}) {
    TextEditingController libelleCtrl = TextEditingController(text: ligne?['libelle'] ?? '');
    TextEditingController descCtrl = TextEditingController(text: ligne?['description'] ?? '');
    int? selectedBusId = ligne?['code_bus'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(ligne == null ? "Ajouter Ligne" : "Modifier Ligne"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: libelleCtrl,
                    decoration: InputDecoration(labelText: "Libelle (Nom)"),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(labelText: "Description"),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedBusId,
                    hint: Text("Choisir Bus"),
                    items: busesList.map<DropdownMenuItem<int>>((bus) {
                      return DropdownMenuItem<int>(
                        value: bus['Code_bus'],
                        child: Text("Bus N° ${bus['Code_bus']}"),
                      );
                    }).toList(),
                    onChanged: (value) => setStateDialog(() => selectedBusId = value),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
                ElevatedButton(
                  onPressed: () async {
                    if (libelleCtrl.text.isEmpty || selectedBusId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Champs obligatoires !")));
                      return;
                    }

                    var data = {
                      "libelle": libelleCtrl.text,
                      "description": descCtrl.text,
                      "code_bus": selectedBusId,
                    };

                    final url = ligne == null 
                        ? "$baseUrl/add_ligne" 
                        : "$baseUrl/update_ligne/${ligne['code_ligne']}";

                    if (ligne == null) {
                      await http.post(
                        Uri.parse(url),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );
                    } else {
                      await http.put(
                        Uri.parse(url),
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );
                    }

                    Navigator.pop(context);
                    getLignes();
                  },
                  child: Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des Lignes"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: lignesList.length,
              itemBuilder: (context, index) {
                final item = lignesList[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.directions_bus, color: Colors.green),
                    title: Text(item['libelle'] ?? 'Sans Nom', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${item['description'] ?? ''}"),
                        Text("Bus: ${item['code_bus'] ?? 'N/A'}", style: TextStyle(color: Colors.blueGrey)),
                        // هوني يظهر الشوفير المربوط بالكار تلقائياً
                        Text(
                          "Chauffeur: ${item['nom_chauffeur'] ?? 'Non assigné'}",
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showLigneDialog(ligne: item)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteLigne(item['code_ligne'])),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLigneDialog(),
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}