import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'main.dart';

class LoginLocalScreen extends StatelessWidget {
  const LoginLocalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Atrás', style: TextStyle(color: Colors.blueGrey)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: const Icon(
                  Icons.storefront,
                  size: 100,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                child: Text(
                  'Acceso a Locales',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                child: const Text(
                  'Ingresa tu código único de cafetería',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),

              FadeInUp(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. CAFE-9999',
                    prefixIcon: const Icon(Icons.key, color: Colors.blueGrey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardLocalScreen(),
                        ),
                      ),
                  child: const Text(
                    'Abrir Panel de Pedidos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
// 7. DASHBOARD DEL LOCAL (Comandas y Gestión)
// ==========================================
class ComandaDummy {
  final String idPedido;
  final String alumno;
  final String detalle;
  int estado;
  ComandaDummy(this.idPedido, this.alumno, this.detalle, this.estado);
}

class DashboardLocalScreen extends StatefulWidget {
  const DashboardLocalScreen({super.key});

  @override
  State<DashboardLocalScreen> createState() => _DashboardLocalScreenState();
}

class _DashboardLocalScreenState extends State<DashboardLocalScreen> {
  List<ComandaDummy> pedidosActivos = [
    ComandaDummy(
      '#TESE-4029',
      'Axel Guerrero',
      '1x Hamb. Clásica\n1x Jugo Naranja',
      0,
    ),
    ComandaDummy('#TESE-8112', 'Dana Patricia', '2x Chilaquiles Verdes', 1),
    ComandaDummy('#TESE-1993', 'Profe. Informática', '1x Orden Tacos', 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Kiosko Sistemas - Panel',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const DecisionScreen()),
                ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pedidosActivos.length,
        itemBuilder: (context, index) {
          final comanda = pedidosActivos[index];

          Color colorEstado = Colors.grey;
          String textoBoton = '';
          IconData iconoEstado = Icons.receipt;

          if (comanda.estado == 0) {
            colorEstado = Colors.redAccent;
            textoBoton = 'Empezar a Preparar';
            iconoEstado = Icons.notifications_active;
          } else if (comanda.estado == 1) {
            colorEstado =
                colorAmarilloTese; // Usa colorAmarilloTese de main.dart
            textoBoton = '¡Marcar como Listo!';
            iconoEstado = Icons.soup_kitchen;
          } else {
            colorEstado = colorExito; // Usa colorExito de main.dart
            textoBoton = 'Entregado (Quitar de lista)';
            iconoEstado = Icons.check_circle;
          }

          return FadeInUp(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: colorEstado, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comanda.idPedido,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colorEstado,
                          ),
                        ),
                        Chip(
                          avatar: Icon(
                            iconoEstado,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            comanda.estado == 0
                                ? 'NUEVO'
                                : (comanda.estado == 1
                                    ? 'PREPARANDO'
                                    : 'LISTO'),
                          ),
                          backgroundColor: colorEstado,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Alumno: ${comanda.alumno}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      comanda.detalle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorEstado,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (comanda.estado < 2) {
                              comanda.estado++;
                            } else {
                              pedidosActivos.removeAt(index);
                            }
                          });
                        },
                        child: Text(
                          textoBoton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
