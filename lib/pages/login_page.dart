import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'current_user.dart';
import 'clientdashboard.dart';
import 'chauffeurdashboard.dart';
import 'admin_dashboard.dart';
import '../api_config.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    // Utiliser l'URL centralisée de ApiConfig
    String apiUrl = "${ApiConfig.baseUrl}/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim().toLowerCase(),
          "password": passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ SAVE SESSION
        String nom = data["nom"] ?? "Utilisateur";
        String photo = data["photo"] ?? "";
        await CurrentUser.saveSession(data["email"], data["role"], data["id"] ?? 1, userNom: nom, userPhoto: photo);
        int userId = CurrentUser.id;

        _showSnackBar("Bienvenue $nom (${CurrentUser.role})", Colors.green);

        // ✅ REDIRECT
        if (CurrentUser.role == "client") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ClientDashboard(clientId: userId, userEmail: CurrentUser.email),
            ),
          );
        } else if (CurrentUser.role == "chauffeur") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChauffeurDashboard(driverId: userId, userEmail: CurrentUser.email),
            ),
          );
        } else if (CurrentUser.role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(adminEmail: CurrentUser.email),
            ),
          );
        }
      } else {
        _showSnackBar(data['message'] ?? "Identifiants incorrects", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Erreur: Impossible de contacter le serveur", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_bus, size: 90, color: Colors.teal),
                const SizedBox(height: 10),
                const Text(
                  "SMART-TRANS",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 2.0,
                  ),
                ),
                const Text("Cyber Security Edition 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Se connecter", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                  child: const Text("Mot de passe oublié ?", style: TextStyle(color: Colors.teal)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Pas de compte ? Créer un compte", style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}