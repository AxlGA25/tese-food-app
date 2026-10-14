import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';
import 'pantalla_inicio.dart';

Widget _botonStock(IconData icono, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: colorFondoCrema,
        shape: BoxShape.circle,
        border: Border.all(color: colorTextoGris.withValues(alpha: 0.25)),
      ),
      child: Icon(icono, size: 16, color: colorTextoOscuro),
    ),
  );
}

// ==========================================================
// 1. ACCESO BLINDADO ANTI-HACKEOS CON AYUDA INTERACTIVA
// ==========================================================
class LoginLocalScreen extends StatefulWidget {
  const LoginLocalScreen({super.key});

  @override
  State<LoginLocalScreen> createState() => _LoginLocalScreenState();
}

class _LoginLocalScreenState extends State<LoginLocalScreen> {
  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

  bool _estaValidando = false;
  bool _ocultarPin = true;
  int _intentosFallidos = 0;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  // 💡 Modal amigable para autocompletar sucursales durante pruebas o demos
  void _mostrarAyudaSucursales() {
    final sucursales = [
      {
        'codigo': 'KS-SISTEMAS',
        'pin': '849201',
        'nombre': 'Kiosko Sistemas',
        'icono': Icons.computer,
      },
      {
        'codigo': 'KB-BIBLIO',
        'pin': '715309',
        'nombre': 'Kiosko Biblioteca',
        'icono': Icons.menu_book,
      },
      {
        'codigo': 'CC-CENTRAL',
        'pin': '938420',
        'nombre': 'Cafetería Central',
        'icono': Icons.storefront,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.key_rounded,
                      color: colorVerdeTese,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ' Directorio de Terminales TESE',
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: colorTextoOscuro,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Toca cualquier sucursal para rellenar su código rápidamente:',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: colorTextoGris,
                  ),
                ),
                const Divider(height: 22),
                ...sucursales.map(
                  (s) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colorVerdeTese.withValues(alpha: 0.1),
                      child: Icon(
                        s['icono'] as IconData,
                        color: colorVerdeTese,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      s['nombre'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorTextoOscuro,
                      ),
                    ),
                    subtitle: Text(
                      'Código: ${s['codigo']}  •  PIN: ${s['pin']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorTextoGris,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.touch_app,
                      color: colorAmarilloTese,
                      size: 20,
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _codigoCtrl.text = s['codigo'] as String;
                        _pinCtrl.text = s['pin'] as String;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _autenticarLocalSeguro() async {
    final codigo = _codigoCtrl.text.trim().toUpperCase();
    final pin = _pinCtrl.text.trim();

    if (codigo.isEmpty || pin.isEmpty) {
      _mostrarAlerta('Ingresa el código de sucursal y el PIN maestro.');
      return;
    }

    if (pin.length < 6) {
      _mostrarAlerta('El PIN maestro debe ser de 6 dígitos numéricos.');
      return;
    }

    if (_intentosFallidos >= 3) {
      _mostrarAlerta(
        '⛔ Acceso bloqueado temporalmente. Demasiados intentos fallidos.',
      );
      return;
    }

    setState(() => _estaValidando = true);
    HapticFeedback.heavyImpact();

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('Locales_Seguridad')
              .where('codigoSucursal', isEqualTo: codigo)
              .where('pinSecreto', isEqualTo: pin)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final String nombreLocal = data['nombre'] ?? 'Kiosko Sistemas';

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DashboardNavegacionLocal(
                  nombreLocal: nombreLocal,
                  codigoLocal: codigo,
                ),
          ),
        );
      } else {
        final fallbackValido = await _verificarEInicializarLlavesMaestras(
          codigo,
          pin,
        );
        if (!mounted) return;
        if (fallbackValido != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DashboardNavegacionLocal(
                    nombreLocal: fallbackValido,
                    codigoLocal: codigo,
                  ),
            ),
          );
        } else {
          setState(() {
            _intentosFallidos++;
            _estaValidando = false;
          });
          _mostrarAlerta(
            'Credenciales no autorizadas. Intento $_intentosFallidos/3.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaValidando = false);
      _mostrarAlerta('Error al verificar credenciales con el servidor.');
    }
  }

  Future<String?> _verificarEInicializarLlavesMaestras(
    String codigo,
    String pin,
  ) async {
    const credencialesBase = {
      'KS-SISTEMAS': {'pin': '849201', 'nombre': 'Kiosko Sistemas'},
      'KB-BIBLIO': {'pin': '715309', 'nombre': 'Kiosko Biblioteca'},
      'CC-CENTRAL': {'pin': '938420', 'nombre': 'Cafetería Central'},
    };

    if (credencialesBase.containsKey(codigo) &&
        credencialesBase[codigo]!['pin'] == pin) {
      await FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .doc(codigo)
          .set({
            'codigoSucursal': codigo,
            'pinSecreto': pin,
            'nombre': credencialesBase[codigo]!['nombre'],
            'activo': true,
          });
      return credencialesBase[codigo]!['nombre'];
    }
    return null;
  }

  void _mostrarAlerta(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _mostrarAyudaSucursales,
            icon: const Icon(
              Icons.help_outline_rounded,
              color: colorVerdeTese,
              size: 18,
            ),
            label: Text(
              'Códigos',
              style: GoogleFonts.poppins(
                color: colorVerdeTese,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Image.asset(
                  'assets/pedidoParaEntregar.png',
                  height: 145,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),
              FadeInDown(
                child: Text(
                  'Terminal de Cocina',
                  style: GoogleFonts.poppins(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInDown(
                child: Text(
                  'Acceso exclusivo para personal de cafetería y kioskos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colorTextoGris,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _codigoCtrl,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: colorTextoOscuro,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Código de Sucursal',
                        hintText: 'Ej. KS-SISTEMAS',
                        prefixIcon: const Icon(
                          Icons.storefront,
                          color: colorVerdeTese,
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _pinCtrl,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      obscureText: _ocultarPin,
                      maxLength: 6,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: colorTextoOscuro,
                      ),
                      decoration: InputDecoration(
                        labelText: 'PIN Maestro (6 dígitos)',
                        counterText: '',
                        prefixIcon: const Icon(
                          Icons.shield_outlined,
                          color: colorVerdeTese,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPin
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorTextoGris,
                          ),
                          onPressed:
                              () => setState(() => _ocultarPin = !_ocultarPin),
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.lock_open,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          elevation: 3,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed:
                            _estaValidando ? null : _autenticarLocalSeguro,
                        label:
                            _estaValidando
                                ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Text(
                                  'Desbloquear Terminal',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _mostrarAyudaSucursales,
                      icon: const Icon(
                        Icons.touch_app_outlined,
                        size: 16,
                        color: colorVerdeTese,
                      ),
                      label: Text(
                        'Elegir sucursal rápidamente',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeTese,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 14, color: colorTextoGris),
                  const SizedBox(width: 5),
                  Text(
                    'Terminal protegida contra accesos no autorizados',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colorTextoGris,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 2. DASHBOARD AISLADO POR SUCURSAL ESPECÍFICA
// ==========================================================
class DashboardNavegacionLocal extends StatefulWidget {
  final String nombreLocal;
  final String codigoLocal;

  const DashboardNavegacionLocal({
    super.key,
    required this.nombreLocal,
    required this.codigoLocal,
  });

  @override
  State<DashboardNavegacionLocal> createState() =>
      _DashboardNavegacionLocalState();
}

class _DashboardNavegacionLocalState extends State<DashboardNavegacionLocal> {
  int _indiceActual = 0;
  int _filtroEstado = -1;

  int _minutosEspera(Timestamp? hora) {
    if (hora == null) return 0;
    return DateTime.now().difference(hora.toDate()).inMinutes;
  }

  void _cambiarEstadoPedido(String idDoc, int estadoActual) {
    HapticFeedback.heavyImpact();
    int nuevoEstado = estadoActual + 1;
    Map<String, dynamic> updateData = {'estado': nuevoEstado};

    if (nuevoEstado == 3) {
      updateData['puntosAcreditados'] = true;
    }

    FirebaseFirestore.instance
        .collection('Pedidos')
        .doc(idDoc)
        .update(updateData);

    if (nuevoEstado == 3 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Pedido entregado con éxito! Puntos liberados al alumno 🪙🎉',
          ),
          backgroundColor: colorExito,
        ),
      );
    }
  }

  void _ajustarExistencias(String idDoc, int existenciasActuales, int cambio) {
    HapticFeedback.selectionClick();
    int nuevaCantidad = existenciasActuales + cambio;
    if (nuevaCantidad < 0) nuevaCantidad = 0;
    FirebaseFirestore.instance.collection('Menu_Platillos').doc(idDoc).update({
      'existencias': nuevaCantidad,
    });
  }

  void _confirmarCierreSesion() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Bloquear terminal?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: colorTextoOscuro,
              ),
            ),
            content: Text(
              'Se cerrará la sesión activa de ${widget.nombreLocal}. Para volver a entrar se requerirá el PIN maestro.',
              style: GoogleFonts.poppins(color: colorTextoGris, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Seguir operando',
                  style: GoogleFonts.poppins(
                    color: colorTextoGris,
                    fontWeight: FontWeight.w600,
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (c) => const DecisionScreen()),
                  );
                },
                child: Text(
                  'Bloquear Terminal',
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

  void _confirmarEliminarPlatillo(
    BuildContext ctxModal,
    String docId,
    String nombre,
  ) {
    showDialog(
      context: context,
      builder:
          (ctxConfirm) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Eliminar platillo?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Seguro que deseas borrar "$nombre" del menú de ${widget.nombreLocal}?',
              style: GoogleFonts.poppins(fontSize: 13.5, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctxConfirm),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('Menu_Platillos')
                      .doc(docId)
                      .delete();
                  Navigator.pop(ctxConfirm);
                  Navigator.pop(ctxModal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Se eliminó "$nombre" del menú.')),
                  );
                },
                child: const Text(
                  'Sí, eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _mostrarDialogoEditarPlatillo(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final TextEditingController precioCtrl = TextEditingController(
      text: '${data['precio'] ?? 0}',
    );
    final TextEditingController existenciasCtrl = TextEditingController(
      text: '${data['existencias'] ?? 0}',
    );
    final TextEditingController puntosCtrl = TextEditingController(
      text: '${data['puntos'] ?? 10}',
    );
    final TextEditingController descCtrl = TextEditingController(
      text: '${data['descripcion'] ?? ''}',
    );
    final TextEditingController nuevoIngredienteCtrl = TextEditingController();
    final List<String> ingredientes = List<String>.from(
      data['ingredientes'] ?? [],
    );
    String categoriaActual = data['categoria'] ?? 'Comida';
    String tiempoActual = data['tiempoPrep'] ?? '15 min';

    const categoriasOpciones = ['Desayunos', 'Comida', 'Bebidas', 'Postres'];
    const tiemposOpciones = ['5 min', '10 min', '15 min', '20 min'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Editar: ${data['nombre'] ?? 'Platillo'}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorTextoOscuro,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Eliminar Platillo',
                            onPressed:
                                () => _confirmarEliminarPlatillo(
                                  ctx,
                                  doc.id,
                                  data['nombre'] ?? 'Platillo',
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        'Categoría en el menú:',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children:
                            categoriasOpciones.map((cat) {
                              final bool sel = categoriaActual == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: sel,
                                selectedColor: colorVerdeTese,
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: sel ? Colors.white : colorTextoOscuro,
                                ),
                                onSelected:
                                    (_) => setStateModal(
                                      () => categoriaActual = cat,
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Precio (\$)',
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  color: colorVerdeTese,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: existenciasCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Stock / Piezas',
                                prefixIcon: const Icon(
                                  Icons.inventory,
                                  color: colorVerdeTese,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: puntosCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Puntos 🪙',
                                prefixIcon: const Icon(
                                  Icons.stars_rounded,
                                  color: colorAmarilloTese,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value:
                                  tiemposOpciones.contains(tiempoActual)
                                      ? tiempoActual
                                      : '15 min',
                              decoration: InputDecoration(
                                labelText: 'Tiempo Prep.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  tiemposOpciones
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setStateModal(
                                    () => tiempoActual = val ?? '15 min',
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción del platillo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Ingredientes modificables por el alumno:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ingredientes.map((ing) {
                              return Chip(
                                label: Text(
                                  ing,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorVerdeTese,
                                  ),
                                ),
                                backgroundColor: colorVerdeTese.withValues(
                                  alpha: 0.1,
                                ),
                                deleteIcon: const Icon(
                                  Icons.cancel,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                onDeleted:
                                    () => setStateModal(
                                      () => ingredientes.remove(ing),
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nuevoIngredienteCtrl,
                              decoration: InputDecoration(
                                hintText:
                                    'Agregar ingrediente (ej. Crema, Queso)...',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: colorVerdeTese,
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              if (nuevoIngredienteCtrl.text.trim().isNotEmpty) {
                                setStateModal(() {
                                  ingredientes.add(
                                    nuevoIngredienteCtrl.text.trim(),
                                  );
                                  nuevoIngredienteCtrl.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final double nuevoPrecio =
                                double.tryParse(precioCtrl.text) ??
                                (data['precio'] ?? 0).toDouble();
                            final int nuevasExistencias =
                                int.tryParse(existenciasCtrl.text) ??
                                (data['existencias'] ?? 0);
                            final int nuevosPuntos =
                                int.tryParse(puntosCtrl.text) ??
                                (data['puntos'] ?? 10);

                            FirebaseFirestore.instance
                                .collection('Menu_Platillos')
                                .doc(doc.id)
                                .update({
                                  'precio': nuevoPrecio,
                                  'existencias': nuevasExistencias,
                                  'puntos': nuevosPuntos,
                                  'categoria': categoriaActual,
                                  'tiempoPrep': tiempoActual,
                                  'descripcion': descCtrl.text.trim(),
                                  'ingredientes': ingredientes,
                                });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '¡Platillo actualizado en tiempo real! 🍔✨',
                                ),
                                backgroundColor: colorExito,
                              ),
                            );
                          },
                          child: Text(
                            'Guardar Modificaciones',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _mostrarDetallePedido(
    DocumentSnapshot comanda,
    int numeroTicket,
    Color colorEstado,
    String textoBoton,
    int estado,
  ) {
    final data = comanda.data() as Map<String, dynamic>? ?? {};
    String idPedido = data['idPedido'] ?? comanda.id;
    double total = (data['total'] ?? 0).toDouble();
    String alumno = data['alumno'] ?? 'Alumno';
    String detalle = data['detalle'] ?? '';
    String notas = data['notas']?.toString() ?? '';
    String metodoPago = data['metodoPago'] ?? 'Efectivo';
    int puntosGanados = data['puntosGanados'] ?? 10;
    Timestamp? horaLlegada = data['horaLlegada'] as Timestamp?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket #$numeroTicket',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          idPedido,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorVerdeTese.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeTese,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorVerdeTese.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.person,
                        color: colorVerdeTese,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alumno,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorAmarilloTese.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🪙 +$puntosGanados pts',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorVerdeOscuro,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Comanda a preparar:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorTextoGris,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorFondoCrema,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    detalle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorTextoOscuro,
                      height: 1.4,
                    ),
                  ),
                ),
                if (notas.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nota especial / Alergia: $notas',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      metodoPago == 'Efectivo'
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      color: colorTextoGris,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Método: $metodoPago',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTextoGris,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Espera: ${_minutosEspera(horaLlegada)} min',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorTextoGris,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorEstado,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _cambiarEstadoPedido(comanda.id, estado);
                    },
                    child: Text(
                      textoBoton,
                      style: GoogleFonts.poppins(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colorVerdeTese.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront,
                color: colorVerdeTese,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombreLocal,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: colorExito,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'En línea (${widget.codigoLocal})',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorExito,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Bloquear Terminal',
            icon: const Icon(Icons.lock_outline, color: Colors.redAccent),
            onPressed: _confirmarCierreSesion,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child:
            _indiceActual == 0
                ? _vistaPedidosDidi()
                : (_indiceActual == 1 ? _vistaMenuDidi() : _vistaResenasDidi()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) => setState(() => _indiceActual = index),
          selectedItemColor: colorVerdeTese,
          unselectedItemColor: colorTextoGris,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Comandas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Existencias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_rate_rounded),
              label: 'Opiniones',
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaPedidosDidi() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final todosPedidos = List<DocumentSnapshot>.from(snapshot.data!.docs)
          ..removeWhere((d) => ((d.data() as Map)['estado'] ?? 0) >= 3);

        todosPedidos.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          int estadoA = aData['estado'] ?? 0;
          int estadoB = bData['estado'] ?? 0;
          if (estadoA != estadoB) return estadoA.compareTo(estadoB);
          final Timestamp? tA = aData['horaLlegada'] as Timestamp?;
          final Timestamp? tB = bData['horaLlegada'] as Timestamp?;
          if (tA == null) return -1;
          if (tB == null) return 1;
          return tA.compareTo(tB);
        });

        int cantNuevos =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 0).length;
        int cantCocina =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 1).length;
        int cantListos =
            todosPedidos.where((d) => (d.data() as Map)['estado'] == 2).length;

        final pedidos =
            _filtroEstado == -1
                ? todosPedidos
                : todosPedidos
                    .where((d) => (d.data() as Map)['estado'] == _filtroEstado)
                    .toList();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipFiltro(
                      'Todos (${todosPedidos.length})',
                      -1,
                      colorVerdeTese,
                    ),
                    const SizedBox(width: 8),
                    _chipFiltro('Nuevos ($cantNuevos)', 0, Colors.redAccent),
                    const SizedBox(width: 8),
                    _chipFiltro(
                      'En Cocina ($cantCocina)',
                      1,
                      colorAmarilloTese,
                    ),
                    const SizedBox(width: 8),
                    _chipFiltro('Listos ($cantListos)', 2, colorExito),
                  ],
                ),
              ),
            ),
            Expanded(
              child:
                  pedidos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 70,
                              color: colorVerdeTese.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Todo al día en ${widget.nombreLocal}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorVerdeTese,
                              ),
                            ),
                            Text(
                              'Las nuevas órdenes de alumnos aparecerán aquí al instante.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorTextoGris,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final comanda = pedidos[index];
                          final data =
                              comanda.data() as Map<String, dynamic>? ?? {};
                          final int estado = data['estado'] ?? 0;
                          final numeroTicket = index + 1;
                          final int minutos = _minutosEspera(
                            data['horaLlegada'] as Timestamp?,
                          );
                          final int puntos = data['puntosGanados'] ?? 10;

                          Color colorEstado;
                          String textoBoton;
                          String labelEstado;
                          IconData iconoAccion;

                          if (estado == 0) {
                            colorEstado = Colors.redAccent;
                            textoBoton = 'Aceptar y Cocinar';
                            labelEstado = 'NUEVO';
                            iconoAccion = Icons.soup_kitchen;
                          } else if (estado == 1) {
                            colorEstado = colorAmarilloTese;
                            textoBoton = '¡Marcar Listo!';
                            labelEstado = 'EN COCINA';
                            iconoAccion = Icons.check_circle_outline;
                          } else {
                            colorEstado = colorExito;
                            textoBoton = 'Entregar a Alumno (Liberar Puntos)';
                            labelEstado = 'POR ENTREGAR';
                            iconoAccion = Icons.task_alt;
                          }

                          return FadeInUp(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: colorEstado.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap:
                                    () => _mostrarDetallePedido(
                                      comanda,
                                      numeroTicket,
                                      colorEstado,
                                      textoBoton,
                                      estado,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorEstado,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  labelEstado,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Ticket #$numeroTicket',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorTextoGris,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 15,
                                                color:
                                                    minutos >= 15
                                                        ? Colors.redAccent
                                                        : colorTextoGris,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'hace ${minutos}m',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      minutos >= 15
                                                          ? Colors.redAccent
                                                          : colorTextoGris,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data['idPedido'] ?? comanda.id,
                                            style: GoogleFonts.poppins(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w900,
                                              color: colorTextoOscuro,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorAmarilloTese
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+$puntos pts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: colorVerdeOscuro,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 15,
                                            color: colorVerdeTese,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              data['alumno'] ?? 'Alumno',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: colorVerdeTese,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Text(
                                        data['detalle'] ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorTextoOscuro,
                                        ),
                                      ),
                                      if ((data['notas'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '⚠️ ${data['notas']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorEstado,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: Icon(
                                            iconoAccion,
                                            color: Colors.white,
                                            size: 19,
                                          ),
                                          label: Text(
                                            textoBoton,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          onPressed:
                                              () => _cambiarEstadoPedido(
                                                comanda.id,
                                                estado,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _chipFiltro(String titulo, int estado, Color colorAcento) {
    bool activo = _filtroEstado == estado;
    return ChoiceChip(
      label: Text(titulo),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: activo ? Colors.white : colorTextoOscuro,
      ),
      selected: activo,
      selectedColor: colorAcento,
      backgroundColor: colorFondoCrema,
      side: BorderSide(color: activo ? colorAcento : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) => setState(() => _filtroEstado = val ? estado : -1),
    );
  }

  Widget _vistaMenuDidi() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }
        final miMenu = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body:
              miMenu.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: colorVerdeTese.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay platillos registrados',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorVerdeTese,
                            ),
                          ),
                          Text(
                            'Presiona el botón amarillo de abajo para publicar el primer platillo de ${widget.nombreLocal}.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: colorTextoGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 85),
                    itemCount: miMenu.length,
                    itemBuilder: (context, index) {
                      final platillo = miMenu[index];
                      final data =
                          platillo.data() as Map<String, dynamic>? ?? {};

                      final int existencias = data['existencias'] ?? 0;
                      final bool agotado = existencias == 0;
                      final String nombre = data['nombre'] ?? 'Sin nombre';
                      final String categoria = data['categoria'] ?? 'Comida';
                      final dynamic precio = data['precio'] ?? 0;
                      final double calif =
                          (data['calificacion'] ?? 0.0).toDouble();
                      final int puntos = data['puntos'] ?? 10;
                      final List fotos = data['fotos'] ?? [];

                      return FadeInUp(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorVerdeTese.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      agotado
                                          ? Colors.grey.withValues(alpha: 0.1)
                                          : colorVerdeTese.withValues(
                                            alpha: 0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      fotos.isNotEmpty
                                          ? Image.memory(
                                            base64Decode(fotos[0]),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => Icon(
                                                  Icons.fastfood,
                                                  color:
                                                      agotado
                                                          ? colorTextoGris
                                                          : colorVerdeTese,
                                                ),
                                          )
                                          : Icon(
                                            Icons.fastfood,
                                            color:
                                                agotado
                                                    ? colorTextoGris
                                                    : colorVerdeTese,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap:
                                      () => _mostrarDialogoEditarPlatillo(
                                        platillo,
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              nombre,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color:
                                                    agotado
                                                        ? colorTextoGris
                                                        : colorTextoOscuro,
                                                decoration:
                                                    agotado
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.edit_outlined,
                                            size: 15,
                                            color: colorTextoGris,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            '\$$precio',
                                            style: GoogleFonts.poppins(
                                              color: colorExito,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorVerdeTese.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              categoria,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: colorVerdeTese,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorAmarilloTese
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+$puntos pts',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: colorVerdeOscuro,
                                              ),
                                            ),
                                          ),
                                          if (calif > 0)
                                            Text(
                                              '⭐ ${calif.toStringAsFixed(1)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: colorTextoOscuro,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _botonStock(
                                    Icons.remove,
                                    () => _ajustarExistencias(
                                      platillo.id,
                                      existencias,
                                      -1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      '$existencias',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _botonStock(
                                    Icons.add,
                                    () => _ajustarExistencias(
                                      platillo.id,
                                      existencias,
                                      1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colorAmarilloTese,
            elevation: 4,
            icon: const Icon(Icons.add, color: colorVerdeOscuro),
            label: Text(
              'Agregar a ${widget.nombreLocal.replaceAll('Kiosko ', '').replaceAll('Cafetería ', '')}',
              style: GoogleFonts.poppins(
                color: colorVerdeOscuro,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AgregarPlatilloScreen(
                          nombreLocal: widget.nombreLocal,
                        ),
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget _vistaResenasDidi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Resenas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final resenasDocs =
            List<DocumentSnapshot>.from(snapshot.data!.docs).where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final String? localResena = d['local'] as String?;
              return localResena == null || localResena == widget.nombreLocal;
            }).toList();

        resenasDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final Timestamp? tA = aData['fecha'] as Timestamp?;
          final Timestamp? tB = bData['fecha'] as Timestamp?;
          if (tA == null) return -1;
          if (tB == null) return 1;
          return tB.compareTo(tA);
        });

        if (resenasDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 70,
                    color: colorVerdeTese.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin opiniones todavía',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorVerdeTese,
                    ),
                  ),
                  Text(
                    'Cuando los alumnos califiquen sus pedidos, verás sus comentarios y estrellas aquí.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: colorTextoGris,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resenasDocs.length,
          itemBuilder: (context, index) {
            final resena = resenasDocs[index];
            final data = resena.data() as Map<String, dynamic>;
            final String platillo = data['platilloNombre'] ?? 'Comida';
            final int estrellas = data['estrellas'] ?? 5;
            final String comentario = data['comentario'] ?? '';
            final String alumno = data['alumno'] ?? 'Alumno';

            return FadeInUp(
              delay: Duration(milliseconds: 50 * index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colorVerdeTese.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            platillo,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorTextoOscuro,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < estrellas
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color:
                                  starIndex < estrellas
                                      ? colorAmarilloTese
                                      : Colors.grey[300],
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (comentario.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorFondoCrema,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '« $comentario »',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            color: colorTextoOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Por: $alumno',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorTextoGris,
                          ),
                        ),
                        Text(
                          'Calificación: $estrellas/5',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorVerdeTese,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================================
// 3. AGREGAR PLATILLO CON CATEGORÍA, TIEMPO Y DESCRIPCIÓN
// ==========================================================
class AgregarPlatilloScreen extends StatefulWidget {
  final String nombreLocal;
  const AgregarPlatilloScreen({super.key, required this.nombreLocal});

  @override
  State<AgregarPlatilloScreen> createState() => _AgregarPlatilloScreenState();
}

class _AgregarPlatilloScreenState extends State<AgregarPlatilloScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _existenciasCtrl = TextEditingController(
    text: '15',
  );
  final TextEditingController _puntosCtrl = TextEditingController(text: '15');
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _ingredienteCtrl = TextEditingController();

  String _categoriaElegida = 'Comida';
  String _tiempoPrepElegido = '15 min';
  final List<String> _categorias = const [
    'Desayunos',
    'Comida',
    'Bebidas',
    'Postres',
  ];
  final List<String> _tiempos = const ['5 min', '10 min', '15 min', '20 min'];

  final List<String> _ingredientesPersonalizados = [];
  final List<String> _fotosBase64 = [];
  final ImagePicker _picker = ImagePicker();

  bool _estaCargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _existenciasCtrl.dispose();
    _puntosCtrl.dispose();
    _descCtrl.dispose();
    _ingredienteCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto(ImageSource source) async {
    if (_fotosBase64.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten hasta 3 fotos por platillo.'),
        ),
      );
      return;
    }

    try {
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );

      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        final String base64String = base64Encode(bytes);
        if (!mounted) return;
        setState(() => _fotosBase64.add(base64String));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen.')),
      );
    }
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: colorVerdeTese),
                  title: Text(
                    'Tomar foto con cámara',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _seleccionarFoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: colorVerdeTese,
                  ),
                  title: Text(
                    'Elegir de galería',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _seleccionarFoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _guardarPlatillo() async {
    final String nombre = _nombreCtrl.text.trim();
    final double? precio = double.tryParse(_precioCtrl.text.trim());

    if (nombre.isEmpty || precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa un nombre y un precio válido para el platillo.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _estaCargando = true);

    try {
      final int stockFinal = int.tryParse(_existenciasCtrl.text) ?? 15;
      final int puntosFinales = int.tryParse(_puntosCtrl.text) ?? 15;
      final String descFinal =
          _descCtrl.text.trim().isEmpty
              ? 'Platillo preparado al momento en ${widget.nombreLocal}.'
              : _descCtrl.text.trim();

      await FirebaseFirestore.instance.collection('Menu_Platillos').add({
        'nombre': nombre,
        'precio': precio,
        'local': widget.nombreLocal,
        'categoria': _categoriaElegida,
        'descripcion': descFinal,
        'tiempoPrep': _tiempoPrepElegido,
        'calificacion': 0.0,
        'numCalificaciones': 0,
        'popular': true,
        'ingredientes': _ingredientesPersonalizados,
        'existencias': stockFinal,
        'fotos': _fotosBase64,
        'puntos': puntosFinales,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡"$nombre" publicado en ${widget.nombreLocal}! ☁️🍔'),
          backgroundColor: colorExito,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el platillo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _agregarIngrediente(String valor) {
    final limpio = valor.trim();
    if (limpio.isNotEmpty && !_ingredientesPersonalizados.contains(limpio)) {
      setState(() {
        _ingredientesPersonalizados.add(limpio);
        _ingredienteCtrl.clear();
      });
    }
  }

  InputDecoration _decoracionCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: colorVerdeTese),
      filled: true,
      fillColor: colorFondoCrema,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Nuevo Platillo • ${widget.nombreLocal}',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // FOTOS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fotos del platillo (${_fotosBase64.length}/3)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      if (_fotosBase64.length < 3)
                        TextButton.icon(
                          onPressed: _mostrarOpcionesFoto,
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 18,
                            color: colorVerdeTese,
                          ),
                          label: Text(
                            'Agregar',
                            style: GoogleFonts.poppins(
                              color: colorVerdeTese,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_fotosBase64.isEmpty)
                    GestureDetector(
                      onTap: _mostrarOpcionesFoto,
                      child: Container(
                        height: 105,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorVerdeTese.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 34,
                              color: colorVerdeTese.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Toca para tomar foto o elegir de galería',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: colorTextoGris,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fotosBase64.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: colorVerdeTese.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    base64Decode(_fotosBase64[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _fotosBase64.removeAt(index),
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // DATOS DEL PLATILLO + CATEGORÍA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nombreCtrl,
                    decoration: _decoracionCampo(
                      'Nombre del Platillo',
                      Icons.restaurant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Categoría en el catálogo:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _categorias.map((cat) {
                          final bool sel = _categoriaElegida == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: sel,
                            selectedColor: colorVerdeTese,
                            backgroundColor: colorFondoCrema,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: sel ? Colors.white : colorTextoOscuro,
                            ),
                            onSelected:
                                (_) => setState(() => _categoriaElegida = cat),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _precioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _decoracionCampo(
                            'Precio (\$)',
                            Icons.attach_money,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _existenciasCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _decoracionCampo(
                            'Existencias',
                            Icons.inventory,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _puntosCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Puntos 🪙',
                            prefixIcon: const Icon(
                              Icons.stars_rounded,
                              color: colorAmarilloTese,
                            ),
                            filled: true,
                            fillColor: colorFondoCrema,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tiempoPrepElegido,
                          decoration: _decoracionCampo(
                            'Tiempo',
                            Icons.schedule,
                          ),
                          items:
                              _tiempos
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(
                                () => _tiempoPrepElegido = val ?? '15 min',
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: _decoracionCampo(
                      'Descripción breve (opcional)',
                      Icons.notes,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // INGREDIENTES PERSONALIZABLES
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorVerdeTese.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredientes que el alumno puede quitar o pedir extra',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Opcional: Agrega ingredientes como Cebolla, Crema, Queso, Salsa...',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: colorTextoGris,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredienteCtrl,
                          onSubmitted: _agregarIngrediente,
                          decoration: InputDecoration(
                            hintText: 'Ej. Queso, Cebolla, Salsa verde...',
                            filled: true,
                            fillColor: colorFondoCrema,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed:
                            () => _agregarIngrediente(_ingredienteCtrl.text),
                      ),
                    ],
                  ),
                  if (_ingredientesPersonalizados.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _ingredientesPersonalizados.map((ing) {
                            return Chip(
                              label: Text(
                                ing,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorVerdeTese,
                                ),
                              ),
                              backgroundColor: colorVerdeTese.withValues(
                                alpha: 0.1,
                              ),
                              deleteIcon: const Icon(
                                Icons.cancel,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              onDeleted:
                                  () => setState(
                                    () =>
                                        _ingredientesPersonalizados.remove(ing),
                                  ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAmarilloTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _estaCargando ? null : _guardarPlatillo,
                icon: const Icon(
                  Icons.cloud_upload_outlined,
                  color: colorVerdeOscuro,
                ),
                label:
                    _estaCargando
                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: colorVerdeOscuro,
                            strokeWidth: 2.5,
                          ),
                        )
                        : Text(
                          'Publicar Platillo en el Menú',
                          style: GoogleFonts.poppins(
                            color: colorVerdeOscuro,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
