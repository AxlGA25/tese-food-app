import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'colores.dart';
import 'modelos.dart';
import 'pantalla_gachapon.dart';
import 'pantalla_login.dart';

// ==========================================================
// GUÍA RÁPIDA INTERACTIVA PARA COCINA
// ==========================================================
void mostrarTutorialCocina(BuildContext context, String nombreSucursal) {
  int paginaActual = 0;
  final PageController pageCtrl = PageController();

  final List<Map<String, dynamic>> pasos = [
    {
      'badge': 'PASO 1 DE 4 • COMANDAS EN VIVO',
      'titulo': 'Terminal de $nombreSucursal 👨‍🍳',
      'descripcion':
          'Aquí recibirás en tiempo real únicamente los pedidos dirigidos a tu sucursal. Cada tarjeta te muestra hora de llegada, total de piezas, platillos desglosados y método de cobro.',
      'skinId': 'chef',
      'icono': Icons.volume_up_rounded,
      'color': colorVerdeTese,
    },
    {
      'badge': 'PASO 2 DE 4 • FLUJO Y CANCELACIÓN',
      'titulo': 'Cocina, Entrega o Cancela ⚡',
      'descripcion':
          '1️⃣ Toca "Aceptar y Cocinar" para avisarle al alumno.\n2️⃣ Toca "¡Marcar Listo!" para que suene su celular (¡CUAC!).\n3️⃣ Si se agotó un ingrediente, toca "Cancelar" para devolver el stock y compensar al alumno.',
      'skinId': 'insulini',
      'icono': Icons.notifications_active_rounded,
      'color': const Color(0xFFFF8F00),
    },
    {
      'badge': 'PASO 3 DE 4 • CONTROL DE STOCK',
      'titulo': 'Inventario y Local Abierto/Cerrado 📦',
      'descripcion':
          'Usa el botón superior Abierto/Cerrado para pausar pedidos al terminar el turno. En la pestaña "Mi Menú" ajusta tus existencias con [-] y [+] o sube hasta 3 fotos reales por platillo.',
      'skinId': 'ing_sistemas',
      'icono': Icons.inventory_2_rounded,
      'color': const Color(0xFF00B4D8),
    },
    {
      'badge': 'PASO 4 DE 4 • CORTE DE CAJA Y OPINIONES',
      'titulo': 'Historial y Reputación ⭐',
      'descripcion':
          'En la pestaña "Historial" consulta tu corte de caja (Efectivo vs. Terminal, entregados y cancelados). En "Opiniones" revisa las calificaciones públicas o anónimas de tu kiosko.',
      'skinId': 'oro',
      'icono': Icons.analytics_rounded,
      'color': const Color(0xFF8E24AA),
    },
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => StatefulBuilder(
          builder: (contextModal, setStateModal) {
            final pasoActual = pasos[paginaActual];
            final Color colorTema = pasoActual['color'] as Color;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorTema.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorTema.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pasoActual['badge'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colorTema,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Saltar',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorTextoGris,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: pageCtrl,
                        itemCount: pasos.length,
                        onPageChanged: (idx) {
                          HapticFeedback.selectionClick();
                          setStateModal(() => paginaActual = idx);
                        },
                        itemBuilder: (_, index) {
                          final item = pasos[index];
                          final PatoSkin skin = catalogoPatos.firstWhere(
                            (p) => p.id == item['skinId'],
                            orElse: () => catalogoPatos[4],
                          );
                          final Color cItem = item['color'] as Color;

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 6),
                                Container(
                                  width: 118,
                                  height: 118,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cItem.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: cItem.withValues(alpha: 0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: PatoVista(skin: skin, tamano: 92),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  item['titulo'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w900,
                                    color: colorTextoOscuro,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    item['descripcion'] as String,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: colorTextoGris,
                                      height: 1.42,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pasos.length, (i) {
                        final bool activo = i == paginaActual;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: activo ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activo ? colorTema : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (paginaActual > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorTextoOscuro,
                                side: BorderSide(color: Colors.grey.shade300),
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                pageCtrl.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              child: Text(
                                'Anterior',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorTema,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (paginaActual < pasos.length - 1) {
                                pageCtrl.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              } else {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(ctx);
                              }
                            },
                            icon: Icon(
                              paginaActual < pasos.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: Text(
                              paginaActual < pasos.length - 1
                                  ? 'Siguiente'
                                  : '¡A cocinar! 🍳',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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
  );
}

// ==========================================================
// 1. ACCESO DE SEGURIDAD A LOCALES
// ==========================================================
class LoginLocalScreen extends StatefulWidget {
  const LoginLocalScreen({super.key});

  @override
  State<LoginLocalScreen> createState() => _LoginLocalScreenState();
}

class _LoginLocalScreenState extends State<LoginLocalScreen> {
  final TextEditingController _codigoSucursalCtrl = TextEditingController();
  final TextEditingController _pinSecretoCtrl = TextEditingController();

  bool _ocultarPin = true;
  bool _validandoCredenciales = false;
  int _intentosFallidos = 0;
  DateTime? _bloqueadoHasta;

  final Map<String, Map<String, dynamic>> _credencialesIniciales = {
    'KS-SISTEMAS': {
      'nombre': 'Kiosko Sistemas',
      'pinSecreto': '849201',
      'ubicacion': 'Edificio de Ingeniería en Sistemas Computacionales',
      'activo': true,
      'abierto': true,
    },
    'KB-BIBLIO': {
      'nombre': 'Kiosko Biblioteca',
      'pinSecreto': '715309',
      'ubicacion': 'Explanada de Biblioteca Central',
      'activo': true,
      'abierto': true,
    },
    'CC-CENTRAL': {
      'nombre': 'Cafetería Central',
      'pinSecreto': '938420',
      'ubicacion': 'Comedor Principal del Campus TESE',
      'activo': true,
      'abierto': true,
    },
  };

  @override
  void initState() {
    super.initState();
    _inicializarCredencialesEnFirestore();
  }

  Future<void> _inicializarCredencialesEnFirestore() async {
    try {
      final col = FirebaseFirestore.instance.collection('Locales_Seguridad');
      for (final entrada in _credencialesIniciales.entries) {
        final docRef = col.doc(entrada.key);
        final docSnap = await docRef.get();
        if (!docSnap.exists) {
          await docRef.set({
            ...entrada.value,
            'codigoSucursal': entrada.key,
            'fechaCreacion': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _codigoSucursalCtrl.dispose();
    _pinSecretoCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresarAlKiosko() async {
    if (_bloqueadoHasta != null && DateTime.now().isBefore(_bloqueadoHasta!)) {
      final segRestantes =
          _bloqueadoHasta!.difference(DateTime.now()).inSeconds;
      _mostrarErrorSeguridad(
        'Terminal bloqueada temporalmente por seguridad. Intenta en $segRestantes segundos.',
      );
      return;
    }

    final String codigo = _codigoSucursalCtrl.text.trim().toUpperCase();
    final String pin = _pinSecretoCtrl.text.trim();

    if (codigo.isEmpty || pin.isEmpty) {
      _mostrarErrorSeguridad(
        'Ingresa tanto el Código de Sucursal como el PIN Maestro de 6 dígitos.',
      );
      return;
    }

    setState(() => _validandoCredenciales = true);
    HapticFeedback.lightImpact();

    if (!await verificarConexionInternet()) {
      setState(() => _validandoCredenciales = false);
      _mostrarErrorSeguridad(
        '📡 Sin conexión a Internet. Conéctate a una red para abrir la terminal.',
      );
      return;
    }

    try {
      String? nombreSucursalAutorizada;

      final doc = await FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .doc(codigo)
          .get()
          .timeout(const Duration(seconds: 8));

      if (doc.exists) {
        final data = doc.data()!;
        final bool activo = data['activo'] ?? true;
        final String pinReal = (data['pinSecreto'] ?? '').toString();

        if (!activo) {
          setState(() => _validandoCredenciales = false);
          _mostrarErrorSeguridad('Esta sucursal se encuentra deshabilitada.');
          return;
        }

        if (pinReal == pin) {
          nombreSucursalAutorizada = data['nombre'] as String?;
        }
      } else if (_credencialesIniciales.containsKey(codigo)) {
        final localData = _credencialesIniciales[codigo]!;
        if (localData['pinSecreto'] == pin) {
          nombreSucursalAutorizada = localData['nombre'] as String;
        }
      }

      if (!mounted) return;

      if (nombreSucursalAutorizada != null) {
        _intentosFallidos = 0;
        HapticFeedback.heavyImpact();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DashboardLocalScreen(
                  nombreLocal: nombreSucursalAutorizada!,
                  codigoSucursal: codigo,
                ),
          ),
        );
      } else {
        _intentosFallidos++;
        HapticFeedback.vibrate();
        if (_intentosFallidos >= 3) {
          _bloqueadoHasta = DateTime.now().add(const Duration(seconds: 30));
          _intentosFallidos = 0;
          _mostrarErrorSeguridad(
            'Demasiados intentos fallidos. Acceso bloqueado por 30 segundos.',
          );
        } else {
          _mostrarErrorSeguridad(
            'Credenciales inválidas. Verifica el código y tu PIN (${3 - _intentosFallidos} intentos restantes).',
          );
        }
      }
    } catch (e) {
      _mostrarErrorSeguridad(
        '📡 Error al conectar con el servidor de seguridad.',
      );
    } finally {
      if (mounted) setState(() => _validandoCredenciales = false);
    }
  }

  void _mostrarErrorSeguridad(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gpp_bad_outlined, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(mensaje, style: GoogleFonts.poppins(fontSize: 12.5)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _mostrarAyudaCredenciales() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: colorVerdeTese,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Directorio de Terminales KDS',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorTextoOscuro,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credenciales oficiales para evaluación del sistema multi-sucursal (Toca una tarjeta para autocompletar):',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorTextoGris,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._credencialesIniciales.entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: colorFondoCrema,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorVerdeTese.withValues(alpha: 0.25),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _codigoSucursalCtrl.text = e.key;
                            _pinSecretoCtrl.text = e.value['pinSecreto'];
                          });
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.value['nombre'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: colorVerdeTese,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Código: ${e.key}  •  PIN: ${e.value['pinSecreto']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: colorTextoOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.touch_app_outlined,
                                  color: colorVerdeTese,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.poppins(
                    color: colorVerdeTese,
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              onPressed: _mostrarAyudaCredenciales,
              icon: const Icon(
                Icons.vpn_key_outlined,
                color: colorVerdeTese,
                size: 16,
              ),
              label: Text(
                'Códigos',
                style: GoogleFonts.poppins(
                  color: colorVerdeTese,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorAmarilloTese, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorVerdeTese.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/patito_chef.png', height: 110),
                ),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: colorVerdeTese,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACCESO DE PERSONAL DE COCINA',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: colorVerdeTese,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                child: Text(
                  'Terminal de Cocina',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              Text(
                'Autenticación por doble credencial de sucursal',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                        '1. Identificador de Sucursal',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _codigoSucursalCtrl,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej. KS-SISTEMAS',
                          prefixIcon: const Icon(
                            Icons.storefront_outlined,
                            color: colorVerdeTese,
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '2. PIN Maestro de Seguridad (6 dígitos)',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pinSecretoCtrl,
                        obscureText: _ocultarPin,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        onSubmitted: (_) => _ingresarAlKiosko(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••••',
                          prefixIcon: const Icon(
                            Icons.pin_outlined,
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
                                () =>
                                    setState(() => _ocultarPin = !_ocultarPin),
                          ),
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed:
                              _validandoCredenciales ? null : _ingresarAlKiosko,
                          icon:
                              _validandoCredenciales
                                  ? const SizedBox.shrink()
                                  : const Icon(
                                    Icons.lock_open_rounded,
                                    color: Colors.white,
                                  ),
                          label:
                              _validandoCredenciales
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : Text(
                                    'Desbloquear Terminal',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
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

// ==========================================================
// 2. DASHBOARD DE CAFETERÍA CON FICHA ULTRA DETALLADA DE PEDIDOS
// ==========================================================
class DashboardLocalScreen extends StatefulWidget {
  final String nombreLocal;
  final String codigoSucursal;

  const DashboardLocalScreen({
    super.key,
    required this.nombreLocal,
    this.codigoSucursal = 'KS-SISTEMAS',
  });

  @override
  State<DashboardLocalScreen> createState() => _DashboardLocalScreenState();
}

class _DashboardLocalScreenState extends State<DashboardLocalScreen> {
  int _indicePestana = 0;
  int _filtroEstadoPedido = -1;
  String _busquedaFolio = '';
  final TextEditingController _buscadorFolioCtrl = TextEditingController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<QuerySnapshot>? _vigilanteNuevasComandas;
  final Set<String> _pedidosConocidos = {};
  bool _primeraCargaComandas = true;

  @override
  void initState() {
    super.initState();
    _iniciarVigilanteAudioCocina();
  }

  void _iniciarVigilanteAudioCocina() {
    _vigilanteNuevasComandas = FirebaseFirestore.instance
        .collection('Pedidos')
        .where('local', isEqualTo: widget.nombreLocal)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) async {
          if (_primeraCargaComandas) {
            for (var doc in snapshot.docs) {
              _pedidosConocidos.add(doc.id);
            }
            _primeraCargaComandas = false;
            return;
          }

          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added &&
                !change.doc.metadata.hasPendingWrites) {
              final idDoc = change.doc.id;
              if (!_pedidosConocidos.contains(idDoc)) {
                _pedidosConocidos.add(idDoc);
                final data = change.doc.data();
                if (data != null && (data['estado'] ?? 0) == 0) {
                  HapticFeedback.heavyImpact();
                  try {
                    await _audioPlayer.play(AssetSource('sonidos/exito.mp3'));
                  } catch (_) {}
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '🔔 ¡Nueva comanda recibida (${data['idPedido']}) de ${data['alumno']}!',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: colorVerdeTese,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            }
          }
        });
  }

  @override
  void dispose() {
    _vigilanteNuevasComandas?.cancel();
    _audioPlayer.dispose();
    _buscadorFolioCtrl.dispose();
    super.dispose();
  }

  // Formatea la hora de llegada y cuántos minutos lleva esperando el alumno
  String _formatearHoraYTiempoEspera(Timestamp? ts) {
    if (ts == null) return 'Recién recibido';
    final dt = ts.toDate();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final diff = DateTime.now().difference(dt).inMinutes;
    if (diff <= 0) return '$hh:$mm hrs • Hace un momento';
    if (diff < 60) return '$hh:$mm hrs • Hace $diff min';
    return '$hh:$mm hrs • ${dt.day}/${dt.month}';
  }

  // Cuenta cuántas piezas totales lleva el pedido para empacar fácil
  int _calcularTotalPiezas(Map<String, dynamic> p) {
    final mapaCant = p['cantidadesPorPlatillo'] as Map<String, dynamic>?;
    if (mapaCant != null && mapaCant.isNotEmpty) {
      int suma = 0;
      for (final v in mapaCant.values) {
        suma += (v as num).toInt();
      }
      if (suma > 0) return suma;
    }
    final String det = (p['detalle'] ?? '').toString();
    final lineas = det.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lineas.isEmpty ? 1 : lineas.length;
  }

  void _confirmarBloquearTerminal() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Bloquear Terminal?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: colorTextoOscuro,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Saldrás del panel de ${widget.nombreLocal} y necesitarás ingresar el PIN de seguridad nuevamente para ver las comandas.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Seguir en cocina',
                  style: GoogleFonts.poppins(
                    color: colorVerdeTese,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  'Bloquear y Salir',
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

  Future<void> _avanzarEstadoPedido(
    String docId,
    int estadoActual,
    String codigoOrden,
  ) async {
    if (estadoActual >= 3) return;
    HapticFeedback.mediumImpact();
    final int nuevoEstado = estadoActual + 1;

    await FirebaseFirestore.instance.collection('Pedidos').doc(docId).update({
      'estado': nuevoEstado,
    });

    if (!mounted) return;
    String textoAviso = 'Orden $codigoOrden pasó a preparación 🍳';
    if (nuevoEstado == 2) {
      textoAviso =
          '¡Orden $codigoOrden marcada como LISTA! Se notificó al alumno 🔔';
    } else if (nuevoEstado == 3) {
      textoAviso =
          'Orden $codigoOrden ENTREGADA. Puntos liberados al estudiante 🪙✅';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textoAviso, style: GoogleFonts.poppins(fontSize: 12.5)),
        backgroundColor: nuevoEstado == 3 ? colorExito : colorVerdeTese,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarModalCancelarPedidoCocina(
    String docId,
    Map<String, dynamic> pData,
  ) {
    final List<String> motivosRapidos = [
      'Se agotó un ingrediente principal del platillo 🥖',
      'Alta saturación en cocina / Tiempo excedido ⏳',
      'Cierre de turno de la cafetería 🔒',
      'Problema técnico en equipos de cocina 🔧',
    ];
    String motivoSeleccionado = motivosRapidos[0];
    final TextEditingController notaExtraCtrl = TextEditingController();
    bool cancelando = false;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.cancel_rounded,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelar ${pData['idPedido']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona la razón. El sistema devolverá el stock al menú y le abonará +10 pts 🪙 de disculpa al estudiante:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorTextoGris,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...motivosRapidos.map(
                        (m) => RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: Colors.redAccent,
                          title: Text(
                            m,
                            style: GoogleFonts.poppins(fontSize: 12.5),
                          ),
                          value: m,
                          groupValue: motivoSeleccionado,
                          onChanged:
                              (val) => setStateModal(
                                () => motivoSeleccionado = val!,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notaExtraCtrl,
                        decoration: InputDecoration(
                          labelText: 'Detalle adicional (opcional)',
                          hintText: 'Ej. Se terminó el jamón de pavo',
                          filled: true,
                          fillColor: colorFondoCrema,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: cancelando ? null : () => Navigator.pop(ctx),
                    child: Text(
                      'Volver',
                      style: GoogleFonts.poppins(color: colorTextoGris),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        cancelando
                            ? null
                            : () async {
                              setStateModal(() => cancelando = true);
                              final String extra = notaExtraCtrl.text.trim();
                              final String motivoFinal =
                                  extra.isNotEmpty
                                      ? '$motivoSeleccionado ($extra)'
                                      : motivoSeleccionado;

                              try {
                                await FirebaseFirestore.instance
                                    .collection('Pedidos')
                                    .doc(docId)
                                    .update({
                                      'estado': 4,
                                      'canceladoPor':
                                          'Cafetería (${widget.nombreLocal})',
                                      'motivoCancelacion': motivoFinal,
                                      'compensacionPts': 10,
                                    });

                                final List<dynamic> ids =
                                    pData['platillosIds'] ?? [];
                                final Map<String, dynamic> cantidadesMap =
                                    (pData['cantidadesPorPlatillo']
                                        as Map<String, dynamic>?) ??
                                    {};

                                for (var idPlatillo in ids) {
                                  final String pid = idPlatillo.toString();
                                  final int cantDevuelta =
                                      (cantidadesMap[pid] ?? 1) as int;
                                  await FirebaseFirestore.instance
                                      .collection('Menu_Platillos')
                                      .doc(pid)
                                      .update({
                                        'existencias': FieldValue.increment(
                                          cantDevuelta,
                                        ),
                                      })
                                      .catchError((_) {});
                                }

                                final String idAl =
                                    (pData['idAlumno'] ?? '').toString();
                                if (idAl.isNotEmpty && idAl != 'anonimo') {
                                  await FirebaseFirestore.instance
                                      .collection('Usuarios')
                                      .doc(idAl)
                                      .set({
                                        'puntosCompensacion':
                                            FieldValue.increment(10),
                                      }, SetOptions(merge: true));
                                }

                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pedido ${pData['idPedido']} cancelado. Stock devuelto y +10 pts abonados al alumno.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              } catch (_) {
                                setStateModal(() => cancelando = false);
                              }
                            },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Confirmar Cancelación',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  // 📋 FICHA COMPLETA DE DESPACHO (SIN OVERFLOW Y CON DATOS DEL ESTUDIANTE)
  void _mostrarDetallePedido(String docId, Map<String, dynamic> p) {
    final int estado = p['estado'] ?? 0;
    final String codigo = p['idPedido'] ?? '#TESE-0000';
    final String alumno = p['alumno'] ?? 'Estudiante';
    final String idAlumno = (p['idAlumno'] ?? '').toString();
    final String detalle = (p['detalle'] ?? '').toString();
    final List<String> lineasPlatillos =
        detalle.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final String notas = (p['notas'] ?? 'Sin notas adicionales').toString();
    final String pago = (p['metodoPago'] ?? 'Efectivo').toString();
    final bool esEfectivo = pago.toLowerCase().contains('efectivo');
    final double total = (p['total'] ?? 0.0).toDouble();
    final int puntos = (p['puntosGanados'] ?? 10) as int;
    final int totalPiezas = _calcularTotalPiezas(p);
    final String textoHora = _formatearHoraYTiempoEspera(
      p['horaLlegada'] as Timestamp?,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder:
          (ctx) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Encabezado Folio + Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              codigo,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: colorVerdeTese,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: colorTextoGris,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '$textoHora  •  ${widget.nombreLocal}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colorTextoGris,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _BadgeEstadoCocina(estado: estado),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tarjeta de Identificación del Cliente (Consulta Matrícula y Carrera en vivo)
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        idAlumno.isNotEmpty && idAlumno != 'anonimo'
                            ? FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(idAlumno)
                                .get()
                            : null,
                    builder: (context, userSnap) {
                      String matricula = 'Verificada en campus';
                      String carrera = 'Comunidad TESE';
                      String rol = 'Estudiante';
                      if (userSnap.hasData &&
                          userSnap.data != null &&
                          userSnap.data!.exists) {
                        final u = userSnap.data!.data() as Map<String, dynamic>;
                        matricula =
                            (u['identificador'] ?? matricula).toString();
                        carrera = (u['carrera_area'] ?? carrera).toString();
                        rol = (u['rol'] ?? rol).toString();
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.badge_rounded,
                                color: colorVerdeTese,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumno,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: colorTextoOscuro,
                                    ),
                                  ),
                                  Text(
                                    '$rol • Matrícula: $matricula',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: colorVerdeTese,
                                    ),
                                  ),
                                  Text(
                                    carrera,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: colorTextoGris,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Cabecera de platillos y conteo de piezas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Desglose para preparar:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6D6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$totalPiezas ${totalPiezas == 1 ? 'artículo' : 'artículos'} en total',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista individual de cada platillo y su personalización
                  ...lineasPlatillos.map((linea) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: colorFondoCrema,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 17,
                              color: colorVerdeTese,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              linea,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: colorTextoOscuro,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Notas o alertas médicas de alergia
                  if (notas.isNotEmpty && notas != 'Sin notas adicionales') ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.shade400,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Atención en cocina: $notas',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Tarjeta de Cobro en Ventanilla (100% libre de RIGHT OVERFLOW)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorFondoCrema,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            esEfectivo
                                ? Icons.payments_outlined
                                : Icons.credit_card_rounded,
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
                                'Cobro al entregar en ventanilla',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: colorTextoGris,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                esEfectivo
                                    ? 'Efectivo en ventanilla 💵'
                                    : 'Terminal Bancaria / Tarjeta 💳',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              Text(
                                'Libera +$puntos pts al entregarse',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '\$${total.toStringAsFixed(0)} MXN',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: colorVerdeTese,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Botones de acción amplios sin partir "Cancelar"
                  if (estado < 3)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                            minimumSize: const Size(118, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _mostrarModalCancelarPedidoCocina(docId, p);
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(
                            'Cancelar',
                            maxLines: 1,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  estado == 0
                                      ? Colors.orange.shade800
                                      : (estado == 1
                                          ? colorExito
                                          : colorVerdeTese),
                              minimumSize: const Size(0, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _avanzarEstadoPedido(docId, estado, codigo);
                            },
                            icon: Icon(
                              estado == 0
                                  ? Icons.soup_kitchen_outlined
                                  : (estado == 1
                                      ? Icons.notifications_active_outlined
                                      : Icons.check_circle_outline),
                              color: Colors.white,
                              size: 19,
                            ),
                            label: Text(
                              estado == 0
                                  ? 'Aceptar y Cocinar'
                                  : (estado == 1
                                      ? '¡Marcar LISTO!'
                                      : 'Entregar Orden'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmarBloquearTerminal();
        }
      },
      child: Scaffold(
        backgroundColor: colorFondoCrema,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: colorVerdeTese,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombreLocal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colorTextoOscuro,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      'Terminal ${widget.codigoSucursal}',
                      style: GoogleFonts.poppins(
                        color: colorVerdeTese,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Locales_Seguridad')
                      .doc(widget.codigoSucursal)
                      .snapshots(),
              builder: (context, snapLocal) {
                bool estaAbierto = true;
                if (snapLocal.hasData && snapLocal.data!.exists) {
                  final d = snapLocal.data!.data() as Map<String, dynamic>;
                  estaAbierto = d['abierto'] ?? true;
                }
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    FirebaseFirestore.instance
                        .collection('Locales_Seguridad')
                        .doc(widget.codigoSucursal)
                        .set({
                          'nombre': widget.nombreLocal,
                          'abierto': !estaAbierto,
                        }, SetOptions(merge: true));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          estaAbierto
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: estaAbierto ? colorExito : Colors.redAccent,
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: estaAbierto ? colorExito : Colors.redAccent,
                          size: 9,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          estaAbierto ? 'Abierto' : 'Cerrado',
                          style: GoogleFonts.poppins(
                            color:
                                estaAbierto ? colorVerdeTese : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Guía de Cocina',
              icon: const Icon(
                Icons.help_outline_rounded,
                color: colorVerdeTese,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                mostrarTutorialCocina(context, widget.nombreLocal);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                tooltip: 'Bloquear Terminal',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                ),
                icon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: _confirmarBloquearTerminal,
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _indicePestana,
          children: [
            _construirTabComandas(),
            _construirTabMenu(),
            _construirTabHistorial(),
            _construirTabResenas(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indicePestana,
          selectedItemColor: colorVerdeTese,
          unselectedItemColor: colorTextoGris,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10.5),
          onTap: (idx) {
            HapticFeedback.selectionClick();
            setState(() => _indicePestana = idx);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Comandas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Mi Menú',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu_rounded),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reviews_outlined),
              label: 'Opiniones',
            ),
          ],
        ),
        floatingActionButton:
            _indicePestana == 1
                ? FloatingActionButton.extended(
                  backgroundColor: colorAmarilloTese,
                  icon: const Icon(Icons.add_rounded, color: colorVerdeOscuro),
                  label: Text(
                    'Nuevo Platillo',
                    style: GoogleFonts.poppins(
                      color: colorVerdeOscuro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AgregarPlatilloScreen(
                              localAsignado: widget.nombreLocal,
                            ),
                      ),
                    );
                  },
                )
                : null,
      ),
    );
  }

  Widget _construirTabComandas() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final List<QueryDocumentSnapshot> pedidosActivos = [];
        int contNuevos = 0;
        int contCocinando = 0;
        int contListos = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final int est = data['estado'] ?? 0;
          if (est == 0) contNuevos++;
          if (est == 1) contCocinando++;
          if (est == 2) contListos++;
          if (est < 3) {
            final String codigo =
                (data['idPedido'] ?? '').toString().toUpperCase();
            final String alumno =
                (data['alumno'] ?? '').toString().toUpperCase();
            final bool coincideBusqueda =
                _busquedaFolio.isEmpty ||
                codigo.contains(_busquedaFolio.toUpperCase()) ||
                alumno.contains(_busquedaFolio.toUpperCase());

            if (coincideBusqueda &&
                (_filtroEstadoPedido == -1 || est == _filtroEstadoPedido)) {
              pedidosActivos.add(doc);
            }
          }
        }

        pedidosActivos.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final ta = da['horaLlegada'] as Timestamp?;
          final tb = db['horaLlegada'] as Timestamp?;
          if (ta == null || tb == null) return 0;
          return ta.compareTo(tb);
        });

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ChipContadorKDS(
                        titulo: 'Todos',
                        cantidad: contNuevos + contCocinando + contListos,
                        color: colorVerdeTese,
                        seleccionado: _filtroEstadoPedido == -1,
                        onTap: () => setState(() => _filtroEstadoPedido = -1),
                      ),
                      const SizedBox(width: 6),
                      _ChipContadorKDS(
                        titulo: 'Nuevos',
                        cantidad: contNuevos,
                        color: const Color(0xFFE53935),
                        seleccionado: _filtroEstadoPedido == 0,
                        onTap: () => setState(() => _filtroEstadoPedido = 0),
                      ),
                      const SizedBox(width: 6),
                      _ChipContadorKDS(
                        titulo: 'En Cocina',
                        cantidad: contCocinando,
                        color: const Color(0xFFF57C00),
                        seleccionado: _filtroEstadoPedido == 1,
                        onTap: () => setState(() => _filtroEstadoPedido = 1),
                      ),
                      const SizedBox(width: 6),
                      _ChipContadorKDS(
                        titulo: 'Listos',
                        cantidad: contListos,
                        color: colorExito,
                        seleccionado: _filtroEstadoPedido == 2,
                        onTap: () => setState(() => _filtroEstadoPedido = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _buscadorFolioCtrl,
                      onChanged:
                          (v) => setState(() => _busquedaFolio = v.trim()),
                      decoration: InputDecoration(
                        hintText:
                            'Buscar folio #TESE-XXXX o nombre del alumno...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorTextoGris,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: colorVerdeTese,
                          size: 19,
                        ),
                        suffixIcon:
                            _busquedaFolio.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear, size: 17),
                                  onPressed: () {
                                    _buscadorFolioCtrl.clear();
                                    setState(() => _busquedaFolio = '');
                                  },
                                )
                                : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  pedidosActivos.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 54,
                                color: colorVerdeTese,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sin comandas pendientes en esta vista',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorTextoOscuro,
                              ),
                            ),
                            Text(
                              'Solo se muestran órdenes de ${widget.nombreLocal}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorTextoGris,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: pedidosActivos.length,
                        itemBuilder: (context, index) {
                          final doc = pedidosActivos[index];
                          final p = doc.data() as Map<String, dynamic>;
                          final int estado = p['estado'] ?? 0;
                          final String codigo = p['idPedido'] ?? '#TESE';
                          final String alumno = p['alumno'] ?? 'Estudiante';
                          final String detalle =
                              (p['detalle'] ?? '').toString();
                          final List<String> lineas =
                              detalle
                                  .split('\n')
                                  .where((l) => l.trim().isNotEmpty)
                                  .toList();
                          final String notas = (p['notas'] ?? '').toString();
                          final String pago =
                              (p['metodoPago'] ?? 'Efectivo').toString();
                          final bool esEfectivo = pago.toLowerCase().contains(
                            'efectivo',
                          );
                          final double total = (p['total'] ?? 0.0).toDouble();
                          final int totalPiezas = _calcularTotalPiezas(p);
                          final String horaTexto = _formatearHoraYTiempoEspera(
                            p['horaLlegada'] as Timestamp?,
                          );

                          Color colorBorde = const Color(0xFFE53935);
                          if (estado == 1) colorBorde = const Color(0xFFF57C00);
                          if (estado == 2) colorBorde = colorExito;

                          return FadeInUp(
                            duration: const Duration(milliseconds: 220),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorBorde.withValues(alpha: 0.5),
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorBorde.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _mostrarDetallePedido(doc.id, p),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Fila 1: Código + Hora de llegada + Estado
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  codigo,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w900,
                                                    color: colorTextoOscuro,
                                                  ),
                                                ),
                                                Text(
                                                  '🕒 $horaTexto',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: colorTextoGris,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _BadgeEstadoCocina(estado: estado),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Fila 2: Cliente y cantidad total de piezas
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '👤 $alumno',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: colorVerdeTese,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$totalPiezas ${totalPiezas == 1 ? 'pieza' : 'piezas'}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: colorVerdeTese,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      // Desglose claro por platillo
                                      ...lineas.map((l) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '🍽️ ',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  l,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorTextoOscuro,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (notas.isNotEmpty &&
                                          notas != 'Sin notas adicionales') ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF8E1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.amber.shade400,
                                            ),
                                          ),
                                          child: Text(
                                            '⚠️ $notas',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      // Fila inferior de cobro y acciones (sin overflow)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorFondoCrema,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${esEfectivo ? '💵 Efectivo' : '💳 Tarjeta'} • \$${total.toStringAsFixed(0)} MXN',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: colorTextoOscuro,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            tooltip: 'Cancelar Pedido',
                                            onPressed:
                                                () =>
                                                    _mostrarModalCancelarPedidoCocina(
                                                      doc.id,
                                                      p,
                                                    ),
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colorBorde,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onPressed:
                                                () => _avanzarEstadoPedido(
                                                  doc.id,
                                                  estado,
                                                  codigo,
                                                ),
                                            icon: Icon(
                                              estado == 0
                                                  ? Icons
                                                      .local_fire_department_rounded
                                                  : (estado == 1
                                                      ? Icons
                                                          .notifications_active
                                                      : Icons.done_all),
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            label: Text(
                                              estado == 0
                                                  ? 'Aceptar y Cocinar'
                                                  : (estado == 1
                                                      ? '¡Marcar Listo!'
                                                      : 'Entregar'),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
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

  Widget _construirTabMenu() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lunch_dining_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no tienes platillos en ${widget.nombreLocal}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca el botón amarillo "+ Nuevo Platillo" para registrar tu menú.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: colorTextoGris,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final platillo = Platillo.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          platillo.fotos.isNotEmpty
                              ? Image.memory(
                                base64Decode(platillo.fotos.first),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _iconoPlatilloDefault(),
                              )
                              : _iconoPlatilloDefault(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platillo.nombre,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: colorTextoOscuro,
                            ),
                          ),
                          Text(
                            '\$${platillo.precio.toStringAsFixed(0)} MXN • ${platillo.categoria}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: colorVerdeTese,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (platillo.existencias > 0) {
                                    FirebaseFirestore.instance
                                        .collection('Menu_Platillos')
                                        .doc(platillo.id)
                                        .update({
                                          'existencias':
                                              platillo.existencias - 1,
                                        });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  platillo.existencias > 0
                                      ? 'Stock: ${platillo.existencias}'
                                      : 'AGOTADO',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        platillo.existencias > 0
                                            ? colorExito
                                            : Colors.red,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FirebaseFirestore.instance
                                      .collection('Menu_Platillos')
                                      .doc(platillo.id)
                                      .update({
                                        'existencias': platillo.existencias + 1,
                                      });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: colorVerdeTese,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: colorVerdeTese,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AgregarPlatilloScreen(
                                      platilloAEditar: platillo,
                                      localAsignado: widget.nombreLocal,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Menu_Platillos')
                                .doc(platillo.id)
                                .delete();
                          },
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

  Widget _iconoPlatilloDefault() {
    return Container(
      width: 64,
      height: 64,
      color: colorFondoCrema,
      child: const Icon(
        Icons.fastfood_rounded,
        color: colorVerdeTese,
        size: 30,
      ),
    );
  }

  Widget _construirTabHistorial() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Pedidos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final List<QueryDocumentSnapshot> historial = [];

        double totalVendido = 0.0;
        double totalEfectivo = 0.0;
        double totalTerminal = 0.0;
        int entregadosCount = 0;
        int canceladosCount = 0;

        for (var doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          final int est = d['estado'] ?? 0;
          if (est == 3 || est == 4) {
            historial.add(doc);
            final double monto = (d['total'] ?? 0.0).toDouble();
            final String metodo = (d['metodoPago'] ?? 'Efectivo').toString();

            if (est == 3) {
              entregadosCount++;
              totalVendido += monto;
              if (metodo.contains('Efectivo')) {
                totalEfectivo += monto;
              } else {
                totalTerminal += monto;
              }
            } else if (est == 4) {
              canceladosCount++;
            }
          }
        }

        historial.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final ta = da['horaLlegada'] as Timestamp?;
          final tb = db['horaLlegada'] as Timestamp?;
          if (ta == null || tb == null) return 0;
          return tb.compareTo(ta);
        });

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Corte de Caja • ${widget.nombreLocal}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: colorTextoOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaResumenCaja(
                          titulo: 'Total Vendido',
                          valor: '\$${totalVendido.toStringAsFixed(0)}',
                          subtitulo: '$entregadosCount entregados',
                          color: colorVerdeTese,
                          icono: Icons.monetization_on_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TarjetaResumenCaja(
                          titulo: 'Efectivo / Tarjeta',
                          valor:
                              '\$${totalEfectivo.toStringAsFixed(0)} / \$${totalTerminal.toStringAsFixed(0)}',
                          subtitulo: 'Desglose cobro',
                          color: const Color(0xFF0077B6),
                          icono: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TarjetaResumenCaja(
                          titulo: 'Cancelados',
                          valor: '$canceladosCount',
                          subtitulo: 'Con stock devuelto',
                          color: Colors.redAccent,
                          icono: Icons.cancel_presentation_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  historial.isEmpty
                      ? Center(
                        child: Text(
                          'Aún no hay pedidos finalizados o cancelados en esta sucursal.',
                          style: GoogleFonts.poppins(
                            color: colorTextoGris,
                            fontSize: 13,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: historial.length,
                        itemBuilder: (context, index) {
                          final p =
                              historial[index].data() as Map<String, dynamic>;
                          final int est = p['estado'] ?? 3;
                          final bool fueCancelado = est == 4;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    fueCancelado
                                        ? Colors.redAccent.withValues(
                                          alpha: 0.35,
                                        )
                                        : colorExito.withValues(alpha: 0.35),
                              ),
                            ),
                            child: ListTile(
                              onTap:
                                  () => _mostrarDetallePedido(
                                    historial[index].id,
                                    p,
                                  ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    fueCancelado
                                        ? Colors.red.shade50
                                        : const Color(0xFFE8F5E9),
                                child: Icon(
                                  fueCancelado
                                      ? Icons.cancel_outlined
                                      : Icons.check_circle_outline,
                                  color:
                                      fueCancelado
                                          ? Colors.redAccent
                                          : colorExito,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${p['idPedido'] ?? '#TESE'} • ${p['alumno'] ?? 'Alumno'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '\$${(p['total'] ?? 0).toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color:
                                          fueCancelado
                                              ? Colors.redAccent
                                              : colorVerdeTese,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['detalle'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 11.5),
                                  ),
                                  if (fueCancelado)
                                    Text(
                                      'Cancelado por ${p['canceladoPor'] ?? 'Cocina'}: ${p['motivoCancelacion'] ?? ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
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

  Widget _construirTabResenas() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Menu_Platillos')
              .where('local', isEqualTo: widget.nombreLocal)
              .snapshots(),
      builder: (context, menuSnap) {
        if (menuSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorVerdeTese),
          );
        }

        final docsMenu = menuSnap.data?.docs ?? [];
        final Set<String> idsDeMiSucursal = docsMenu.map((d) => d.id).toSet();
        final Set<String> nombresDeMiSucursal =
            docsMenu
                .map(
                  (d) =>
                      ((d.data() as Map<String, dynamic>)['nombre'] ?? '')
                          .toString(),
                )
                .toSet();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Resenas').snapshots(),
          builder: (context, resSnap) {
            if (resSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: colorVerdeTese),
              );
            }

            final todasLasResenas = resSnap.data?.docs ?? [];
            final resenasSucursal =
                todasLasResenas.where((doc) {
                  final r = doc.data() as Map<String, dynamic>;
                  final String localResena = (r['local'] ?? '').toString();
                  final String platilloId = (r['platilloId'] ?? '').toString();
                  final String platilloNombre =
                      (r['platilloNombre'] ?? '').toString();

                  if (localResena.isNotEmpty) {
                    return localResena == widget.nombreLocal;
                  }
                  return idsDeMiSucursal.contains(platilloId) ||
                      nombresDeMiSucursal.contains(platilloNombre);
                }).toList();

            if (resenasSucursal.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aún no hay reseñas para ${widget.nombreLocal}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorTextoGris,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            double sumaEstrellas = 0;
            for (var doc in resenasSucursal) {
              final r = doc.data() as Map<String, dynamic>;
              sumaEstrellas += (r['estrellas'] ?? 5).toDouble();
            }
            final double promedioSucursal =
                sumaEstrellas / resenasSucursal.length;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFD7EFE0)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorVerdeTese.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reputación de ${widget.nombreLocal}',
                              style: GoogleFonts.poppins(
                                color: colorTextoOscuro,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Basado en ${resenasSucursal.length} opiniones verificadas',
                              style: GoogleFonts.poppins(
                                color: colorTextoGris,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorAmarilloTese,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: colorVerdeOscuro,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              promedioSucursal.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: colorVerdeOscuro,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: resenasSucursal.length,
                    itemBuilder: (context, index) {
                      final r =
                          resenasSucursal[index].data() as Map<String, dynamic>;
                      final int estrellas = r['estrellas'] ?? 5;
                      final String fotoEvidencia =
                          (r['fotoEvidencia'] ?? '').toString();
                      final bool esAnon =
                          r['esAnonimo'] == true ||
                          (r['alumno'] ?? '').toString().toLowerCase().contains(
                            'anónimo',
                          );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r['platilloNombre'] ?? 'Platillo',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: colorVerdeTese,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < estrellas
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: colorAmarilloTese,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                r['comentario'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              if (fotoEvidencia.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(fotoEvidencia),
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                'Por: ${esAnon ? 'Estudiante Anónimo 🕵️‍♂️' : (r['alumno'] ?? 'Estudiante')} ${r['codigoPedido'] != null ? '• Orden ${r['codigoPedido']}' : ''}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorTextoGris,
                                ),
                              ),
                            ],
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
      },
    );
  }
}

class _TarjetaResumenCaja extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final Color color;
  final IconData icono;

  const _TarjetaResumenCaja({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 15, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: colorTextoOscuro,
            ),
          ),
          Text(
            subtitulo,
            style: GoogleFonts.poppins(fontSize: 9.5, color: colorTextoGris),
          ),
        ],
      ),
    );
  }
}

class _BadgeEstadoCocina extends StatelessWidget {
  final int estado;
  const _BadgeEstadoCocina({required this.estado});

  @override
  Widget build(BuildContext context) {
    String texto = 'NUEVO';
    Color color = const Color(0xFFE53935);
    if (estado == 1) {
      texto = 'EN COCINA';
      color = const Color(0xFFF57C00);
    } else if (estado == 2) {
      texto = 'LISTO PARA RECOGER';
      color = colorExito;
    } else if (estado == 3) {
      texto = 'ENTREGADO';
      color = colorVerdeTese;
    } else if (estado == 4) {
      texto = 'CANCELADO';
      color = Colors.red.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ChipContadorKDS extends StatelessWidget {
  final String titulo;
  final int cantidad;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipContadorKDS({
    required this.titulo,
    required this.cantidad,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                seleccionado ? color.withValues(alpha: 0.15) : colorFondoCrema,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? color : Colors.grey.shade200,
              width: seleccionado ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$cantidad',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorTextoOscuro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 3. ALTA Y EDICIÓN DE PLATILLOS
// ==========================================================
class AgregarPlatilloScreen extends StatefulWidget {
  final Platillo? platilloAEditar;
  final String localAsignado;

  const AgregarPlatilloScreen({
    super.key,
    this.platilloAEditar,
    required this.localAsignado,
  });

  @override
  State<AgregarPlatilloScreen> createState() => _AgregarPlatilloScreenState();
}

class _AgregarPlatilloScreenState extends State<AgregarPlatilloScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _tiempoCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();
  final TextEditingController _puntosCtrl = TextEditingController();
  final TextEditingController _ingredienteExtraCtrl = TextEditingController();

  String categoriaSeleccionada = 'Comida';
  final List<String> categorias = ['Desayunos', 'Comida', 'Bebidas', 'Postres'];

  List<String> _fotosBase64 = [];
  List<String> _ingredientes = ['Queso', 'Crema', 'Salsa', 'Cebolla'];
  bool _guardando = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.platilloAEditar != null) {
      final p = widget.platilloAEditar!;
      _nombreCtrl.text = p.nombre;
      _precioCtrl.text = p.precio.toStringAsFixed(0);
      _descCtrl.text = p.descripcion;
      _tiempoCtrl.text = p.tiempo;
      _stockCtrl.text = p.existencias.toString();
      _puntosCtrl.text = p.puntos.toString();
      if (categorias.contains(p.categoria)) {
        categoriaSeleccionada = p.categoria;
      }
      _fotosBase64 = List<String>.from(p.fotos);
      _ingredientes = List<String>.from(p.ingredientes);
    } else {
      _tiempoCtrl.text = '10 - 15 min';
      _stockCtrl.text = '15';
      _puntosCtrl.text = '10';
    }
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    if (_fotosBase64.length >= 3) return;
    try {
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 55,
      );
      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        setState(() => _fotosBase64.add(base64Encode(bytes)));
      }
    } catch (_) {}
  }

  Future<void> _guardarPlatillo() async {
    final nombre = _nombreCtrl.text.trim();
    final double precio = double.tryParse(_precioCtrl.text.trim()) ?? 0.0;
    final int stock = int.tryParse(_stockCtrl.text.trim()) ?? -1;
    final int puntos = int.tryParse(_puntosCtrl.text.trim()) ?? 0;

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del platillo.')),
      );
      return;
    }

    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio debe ser mayor a \$0 MXN.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las existencias no pueden ser negativas.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final datos = {
      'nombre': nombre,
      'local': widget.localAsignado,
      'precio': precio,
      'descripcion':
          _descCtrl.text.trim().isEmpty
              ? 'Preparado al momento en ${widget.localAsignado}'
              : _descCtrl.text.trim(),
      'tiempo':
          _tiempoCtrl.text.trim().isEmpty ? '10 min' : _tiempoCtrl.text.trim(),
      'tiempoPreparacion':
          _tiempoCtrl.text.trim().isEmpty ? '10 min' : _tiempoCtrl.text.trim(),
      'categoria': categoriaSeleccionada,
      'existencias': stock,
      'puntos': puntos <= 0 ? 10 : puntos,
      'fotos': _fotosBase64,
      'ingredientes': _ingredientes,
      'calificacion': widget.platilloAEditar?.calificacion ?? 5.0,
      'numCalificaciones': widget.platilloAEditar?.numCalificaciones ?? 1,
    };

    try {
      if (widget.platilloAEditar == null) {
        await FirebaseFirestore.instance
            .collection('Menu_Platillos')
            .add(datos);
      } else {
        await FirebaseFirestore.instance
            .collection('Menu_Platillos')
            .doc(widget.platilloAEditar!.id)
            .update(datos);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.platilloAEditar != null;

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
        title: Text(
          esEdicion ? 'Editar Platillo' : 'Nuevo en ${widget.localAsignado}',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fotografías del Platillo (Máx. 3)',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ..._fotosBase64.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(entry.value)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 12,
                        child: GestureDetector(
                          onTap:
                              () => setState(
                                () => _fotosBase64.removeAt(entry.key),
                              ),
                          child: const CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_fotosBase64.length < 3) ...[
                  IconButton.filledTonal(
                    onPressed: () => _seleccionarImagen(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _seleccionarImagen(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del Platillo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio (\$ MXN)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Existencias (Stock)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
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
                  child: DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items:
                        categorias
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged:
                        (v) => setState(() => categoriaSeleccionada = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _puntosCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Puntos que otorga 🪙',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tiempoCtrl,
              decoration: InputDecoration(
                labelText: 'Tiempo estimado (ej. 10 - 15 min)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descripción del platillo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredientes personalizables:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children:
                  _ingredientes
                      .map(
                        (ing) => Chip(
                          label: Text(ing),
                          onDeleted:
                              () => setState(() => _ingredientes.remove(ing)),
                        ),
                      )
                      .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredienteExtraCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Agregar ingrediente (ej. Aguacate)',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: colorVerdeTese),
                  onPressed: () {
                    final txt = _ingredienteExtraCtrl.text.trim();
                    if (txt.isNotEmpty) {
                      setState(() {
                        _ingredientes.add(txt);
                        _ingredienteExtraCtrl.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _guardando ? null : _guardarPlatillo,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  esEdicion
                      ? 'Guardar Cambios'
                      : 'Publicar en ${widget.localAsignado}',
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
  }
}
