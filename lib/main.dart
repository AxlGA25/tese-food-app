import 'package:flutter/material.dart';

void main() {
  runApp(const TeseFoodApp());
}

class TeseFoodApp extends StatelessWidget {
  const TeseFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TESE Food App',
      theme: ThemeData(
        // Cambiamos todo a Rojo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DecisionScreen(),
    );
  }
}

// ==========================================
// 1. PANTALLA DE DECISIÓN (Rojo a Blanco)
// ==========================================
class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Degradado de Rojo a Blanco
          gradient: LinearGradient(
            colors: [Colors.red, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación de entrada para el Logo
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double val, child) {
                    return Transform.scale(scale: val, child: child);
                  },
                  child: const Hero(
                    tag: 'logo_app',
                    child: Icon(Icons.fastfood, size: 120, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'TESE Food',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Sin filas, más receso.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 80),

                // Botón Estudiante (Destacado)
                ElevatedButton.icon(
                  icon: const Icon(Icons.school, color: Colors.white),
                  label: const Text(
                    'Soy Estudiante',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Botón rojo
                    minimumSize: const Size(double.infinity, 55),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginEstudianteScreen(),
                        ),
                      ),
                ),
                const SizedBox(height: 20),

                // Botón Local (Transparente con borde rojo)
                OutlinedButton.icon(
                  icon: const Icon(Icons.storefront, color: Colors.red),
                  label: const Text(
                    'Soy Cafetería / Local',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginLocalScreen(),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. LOGIN ESTUDIANTE
// ==========================================
class LoginEstudianteScreen extends StatelessWidget {
  const LoginEstudianteScreen({super.key});

  void _simularLogin(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Validando credenciales...'),
        backgroundColor: Colors.red,
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioEstudianteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Estudiantes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Hero(
                tag: 'logo_app',
                child: Icon(Icons.fastfood, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        '¡Hola de nuevo!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Número de Control',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _simularLogin(context),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Crear nueva cuenta',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. LOGIN LOCAL
// ==========================================
class LoginLocalScreen extends StatelessWidget {
  const LoginLocalScreen({super.key});

  void _simularLoginLocal(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accediendo al Panel...'),
        backgroundColor: Colors.blueGrey,
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InicioLocalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Panel Local'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.store, size: 60, color: Colors.blueGrey),
                  const SizedBox(height: 20),
                  const Text(
                    'Administración',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo Institucional',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'PIN de Seguridad',
                      prefixIcon: const Icon(Icons.password),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _simularLoginLocal(context),
                    child: const Text(
                      'Ingresar al Panel',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. PANTALLAS EN BLANCO (Destinos)
// ==========================================

// Pantalla destino para Estudiante
class InicioEstudianteScreen extends StatelessWidget {
  const InicioEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Estudiante'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const DecisionScreen()),
                ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Contenido de la aplicación\n(En construcción)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// Pantalla destino para Local/Cafetería
class InicioLocalScreen extends StatelessWidget {
  const InicioLocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Panel Local'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const DecisionScreen()),
                ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard del local\n(En construcción)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
