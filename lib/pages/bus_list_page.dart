import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class BusListPage extends StatefulWidget {
  @override
  _BusListPageState createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  List busList = [];
  List chauffeursList = []; // لستة الشوافر
  bool isLoading = true;
  final String baseUrl = ApiConfig.baseUrl; // Utiliser l'URL centralisée

  @override
  void initState() {
    super.initState();
    getBuses();
    getChauffeurs(); // نعيطولهم الزوز مع بعضهم
  }

  // 1. جلب الكيران
  Future<void> getBuses() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_buses"));
      if (response.statusCode == 200) {
        setState(() {
          busList = json.decode(response.body) ?? [];
        });
      }
    } catch (e) {
      debugPrint("Erreur Fetch Buses: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 2. جلب الشوافر (هذي اللي كانت ناقصة ومطلعة الأحمر)
  Future<void> getChauffeurs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_chauffeurs"));
      if (response.statusCode == 200) {
        setState(() {
          chauffeursList = json.decode(response.body) ?? [];
        });
      }
    } catch (e) {
      debugPrint("Erreur Fetch Chauffeurs: $e");
    }
  }

  // 3. حذف كار
  Future<void> deleteBus(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete_bus/$id"));
      if (response.statusCode == 200) {
        getBuses();
      }
    } catch (e) {
      debugPrint("Erreur Delete: $e");
    }
  }

  // 4. نافذة الإضافة والتعديل المصلحة
  void _showBusDialog({Map? bus}) {
    TextEditingController numCtrl = TextEditingController(text: (bus?['Numero_bus'] ?? '').toString());
    TextEditingController etatCtrl = TextEditingController(text: (bus?['Etat'] ?? '').toString());
    
    // تأكدي إن الـ ID يتقرأ كـ int
    int? selectedChauffeurId = bus != null ? int.tryParse(bus['Code_chauffeur'].toString()) : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(bus == null ? "Ajouter un Bus" : "Modifier le Bus"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: numCtrl, decoration: InputDecoration(labelText: "Numéro du Bus")),
                TextField(controller: etatCtrl, decoration: InputDecoration(labelText: "Etat")),
                const SizedBox(height: 20),

                // Dropdown مصلح ومحمي من الـ Assertion Error
                chauffeursList.isEmpty
                    ? Text("⚠️ Aucun chauffeur. Ajoutez-en un d'abord!", style: TextStyle(color: Colors.red, fontSize: 12))
                    : DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: "Assigner à un Chauffeur", border: OutlineInputBorder()),
                        value: chauffeursList.any((c) => int.parse(c['Code_chauffeur'].toString()) == selectedChauffeurId) 
                               ? selectedChauffeurId 
                               : null,
                        items: chauffeursList.map((c) => DropdownMenuItem<int>(
                          value: int.parse(c['Code_chauffeur'].toString()),
                          child: Text(c['Nom'].toString()),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedChauffeurId = val),
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                var data = {
                  "Numero_bus": numCtrl.text,
                  "Etat": etatCtrl.text,
                  "Code_chauffeur": selectedChauffeurId,
                };
                final url = bus == null ? "$baseUrl/add_bus" : "$baseUrl/update_bus/${bus['Code_bus']}";
                final response = await (bus == null ? http.post : http.put)(
                  Uri.parse(url),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode(data),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  getBuses();
                }
              },
              child: Text(bus == null ? "Ajouter" : "Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion du Parc Bus"), backgroundColor: Colors.orange[800]),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : busList.isEmpty
              ? Center(child: Text("Aucun bus trouvé"))
              : ListView.builder(
                  itemCount: busList.length,
                  itemBuilder: (context, index) {
                    final bus = busList[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(Icons.directions_bus, color: Colors.orange),
                        title: Text("Bus N°: ${bus['Numero_bus']}"),
                        // عوضي السطر القديم بهذا:
                        // لازم تكون مكتوبة بالظبط هكا (C كبيرة و C كبيرة)
                        subtitle: Text("Etat: ${bus['Etat']} | ID Chauffeur: ${bus['Code_chauffeur'] ?? 'Pas d\'ID'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showBusDialog(bus: bus)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteBus(bus['Code_bus'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBusDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[800],
      ),
    );
  }
}