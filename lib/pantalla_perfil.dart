import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';

class PerfilEstudianteScreen extends StatelessWidget {
  const PerfilEstudianteScreen({super.key});

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Cerrar sesión?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: colorTextoOscuro,
              ),
            ),
            content: Text(
              'Tendrás que volver a ingresar con tu matrícula para realizar pedidos.',
              style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    color: colorTextoGris,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DecisionScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 📊 Consulta en tiempo real las estadísticas del alumno
        stream:
            FirebaseFirestore.instance
                .collection('Pedidos')
                .where('alumno', isEqualTo: 'Axel Guerrero')
                .snapshots(),
        builder: (context, snapshot) {
          int totalPedidos = 0;
          if (snapshot.hasData) {
            totalPedidos = snapshot.data!.docs.length;
          }

          // Medidor de Nivel Hambreado
          String rangoHambreado = 'Iniciando antojos 🍪';
          if (totalPedidos >= 5) {
            rangoHambreado = 'Comelón Frecuente 🍟';
          }
          if (totalPedidos >= 15) {
            rangoHambreado = 'Hambreado VIP 🥇';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              children: [
                // FOTO Y ENCABEZADO
                FadeInDown(
                  child: Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorAmarilloTese,
                                  width: 3,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 52,
                                backgroundColor: colorVerdeTese,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: colorAmarilloTese,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                size: 18,
                                color: colorVerdeOscuro,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Axel Guerrero',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorVerdeTese,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorVerdeTese.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Estudiante TESE • 6° Semestre',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorVerdeTese,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🥇 TARJETA DE ESTADÍSTICAS Y NIVEL HAMBREADO
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [colorVerdeTese, Color(0xFF1B3D37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: colorVerdeTese.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nivel de Consumo',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  rangoHambreado,
                                  style: GoogleFonts.poppins(
                                    color: colorAmarilloTese,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text('🦆', style: TextStyle(fontSize: 32)),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _itemEstadistica(
                              'Pedidos',
                              '$totalPedidos',
                              Icons.receipt_long,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white24,
                            ),
                            _itemEstadistica(
                              'Kiosko Favorito',
                              'Sistemas',
                              Icons.storefront,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white24,
                            ),
                            _itemEstadistica(
                              'Puntos',
                              '${totalPedidos * 10}',
                              Icons.stars,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎓 TARJETA 1: DATOS ACADÉMICOS
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _contenedorTarjeta(
                    titulo: 'Información Académica',
                    hijos: [
                      _FilaInfoPerfil(
                        icono: Icons.badge_outlined,
                        etiqueta: 'Matrícula',
                        valor: '20240001',
                      ),
                      const Divider(height: 1),
                      _FilaInfoPerfil(
                        icono: Icons.school_outlined,
                        etiqueta: 'Carrera',
                        valor: 'Ing. en Sistemas Computacionales',
                      ),
                      const Divider(height: 1),
                      _FilaInfoPerfil(
                        icono: Icons.email_outlined,
                        etiqueta: 'Correo Institucional',
                        valor: 'axel.guerrero@tese.edu.mx',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 💳 TARJETA 2: PREFERENCIAS
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: _contenedorTarjeta(
                    titulo: 'Preferencias de Pedido',
                    hijos: [
                      _FilaInfoPerfil(
                        icono: Icons.payments_outlined,
                        etiqueta: 'Pago Habitual',
                        valor: 'Efectivo en Ventanilla',
                      ),
                      const Divider(height: 1),
                      _FilaInfoPerfil(
                        icono: Icons.location_on_outlined,
                        etiqueta: 'Kiosko Preferido',
                        valor: 'Kiosko Sistemas',
                      ),
                      const Divider(height: 1),
                      _FilaInfoPerfil(
                        icono: Icons.restaurant_outlined,
                        etiqueta: 'Preferencia',
                        valor: 'Come de todo 😋',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // BOTÓN CERRAR SESIÓN
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _confirmarCerrarSesion(context),
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text(
                        'Cerrar Sesión',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _itemEstadistica(String label, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _contenedorTarjeta({
    required String titulo,
    required List<Widget> hijos,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorVerdeTese.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorVerdeTese,
            ),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}

class _FilaInfoPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaInfoPerfil({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icono, color: colorVerdeTese, size: 19),
          const SizedBox(width: 10),
          Text(
            etiqueta,
            style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: colorTextoOscuro,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
