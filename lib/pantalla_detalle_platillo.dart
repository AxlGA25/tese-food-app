import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_menu.dart';

class PantallaDetallePlatillo extends StatefulWidget {
  final Platillo platillo;
  final void Function(Platillo) onAgregar;
  const PantallaDetallePlatillo({
    super.key,
    required this.platillo,
    required this.onAgregar,
  });

  @override
  State<PantallaDetallePlatillo> createState() =>
      _PantallaDetallePlatilloState();
}

class _PantallaDetallePlatilloState extends State<PantallaDetallePlatillo> {
  int cantidad = 1;

  Widget _botonCircular({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icono, color: colorTextoOscuro, size: 20),
      ),
    );
  }

  Widget _chipInfo(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colorTextoOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorFondoCrema,
          shape: BoxShape.circle,
          border: Border.all(color: colorTextoGris.withValues(alpha: 0.3)),
        ),
        child: Icon(icono, size: 18, color: colorTextoOscuro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platillo = widget.platillo;
    final acento = acentoDeCategoria(platillo.categoria);
    final total = platillo.precio * cantidad;

    return Scaffold(
      backgroundColor: colorFondoCrema,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [acento, acento.withValues(alpha: 0.75)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Center(
                  child: ZoomIn(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        platillo.icono,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _botonCircular(
                        icono: Icons.arrow_back,
                        onTap: () => Navigator.pop(context, false),
                      ),
                      if (platillo.popular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🔥 Popular',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorTextoOscuro,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          platillo.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      Text(
                        '\$${platillo.precio.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: acento,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.storefront, size: 15, color: colorTextoGris),
                      const SizedBox(width: 4),
                      Text(
                        platillo.local,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: colorTextoGris,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _chipInfo(
                        Icons.star_rounded,
                        '${platillo.calificacion} ★',
                        colorAmarilloTese,
                      ),
                      _chipInfo(
                        Icons.schedule,
                        platillo.tiempoPrep,
                        colorVerdeTese,
                      ),
                      _chipInfo(Icons.local_offer, platillo.categoria, acento),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Descripción',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    platillo.descripcion.isEmpty
                        ? 'Delicioso, recién preparado para ti.'
                        : platillo.descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorTextoGris,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Row(
                        children: [
                          _botonCantidad(Icons.remove, () {
                            if (cantidad > 1) setState(() => cantidad--);
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '$cantidad',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ),
                          _botonCantidad(
                            Icons.add,
                            () => setState(() => cantidad++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acento,
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    for (int i = 0; i < cantidad; i++) {
                      widget.onAgregar(platillo);
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Agregar • \$${total.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: colorTextoSobreAcento(acento),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
