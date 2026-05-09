import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../api_config.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  /// ✅ API dynamique utilisant ApiConfig
  String get apiUrl => "${ApiConfig.baseUrl}/register";

  Future<void> register() async {

    if (nomController.text.isEmpty ||
        emailController.text.isEmpty ||
        passController.text.isEmpty) {

      _showMsg("Veuillez remplir tous les champs", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nomController.text.trim(),
          "email": emailController.text.trim(),
          "password": passController.text,
          "role": "client", // ✅ corrigé
        }),
      );

      if (response.statusCode == 201) {

        _showMsg("Compte créé avec succès ✅", Colors.green);

        await Future.delayed(const Duration(seconds: 1));

        Navigator.pop(context); // retour login
      }
      else {
        final error =
            jsonDecode(response.body)['error'] ?? "Erreur";
        _showMsg(error, Colors.red);
      }

    } catch (e) {
      print(e);
      _showMsg("Impossible de contacter le serveur", Colors.red);
    }

    setState(() => isLoading = false);
  }

  void _showMsg(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: col,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte"),
        backgroundColor: Colors.teal,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              TextField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 30),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize:
                            const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "S'inscrire",
                        style:
                            TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}