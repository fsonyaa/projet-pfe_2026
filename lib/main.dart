import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/chauffeurdashboard.dart';
import 'pages/clientdashboard.dart';
import 'pages/current_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrentUser.loadSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getInitialPage() {
    if (CurrentUser.email.isEmpty) {
      return const LoginPage();
    }
    
    switch (CurrentUser.role) {
      case 'admin':
        return AdminDashboard(adminEmail: CurrentUser.email);
      case 'chauffeur':
        return ChauffeurDashboard(driverId: CurrentUser.id, userEmail: CurrentUser.email);
      case 'client':
        return ClientDashboard(clientId: CurrentUser.id, userEmail: CurrentUser.email);
      default:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-Trans',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
      ),
      home: _getInitialPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/admin_dashboard': (context) => AdminDashboard(adminEmail: CurrentUser.email),
      },
    );
  }
}