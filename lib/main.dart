import 'package:flutter/material.dart';
import 'package:hipertensii/hipertensi.dart';
import 'package:hipertensii/home.dart';
import 'package:hipertensii/login.dart';
import 'package:hipertensii/register.dart';
// import 'hipertensi.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hipertensi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Awal aplikasi
      routes: {
        '/hipertensi': (context) => const Hipertensi(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        // '/riwayat': (context) => const Riwayat(),
        
      },
    );
  }
}