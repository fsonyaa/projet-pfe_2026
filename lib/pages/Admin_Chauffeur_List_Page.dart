import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';


class AdminChauffeurListPage extends StatefulWidget {
  @override
  _AdminChauffeurListPageState createState() => _AdminChauffeurListPageState();
}

class _AdminChauffeurListPageState extends State<AdminChauffeurListPage> {
  List allChauffeurs = [];
  List filteredChauffeurs = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  // Controllers للـ Formulaire
  TextEditingController nomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchChauffeurs();
  }

  // 1. جلب البيانات من السيرفر
  Future<void> fetchChauffeurs() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_chauffeurs'));

      if (response.statusCode == 200) {
        setState(() {
          allChauffeurs = json.decode(response.body);
          filteredChauffeurs = allChauffeurs;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur fetch: $e");
    }
  }

  // 2. دالة الإضافة (Ajouter)
  Future<void> addChauffeur() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/add_chauffeur'),

      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Nom": nomController.text,
        "Email": emailController.text,
        "Password": passwordController.text,
      }),
    );
    if (response.statusCode == 201) {
      Navigator.pop(context);
      fetchChauffeurs();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chauffeur ajouté ✅")));
    }
  }

  // 3. دالة التعديل (Modifier) - تشمل الـ Password والـ Email
  Future<void> updateChauffeur(int userId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/update_chauffeur/$userId'),

      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Nom": nomController.text,
        "Email": emailController.text,
        "Password": passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
      fetchChauffeurs();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mis à jour réussi ✅")));
    }
  }

  // 4. دالة الحذف (Supprimer)
  Future<void> deleteChauffeur(int userId) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/delete_chauffeur/$userId'));

    if (response.statusCode == 200) {
      fetchChauffeurs();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chauffeur supprimé ✅")));
    }
  }

  // 🖼️ واجهة الإضافة والتعديل
  void showFormDialog({Map? chauffeur}) {
    if (chauffeur != null) {
      nomController.text = chauffeur['Nom'] ?? "";
      emailController.text = chauffeur['Email'] ?? "";
      passwordController.clear(); // المودباس نكتبوه جديد لو حاشتنا
    } else {
      nomController.clear();
      emailController.clear();
      passwordController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chauffeur == null ? "Ajouter Chauffeur" : "Modifier Chauffeur"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomController, decoration: InputDecoration(labelText: "Nom")),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              TextField(
                controller: passwordController, 
                decoration: InputDecoration(labelText: "Mot de passe"), 
                obscureText: true
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (chauffeur == null) {
                addChauffeur();
              } else {
                updateChauffeur(chauffeur['ID_utilisateur']);
              }
            },
            child: Text("Valider"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Chauffeurs"), backgroundColor: Colors.teal),
      body: Column(
        children: [
          // 🔍 خانة البحث
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: (v) => setState(() {
                filteredChauffeurs = allChauffeurs.where((c) => c['Nom'].toString().toLowerCase().contains(v.toLowerCase())).toList();
              }),
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          
          // 📊 قائمة الشوفورات
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredChauffeurs.isEmpty
                    ? Center(child: Text("Aucun chauffeur trouvé"))
                    : ListView.builder(
                        itemCount: filteredChauffeurs.length,
                        itemBuilder: (context, index) {
                          final c = filteredChauffeurs[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person), backgroundColor: Colors.teal),
                              title: Text(c['Nom'] ?? ""),
                              subtitle: Text(c['Email'] ?? "Pas d'email"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue), 
                                    onPressed: () => showFormDialog(chauffeur: c)
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red), 
                                    onPressed: () => deleteChauffeur(c['ID_utilisateur'])
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      
      // ➕ بوطون الإضافة
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFormDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}