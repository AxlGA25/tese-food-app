import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colores.dart';
import 'pantalla_admin.dart';

/// Gestiona la huella única local del dispositivo para la política de 1 terminal por sucursal
class ServicioDispositivoTerminal {
  static const String _keyDeviceId = 'tese_kds_device_id';
  static const String _keyLocalDocId = 'tese_kds_local_doc_id';

  static Future<String> obtenerOCrearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keyDeviceId);
    if (id == null || id.isEmpty) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rnd = Random.secure();
      id =
          'DEV-${List.generate(16, (_) => chars[rnd.nextInt(chars.length)]).join()}';
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  static Future<void> guardarSucursalLocal(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocalDocId, docId);
  }

  static Future<String?> obtenerSucursalLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocalDocId);
  }

  static Future<void> limpiarVinculacionLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLocalDocId);
  }
}

/// Pantalla de Acceso Seguro para Cafeterías (1 Dispositivo por QR) + Acceso Admin
class PantallaAccesoQR extends StatefulWidget {
  /// Callback que se ejecuta cuando la terminal está autorizada para abrir tu DashboardLocalScreen
  final void Function(
    String docId,
    String nombreSucursal,
    String codigoSucursal,
  )
  onTerminalAutorizada;

  const PantallaAccesoQR({super.key, required this.onTerminalAutorizada});

  @override
  State<PantallaAccesoQR> createState() => _PantallaAccesoQRState();
}

class _PantallaAccesoQRState extends State<PantallaAccesoQR> {
  bool _verificandoDispositivo = true;
  bool _procesandoQR = false;

  String? _miDeviceId;
  String? _docIdVinculado;
  String? _nombreSucursalVinculada;
  String? _codigoSucursalVinculada;

  // Control de fuerza bruta para el Acceso Admin
  int _intentosAdminFallidos = 0;
  DateTime? _bloqueoAdminHasta;

  @override
  void initState() {
    super.initState();
    _verificarSiEsteDispositivoEstaVinculado();
  }

  Future<void> _verificarSiEsteDispositivoEstaVinculado() async {
    setState(() => _verificandoDispositivo = true);
    try {
      final deviceId =
          await ServicioDispositivoTerminal.obtenerOCrearDeviceId();
      final docGuardado =
          await ServicioDispositivoTerminal.obtenerSucursalLocal();
      _miDeviceId = deviceId;

      if (docGuardado != null && docGuardado.isNotEmpty) {
        final snap =
            await FirebaseFirestore.instance
                .collection('Locales_Seguridad')
                .doc(docGuardado)
                .get();

        if (snap.exists) {
          final data = snap.data()!;
          final String? autorizadoEnNube =
              data['dispositivoAutorizadoId'] as String?;

          if (autorizadoEnNube == deviceId) {
            if (mounted) {
              setState(() {
                _docIdVinculado = snap.id;
                _nombreSucursalVinculada =
                    (data['nombre'] ?? snap.id).toString();
                _codigoSucursalVinculada =
                    (data['codigo'] ?? snap.id).toString();
                _verificandoDispositivo = false;
              });
            }
            return;
          } else {
            // El Admin expulsó este dispositivo o vinculó otro distinto
            await ServicioDispositivoTerminal.limpiarVinculacionLocal();
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _docIdVinculado = null;
        _nombreSucursalVinculada = null;
        _codigoSucursalVinculada = null;
        _verificandoDispositivo = false;
      });
    }
  }

  Future<void> _abrirEscanerCamara() async {
    final String? resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _EscanerCamaraQRScreen()),
    );
    if (resultado != null && resultado.isNotEmpty) {
      await _procesarContenidoQR(resultado);
    }
  }

  Future<void> _cargarQRDesdeGaleria() async {
    if (_procesandoQR) return;
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    if (imagen == null) return;

    setState(() => _procesandoQR = true);
    final MobileScannerController ctrl = MobileScannerController();
    try {
      final BarcodeCapture? capture = await ctrl.analyzeImage(imagen.path);
      if (capture != null &&
          capture.barcodes.isNotEmpty &&
          capture.barcodes.first.rawValue != null) {
        await _procesarContenidoQR(capture.barcodes.first.rawValue!);
      } else {
        _mostrarMensaje(
          'No se detectó ningún código QR válido en la imagen seleccionada.',
          esError: true,
        );
      }
    } catch (_) {
      _mostrarMensaje(
        'No se pudo leer la imagen. Asegúrate de que el QR sea nítido.',
        esError: true,
      );
    } finally {
      await ctrl.dispose();
      if (mounted) setState(() => _procesandoQR = false);
    }
  }

  Future<void> _procesarContenidoQR(String rawQR) async {
    setState(() => _procesandoQR = true);
    HapticFeedback.mediumImpact();

    try {
      final dynamic decoded = jsonDecode(rawQR);
      if (decoded is! Map<String, dynamic> ||
          decoded['app'] != 'TESE_HAMBREADOS_KDS') {
        _mostrarMensaje(
          'Código QR no reconocido. Solicita una llave oficial al Administrador.',
          esError: true,
        );
        return;
      }

      final String docId = (decoded['docId'] ?? '').toString();
      final String tokenRecibido = (decoded['token'] ?? '').toString();
      if (docId.isEmpty || tokenRecibido.isEmpty) {
        _mostrarMensaje(
          'El código QR está incompleto o dañado.',
          esError: true,
        );
        return;
      }

      final String miDeviceId =
          _miDeviceId ??
          await ServicioDispositivoTerminal.obtenerOCrearDeviceId();

      final docRef = FirebaseFirestore.instance
          .collection('Locales_Seguridad')
          .doc(docId);

      String nombreLocal = docId;
      String codigoLocal = docId;

      // Transacción atómica para garantizar 1 solo uso y 1 solo dispositivo
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          throw Exception('La sucursal indicada no existe.');
        }

        final data = snap.data()!;
        final String? tokenNube = data['qrTokenTemporal'] as String?;
        final bool qrUsado = (data['qrUsado'] ?? true) as bool;
        final Timestamp? expiraTs = data['qrExpiraEn'] as Timestamp?;

        if (qrUsado || tokenNube == null || tokenNube != tokenRecibido) {
          throw Exception(
            'Este código QR ya fue utilizado o revocado. Pide uno nuevo al Administrador.',
          );
        }

        if (expiraTs == null || DateTime.now().isAfter(expiraTs.toDate())) {
          throw Exception(
            'Este código QR expiró (vigencia de 5 min). Solicita uno nuevo.',
          );
        }

        nombreLocal = (data['nombre'] ?? docId).toString();
        codigoLocal = (data['codigo'] ?? docId).toString();

        tx.set(docRef, {
          'dispositivoAutorizadoId': miDeviceId,
          'dispositivoNombre': 'Terminal $nombreLocal',
          'vinculadoEn': FieldValue.serverTimestamp(),
          'qrUsado': true,
          'qrTokenTemporal': FieldValue.delete(),
        }, SetOptions(merge: true));
      });

      await ServicioDispositivoTerminal.guardarSucursalLocal(docId);
      HapticFeedback.heavyImpact();

      if (!mounted) return;
      setState(() {
        _docIdVinculado = docId;
        _nombreSucursalVinculada = nombreLocal;
        _codigoSucursalVinculada = codigoLocal;
      });

      _mostrarMensaje(
        '✅ Terminal vinculada con éxito a $nombreLocal.',
        esError: false,
      );

      widget.onTerminalAutorizada(docId, nombreLocal, codigoLocal);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _mostrarMensaje(msg, esError: true);
    } finally {
      if (mounted) setState(() => _procesandoQR = false);
    }
  }

  void _abrirModalAccesoAdmin() {
    final TextEditingController claveCtrl = TextEditingController();
    final TextEditingController pinCtrl = TextEditingController();
    bool validando = false;
    String? errorLocal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setStateModal) {
              final bool bloqueado =
                  _bloqueoAdminHasta != null &&
                  DateTime.now().isBefore(_bloqueoAdminHasta!);

              return Padding(
                padding: EdgeInsets.only(
                  left: 22,
                  right: 22,
                  top: 16,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: colorVerdeTese,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acceso Administrativo 🛡️',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              Text(
                                'Control de llaves QR, ventas y buzón de quejas',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: colorTextoGris,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: claveCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Clave de Administrador',
                        hintText: 'Ej. ADMIN-TESE',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: pinCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'PIN Maestro (6 dígitos)',
                        counterText: '',
                        prefixIcon: const Icon(
                          Icons.pin_outlined,
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
                    if (errorLocal != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorLocal!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            (validando || bloqueado)
                                ? null
                                : () async {
                                  setStateModal(() {
                                    validando = true;
                                    errorLocal = null;
                                  });

                                  final String clave =
                                      claveCtrl.text.trim().toUpperCase();
                                  final String pin = pinCtrl.text.trim();

                                  // Lee credenciales de Config_Admin/acceso en Firestore
                                  // (con respaldo inicial ADMIN-TESE / 202699 si aún no se crea el documento)
                                  String claveValida = 'ADMIN-TESE';
                                  String pinValido = '202699';
                                  try {
                                    final doc =
                                        await FirebaseFirestore.instance
                                            .collection('Config_Admin')
                                            .doc('acceso')
                                            .get();
                                    if (doc.exists && doc.data() != null) {
                                      claveValida =
                                          (doc.data()!['clave'] ?? claveValida)
                                              .toString()
                                              .toUpperCase();
                                      pinValido =
                                          (doc.data()!['pin'] ?? pinValido)
                                              .toString();
                                    }
                                  } catch (_) {}

                                  if (clave == claveValida &&
                                      pin == pinValido) {
                                    _intentosAdminFallidos = 0;
                                    HapticFeedback.heavyImpact();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const DashboardAdminScreen(),
                                      ),
                                    );
                                  } else {
                                    HapticFeedback.vibrate();
                                    _intentosAdminFallidos++;
                                    if (_intentosAdminFallidos >= 3) {
                                      _bloqueoAdminHasta = DateTime.now().add(
                                        const Duration(seconds: 30),
                                      );
                                      _intentosAdminFallidos = 0;
                                      setStateModal(() {
                                        validando = false;
                                        errorLocal =
                                            '🔒 Demasiados intentos. Acceso bloqueado por 30 segundos.';
                                      });
                                    } else {
                                      setStateModal(() {
                                        validando = false;
                                        errorLocal =
                                            '❌ Credenciales incorrectas (${3 - _intentosAdminFallidos} intentos restantes).';
                                      });
                                    }
                                  }
                                },
                        icon: const Icon(
                          Icons.lock_open_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                        label: Text(
                          bloqueado
                              ? 'Bloqueado temporalmente...'
                              : (validando
                                  ? 'Verificando...'
                                  : 'Entrar al Panel Administrativo'),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  void _mostrarMensaje(String texto, {required bool esError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto, style: GoogleFonts.poppins(fontSize: 12.5)),
        backgroundColor: esError ? Colors.redAccent : colorExito,
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
            Icons.arrow_back_ios_new_rounded,
            color: colorVerdeTese,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Portal de Cafeterías',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _verificandoDispositivo
              ? const Center(
                child: CircularProgressIndicator(color: colorVerdeTese),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Column(
                  children: [
                    ZoomIn(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: 125,
                        height: 125,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Image.asset(
                          'assets/patito_chef.png',
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                size: 62,
                                color: colorVerdeTese,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SI ESTE CELULAR YA ES LA TERMINAL AUTORIZADA
                    if (_docIdVinculado != null) ...[
                      FadeInDown(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorExito.withValues(alpha: 0.45),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorVerdeTese.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '✅ TERMINAL AUTORIZADA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: colorExito,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _nombreSucursalVinculada ?? 'Sucursal TESE',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: colorTextoOscuro,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Este dispositivo está vinculado como estación exclusiva de cocina.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colorTextoGris,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorVerdeTese,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Re-verifica en vivo que el Admin no la haya expulsado
                                    await _verificarSiEsteDispositivoEstaVinculado();
                                    if (_docIdVinculado != null && mounted) {
                                      widget.onTerminalAutorizada(
                                        _docIdVinculado!,
                                        _nombreSucursalVinculada ?? '',
                                        _codigoSucursalVinculada ?? '',
                                      );
                                    } else {
                                      _mostrarMensaje(
                                        '🔒 Esta terminal fue desvinculada por el Administrador.',
                                        esError: true,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.kitchen_rounded,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Entrar a mi Cocina (KDS)',
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
                      ),
                    ] else ...[
                      // SI ESTE CELULAR AÚN NO ESTÁ VINCULADO
                      Text(
                        'Vincular Terminal Oficial 🔐',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: colorTextoOscuro,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Escanea o sube el código QR temporal de un solo uso proporcionado por Administración para autorizar este dispositivo.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: colorTextoGris,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Aviso de responsabilidad por filtración
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFD54F)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFD97706),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Solo puede haber 1 dispositivo activo por sucursal. No compartas ni permitas fotos a tu llave QR; cualquier filtración es responsabilidad de la cafetería.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown.shade900,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón 1: Escanear con cámara
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _procesandoQR ? null : _abrirEscanerCamara,
                          icon: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            _procesandoQR
                                ? 'Validando llave QR...'
                                : 'Escanear QR con Cámara',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botón 2: Subir desde galería
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorVerdeTese,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: colorVerdeTese,
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed:
                              _procesandoQR ? null : _cargarQRDesdeGaleria,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 21,
                          ),
                          label: Text(
                            'Cargar QR desde Galería',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 10),

                    // ACCESO DISCRETO PARA EL ADMINISTRATIVO
                    FadeInUp(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        onPressed: _abrirModalAccesoAdmin,
                        icon: const Icon(
                          Icons.shield_outlined,
                          color: colorVerdeTese,
                          size: 19,
                        ),
                        label: Text(
                          'Acceso Administrativo TESE',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colorTextoOscuro,
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

/// Pantalla de Cámara en vivo para leer el QR de vinculación
class _EscanerCamaraQRScreen extends StatefulWidget {
  const _EscanerCamaraQRScreen();

  @override
  State<_EscanerCamaraQRScreen> createState() => _EscanerCamaraQRScreenState();
}

class _EscanerCamaraQRScreenState extends State<_EscanerCamaraQRScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _detectado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Apunta al QR de Vinculación',
          style: GoogleFonts.poppins(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              if (_detectado) return;
              if (capture.barcodes.isNotEmpty) {
                final String? valor = capture.barcodes.first.rawValue;
                if (valor != null && valor.isNotEmpty) {
                  _detectado = true;
                  _controller.stop();
                  Navigator.pop(context, valor);
                }
              }
            },
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorAmarilloTese, width: 3.5),
            ),
          ),
          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Coloca el código QR dentro del recuadro',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
