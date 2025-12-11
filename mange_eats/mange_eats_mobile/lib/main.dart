import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Garanta que instalou: flutter pub add google_fonts
import 'providers/bag_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BagProvider()),
      ],
      child: const MangeEatsApp(),
    ),
  );
}

class MangeEatsApp extends StatelessWidget {
  const MangeEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mange Eats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Paleta de Cores "Mange Eats"
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63946), // Vermelho vibrante
          primary: const Color(0xFFE63946),
          secondary: const Color(0xFFF1FAEE), // Branco gelo
          surface: Colors.white,
          background: const Color(0xFFF8F9FA), // Cinza bem clarinho pro fundo
        ),
        // Tipografia Moderna
        textTheme: GoogleFonts.poppinsTextTheme(),
        
        // Estilo padrão dos botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE63946),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Estilo dos inputs (Caixas de texto)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE63946), width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}