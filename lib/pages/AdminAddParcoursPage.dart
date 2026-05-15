import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

import 'package:intl/intl.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminAddParcoursPage extends StatefulWidget {
  @override
  _AdminAddParcoursPageState createState() => _AdminAddParcoursPageState();
}

class _AdminAddParcoursPageState extends State<AdminAddParcoursPage> {
  List lignes = []; 
  String? selectedLigne; 
  
  TextEditingController departController = TextEditingController();
  TextEditingController arriveeController = TextEditingController();

  // قائمة الـ 6 خانات للأوقات
  List<TextEditingController> heureControllers = 
      List.generate(6, (index) => TextEditingController());

  bool isLoadingLignes = true;
  
  // Map Variables
  LatLng? departCoord;
  LatLng? arriveeCoord;
  String pickingMode = 'depart'; // 'depart' ou 'arrivee'
  final MapController mapController = MapController();
  final LatLng tunisCenter = LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    fetchLignes();
  }

  // دالة تزيد ساعة بنظام 24 ساعة (ترجع 13:00 في عوض 01:00 PM)
  String addOneHour24h(String startTime) {
    try {
      // نخدموا بنظام 24 ساعة (HH:mm)
      DateFormat format24 = DateFormat("HH:mm"); 
      DateTime dateTime = format24.parse(startTime.trim());
      DateTime arrivalTime = dateTime.add(Duration(hours: 1)); 
      
      return format24.format(arrivalTime); 
    } catch (e) {
      return startTime; 
    }
  }

  Future<void> fetchLignes() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/get_lignes'));

      if (response.statusCode == 200) {
        setState(() {
          lignes = json.decode(response.body);
          isLoadingLignes = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingLignes = false);
    }
  }

  Future<void> saveParcours() async {
    if (selectedLigne == null || departController.text.isEmpty || arriveeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    if (departController.text.trim().toLowerCase() == arriveeController.text.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le départ et l'arrivée doivent être différents ❌"), backgroundColor: Colors.orange),
      );
      return;
    }

    int count = 0;
    for (int i = 0; i < heureControllers.length; i++) {
      if (heureControllers[i].text.isNotEmpty) {
        String arrivalTime;

        // إذا فمة سفرة بعدها خوذ وقتها، وإلا زيد ساعة بنظام 24 ساعة
        if (i < heureControllers.length - 1 && heureControllers[i + 1].text.isNotEmpty) {
          arrivalTime = heureControllers[i + 1].text;
        } else {
          arrivalTime = addOneHour24h(heureControllers[i].text);
        }

        // منطق التناوب: الزوجي (0, 2, 4) هو ذهاب، الفردي (1, 3, 5) هو إياب
        String currentDepart = (i % 2 == 0) ? departController.text : arriveeController.text;
        String currentArrivee = (i % 2 == 0) ? arriveeController.text : departController.text;

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/add_parcours'),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "Depart": currentDepart,
            "Arrivee": currentArrivee,
            "Heure_depart": heureControllers[i].text,
            "Heure_arrivee": arrivalTime, 
            "Code_Ligne": selectedLigne,
            "Etat": 0,
          }),
        );
        if (response.statusCode == 201) count++;
      }
    }

    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$count Trajets enregistrés (Aller/Retour) ✅"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Programmation des Parcours", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[700],
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Informations de la Ligne"),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      isLoadingLignes 
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            value: selectedLigne,
                            decoration: InputDecoration(
                              labelText: "Choisir une Ligne",
                              prefixIcon: Icon(Icons.route, color: Colors.teal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: lignes.map((l) => DropdownMenuItem<String>(
                              value: l['Code_Ligne'].toString(),
                              child: Text(l['Libelle'] ?? "Ligne"),
                            )).toList(),
                            onChanged: (val) => setState(() => selectedLigne = val),
                          ),
                      SizedBox(height: 15),
                      _buildTextField(departController, "Point de Départ", Icons.location_on, isDepart: true),
                      SizedBox(height: 15),
                      _buildTextField(arriveeController, "Point d'Arrivée", Icons.flag, isDepart: false),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              _buildSectionTitle("Choisir sur la Carte (Tunis)"),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: Text("Départ"),
                            selected: pickingMode == 'depart',
                            onSelected: (val) => setState(() => pickingMode = 'depart'),
                            selectedColor: Colors.teal.withOpacity(0.3),
                          ),
                          ChoiceChip(
                            label: Text("Arrivée"),
                            selected: pickingMode == 'arrivee',
                            onSelected: (val) => setState(() => pickingMode = 'arrivee'),
                            selectedColor: Colors.red.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: tunisCenter,
                            initialZoom: 13.0,
                            onTap: (tapPosition, point) {
                              setState(() {
                                if (pickingMode == 'depart') {
                                  departCoord = point;
                                  departController.text = "Chargement...";
                                  _getAddressFromLatLng(point, true);
                                } else {
                                  arriveeCoord = point;
                                  arriveeController.text = "Chargement...";
                                  _getAddressFromLatLng(point, false);
                                }
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                if (departCoord != null)
                                  Marker(
                                    point: departCoord!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_on, color: Colors.teal, size: 40),
                                  ),
                                if (arriveeCoord != null)
                                  Marker(
                                    point: arriveeCoord!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.flag, color: Colors.red, size: 40),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (departCoord != null || arriveeCoord != null)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          departCoord = null;
                          arriveeCoord = null;
                          departController.clear();
                          arriveeController.clear();
                        }),
                        icon: Icon(Icons.refresh, size: 16, color: Colors.grey),
                        label: Text("Réinitialiser les points", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 25),
              _buildSectionTitle("Horaires (Format 24h)"),
              
              Container(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 4, 
                  children: List.generate(6, (index) => _buildTimeField(index)),
                ),
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveParcours,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("ENREGISTRER LE PLANNING", 
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal[900])),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool? isDepart}) {
    return TextField(
      controller: controller,
      readOnly: isDepart != null, // Make it read-only if picking from map to prevent manual mess
      onTap: isDepart != null ? () {
        setState(() {
          pickingMode = isDepart ? 'depart' : 'arrivee';
        });
      } : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDepart == null ? Colors.teal : (isDepart ? Colors.teal : Colors.red)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isDepart != null ? Icon(Icons.map, color: Colors.grey) : null,
        helperText: isDepart != null ? "Appuyez pour choisir sur la carte" : null,
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng point, bool isDepart) async {
    try {
      // Using Nominatim (Free OSM Geocoding)
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18'),
        headers: {'User-Agent': 'SmartTransApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address = data['display_name'] ?? "";
        
        // Extract a shorter version (e.g., Street and Neighborhood)
        List<String> parts = address.split(',');
        if (parts.length >= 2) {
          address = "${parts[0].trim()}, ${parts[1].trim()}";
        }

        setState(() {
          if (isDepart) {
            departController.text = address;
          } else {
            arriveeController.text = address;
          }
        });
      } else {
        // Fallback to coordinates
        setState(() {
          String coords = "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
          if (isDepart) departController.text = coords;
          else arriveeController.text = coords;
        });
      }
    } catch (e) {
      setState(() {
        String coords = "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
        if (isDepart) departController.text = coords;
        else arriveeController.text = coords;
      });
    }
  }

  Widget _buildTimeField(int index) {
    return TextField(
      controller: heureControllers[index],
      readOnly: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: "Sprint ${index + 1}",
        prefixIcon: Icon(Icons.access_time, size: 18, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context, 
          initialTime: TimeOfDay.now(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // إجبار نظام 24 ساعة
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            // تخزين الوقت بتنسيق HH:mm (مثلاً 13:00)
            heureControllers[index].text = 
                picked.hour.toString().padLeft(2, '0') + ":" + 
                picked.minute.toString().padLeft(2, '0');
          });
        }
      },
    );
  }
}