import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';

void main() {
  runApp(const TeseHambreadosApp());
}

class TeseHambreadosApp extends StatelessWidget {
  const TeseHambreadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TESE Hambreados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorVerdeTese,
          primary: colorVerdeTese,
          secondary: colorAmarilloTese,
        ),
        scaffoldBackgroundColor: colorFondoCrema,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
