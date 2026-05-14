import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int step = 1; // 1: Email, 2: Code, 3: New Password
  bool isLoading = false;

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> sendCode() async {
    if (emailController.text.isEmpty) {
      _showSnackBar("Veuillez entrer votre email", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim().toLowerCase()}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar("Code envoyé !", Colors.green);
        setState(() => step = 2);
      } else {
        _showSnackBar(data['error'] ?? "Erreur", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Erreur de connexion", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyCode() async {
    if (codeController.text.length != 6) {
      _showSnackBar("Le code doit contenir 6 chiffres", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/verify-reset-code"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim().toLowerCase(),
          "code": codeController.text.trim()
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => step = 3);
      } else {
        _showSnackBar(data['error'] ?? "Code incorrect", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Erreur de connexion", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (passwordController.text.length < 6) {
      _showSnackBar("Le mot de passe doit contenir au moins 6 caractères", Colors.orange);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Les mots de passe ne correspondent pas", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim().toLowerCase(),
          "code": codeController.text.trim(),
          "new_password": passwordController.text.trim()
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar("Mot de passe réinitialisé !", Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackBar(data['error'] ?? "Erreur", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Erreur de connexion", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réinitialisation"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            if (step == 1) _buildEmailStep(),
            if (step == 2) _buildCodeStep(),
            if (step == 3) _buildPasswordStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        const Text("Entrez votre email pour recevoir un code de vérification", textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: "Email",
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Envoyer le code", style: TextStyle(color: Colors.white)),
              ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      children: [
        Text("Code envoyé à ${emailController.text}", textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: "Code de vérification (6 chiffres)",
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Vérifier le code", style: TextStyle(color: Colors.white)),
              ),
        TextButton(onPressed: () => setState(() => step = 1), child: const Text("Changer l'email"))
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        const Text("Définissez votre nouveau mot de passe", textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "Nouveau mot de passe",
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 15),
        TextField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: "Confirmer le mot de passe",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Changer le mot de passe", style: TextStyle(color: Colors.white)),
              ),
      ],
    );
  }
}
