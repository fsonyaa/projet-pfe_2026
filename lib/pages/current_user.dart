import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser {
  static String email = "";
  static String role = "";
  static String nom = "";
  static String photo = ""; // Base64 or URL
  static int id = 0;

  static Future<void> saveSession(String userEmail, String userRole, int userId, {String userNom = "", String userPhoto = ""}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', userEmail);
    await prefs.setString('role', userRole);
    await prefs.setInt('id', userId);
    await prefs.setString('nom', userNom);
    await prefs.setString('photo', userPhoto);
    
    email = userEmail;
    role = userRole;
    id = userId;
    nom = userNom;
    photo = userPhoto;
  }

  static Future<void> loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? "";
    role = prefs.getString('role') ?? "";
    id = prefs.getInt('id') ?? 0;
    nom = prefs.getString('nom') ?? "";
    photo = prefs.getString('photo') ?? "";
  }

  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    email = "";
    role = "";
    id = 0;
    nom = "";
    photo = "";
  }
}