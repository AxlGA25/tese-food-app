import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'colores.dart';
import 'pantalla_menu.dart';

const List<String> kCarrerasTese = [
  'Ing. en Computación',
  'Ing. en Sistemas Computacionales',
  'Ing. Informática',
  'Ing. Mecatrónica',
  'Ing. Industrial',
  'Ing. Electrónica',
  'Ing. Mecánica',
  'Ing. Química',
  'Ing. Bioquímica',
  'Ing. en Gestión Empresarial',
  'Ing. Aeronáutica',
  'Lic. en Contaduría Pública',
  'Otra Área / Administrativo',
];

class LoginEstudianteScreen extends StatefulWidget {
  const LoginEstudianteScreen({super.key});

  @override
  State<LoginEstudianteScreen> createState() => _LoginEstudianteScreenState();
}

class _LoginEstudianteScreenState extends State<LoginEstudianteScreen> {
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _estaCargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _autocompletarDominio(String dominio) {
    HapticFeedback.selectionClick();
    final textoActual = _correoCtrl.text.trim();
    final sinDominio =
        textoActual.contains('@') ? textoActual.split('@').first : textoActual;
    setState(() {
      _correoCtrl.text = '$sinDominio$dominio';
      _correoCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _correoCtrl.text.length),
      );
    });
  }

  // 🔑 RECUPERACIÓN DE CONTRASEÑA AMIGABLE
  void _mostrarModalRecuperarPassword() {
    final TextEditingController recupCtrl = TextEditingController(
      text: _correoCtrl.text.trim(),
    );
    bool enviando = false;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextDialog, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      color: colorVerdeTese,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuperar Contraseña',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresa tu correo institucional y te enviaremos un enlace seguro para restablecer tu contraseña.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: colorTextoGris,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: recupCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Institucional',
                        hintText: 'usuario@tese.edu.mx',
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: colorVerdeTese,
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: enviando ? null : () => Navigator.pop(ctx),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        color: colorTextoGris,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorVerdeTese,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        enviando
                            ? null
                            : () async {
                              final correo =
                                  recupCtrl.text.trim().toLowerCase();
                              if (correo.isEmpty || !correo.contains('@')) {
                                _mostrarAlerta('Ingresa un correo válido.');
                                return;
                              }
                              setStateDialog(() => enviando = true);
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: correo);
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                _mostrarMensajeExito(
                                  '¡Listo! Revisa tu bandeja de entrada o spam en $correo para cambiar tu contraseña. 📩',
                                );
                              } on FirebaseAuthException catch (e) {
                                setStateDialog(() => enviando = false);
                                if (e.code == 'user-not-found') {
                                  _mostrarAlerta(
                                    'No hay ninguna cuenta registrada con ese correo.',
                                  );
                                } else {
                                  _mostrarAlerta(
                                    'No se pudo enviar el correo. Verifica que esté bien escrito.',
                                  );
                                }
                              } catch (_) {
                                setStateDialog(() => enviando = false);
                                _mostrarAlerta(
                                  'Error de conexión al enviar el enlace.',
                                );
                              }
                            },
                    child:
                        enviando
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Enviar enlace',
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

  // 🔒 VENTANA OBLIGATORIA: Si entra con Google DEBE poner matrícula y carrera
  void _mostrarModalObligatorioGoogle(User user, bool yaTeniaPerfil) {
    final TextEditingController matriculaCtrl = TextEditingController();
    String carreraElegida = kCarrerasTese[0];
    bool guardandoDatos = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextDialog, setStateDialog) {
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.school, color: colorVerdeTese, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¡Casi listo! Datos TESE',
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
                          'Para entregarte tus pedidos en ventanilla sin confusiones, registra tu matrícula y carrera institucional:',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: colorTextoGris,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: matriculaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Matrícula Oficial',
                            hintText: 'Ej. 20240001',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: colorVerdeTese,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: carreraElegida,
                          decoration: InputDecoration(
                            labelText: 'Carrera',
                            prefixIcon: const Icon(
                              Icons.school_outlined,
                              color: colorVerdeTese,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items:
                              kCarrerasTese
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) =>
                                  setStateDialog(() => carreraElegida = val!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          guardandoDatos
                              ? null
                              : () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorVerdeTese,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          guardandoDatos
                              ? null
                              : () async {
                                final mat = matriculaCtrl.text.trim();
                                if (mat.isEmpty || mat.length < 5) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Por favor ingresa una matrícula válida (mínimo 5 dígitos).',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setStateDialog(() => guardandoDatos = true);

                                await FirebaseFirestore.instance
                                    .collection('Usuarios')
                                    .doc(user.uid)
                                    .set({
                                      'uid': user.uid,
                                      'nombre_completo':
                                          user.displayName ?? 'Estudiante TESE',
                                      'rol': 'Estudiante',
                                      'identificador': mat,
                                      'carrera_area': carreraElegida,
                                      'correo': user.email ?? '',
                                      'fecha_registro':
                                          FieldValue.serverTimestamp(),
                                      'alergia':
                                          'Sin restricciones alimentarias 😋',
                                    }, SetOptions(merge: true));

                                if (!yaTeniaPerfil) {
                                  await FirebaseFirestore.instance
                                      .collection('Usuarios_Perfil')
                                      .doc(user.uid)
                                      .set({
                                        'patoEquipadoId': 'estudiante',
                                        'coleccionPatos': {'estudiante': 1},
                                        'puntosGastadosEnGachapon': 0,
                                      }, SetOptions(merge: true));
                                }

                                if (ctx.mounted) Navigator.pop(ctx);
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NavegacionEstudiante(),
                                  ),
                                );
                              },
                      child:
                          guardandoDatos
                              ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Confirmar y Entrar',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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

  // 🌐 LOGIN CON GOOGLE
  Future<void> _iniciarSesionConGoogle() async {
    setState(() => _estaCargando = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _estaCargando = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('Usuarios')
                .doc(user.uid)
                .get();
        final perfilDoc =
            await FirebaseFirestore.instance
                .collection('Usuarios_Perfil')
                .doc(user.uid)
                .get();

        final String? idActual = userDoc.data()?['identificador'] as String?;
        final bool faltaMatricula =
            !userDoc.exists ||
            idActual == null ||
            idActual.isEmpty ||
            idActual == 'Sin Matrícula' ||
            idActual == 'Google Auth';

        if (!mounted) return;
        if (faltaMatricula) {
          _mostrarModalObligatorioGoogle(user, perfilDoc.exists);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NavegacionEstudiante(),
            ),
          );
        }
      }
    } catch (e) {
      _mostrarAlerta('Error al iniciar sesión con Google.');
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  Future<void> _iniciarSesionCorreo() async {
    final correo = _correoCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mostrarAlerta('Por favor escribe tu correo y contraseña.');
      return;
    }

    if (!correo.endsWith('@tese.edu.mx') &&
        !correo.endsWith('@ecatepec.tecnm.mx')) {
      _mostrarAlerta(
        'Usa tu correo institucional (@tese.edu.mx o @ecatepec.tecnm.mx).',
      );
      return;
    }

    setState(() => _estaCargando = true);
    HapticFeedback.lightImpact();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavegacionEstudiante()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión.';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con este correo. ¡Regístrate abajo!';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensaje = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'network-request-failed') {
        mensaje = 'Revisa tu conexión a internet.';
      }
      _mostrarAlerta(mensaje);
    } catch (_) {
      _mostrarAlerta('Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
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

  void _mostrarMensajeExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: colorExito,
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  'Acceso Estudiantil',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ingresa para pedir tu comida sin hacer filas',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: colorTextoGris,
                ),
              ),
              const SizedBox(height: 14),
              ZoomIn(
                child: Image.asset(
                  'assets/patito_login.png',
                  height: 135,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Institucional',
                        hintText: 'ejemplo@tese.edu.mx',
                        prefixIcon: const Icon(
                          Icons.mail_outline,
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
                    const SizedBox(height: 8),
                    // Chips rápidos para autocompletar el dominio institucional
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'Autocompletar: ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: colorTextoGris,
                            ),
                          ),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: colorFondoCrema,
                            side: BorderSide.none,
                            label: Text(
                              '@tese.edu.mx',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorVerdeTese,
                              ),
                            ),
                            onPressed:
                                () => _autocompletarDominio('@tese.edu.mx'),
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            backgroundColor: colorFondoCrema,
                            side: BorderSide.none,
                            label: Text(
                              '@ecatepec.tecnm.mx',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorVerdeTese,
                              ),
                            ),
                            onPressed:
                                () =>
                                    _autocompletarDominio('@ecatepec.tecnm.mx'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _ocultarPassword,
                      onSubmitted: (_) => _iniciarSesionCorreo(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: colorVerdeTese,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorTextoGris,
                          ),
                          onPressed:
                              () => setState(
                                () => _ocultarPassword = !_ocultarPassword,
                              ),
                        ),
                        filled: true,
                        fillColor: colorFondoCrema,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _mostrarModalRecuperarPassword,
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorVerdeTese,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorVerdeTese,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _estaCargando ? null : _iniciarSesionCorreo,
                        child:
                            _estaCargando
                                ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Text(
                                  'Ingresar con Correo TESE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'o ingresa rápido con',
                            style: GoogleFonts.poppins(
                              color: colorTextoGris,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                          height: 22,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.g_mobiledata,
                                color: Colors.blue,
                                size: 28,
                              ),
                        ),
                        label: Text(
                          'Continuar con Google',
                          style: GoogleFonts.poppins(
                            color: colorTextoOscuro,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed:
                            _estaCargando ? null : _iniciarSesionConGoogle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroEstudianteScreen(),
                      ),
                    ),
                icon: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: colorVerdeTese,
                  size: 18,
                ),
                label: Text(
                  '¿Eres nuevo? Crear cuenta institucional',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colorVerdeTese,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
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
// 3. REGISTRO INSTITUCIONAL AMIGABLE
// ==========================================
class RegistroEstudianteScreen extends StatefulWidget {
  const RegistroEstudianteScreen({super.key});

  @override
  State<RegistroEstudianteScreen> createState() =>
      _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _matriculaCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  String rolSeleccionado = 'Estudiante';
  final List<String> opcionesRol = ['Estudiante', 'Maestro', 'Directivo'];
  String areaSeleccionada = kCarrerasTese[0];

  bool _estaCargando = false;
  bool _ocultarPass = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _matriculaCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    final nombre = _nombreCtrl.text.trim();
    final matricula = _matriculaCtrl.text.trim();
    final correo = _correoCtrl.text.trim().toLowerCase();
    final telefono = _telefonoCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (nombre.isEmpty || matricula.isEmpty || correo.isEmpty || pass.isEmpty) {
      _mostrarAlerta('Por favor completa todos los campos obligatorios.');
      return;
    }

    if (!correo.endsWith('@tese.edu.mx') &&
        !correo.endsWith('@ecatepec.tecnm.mx')) {
      _mostrarAlerta(
        'Debes usar tu correo institucional (@tese.edu.mx o @ecatepec.tecnm.mx).',
      );
      return;
    }

    if (pass.length < 6) {
      _mostrarAlerta('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (pass != confirmPass) {
      _mostrarAlerta('Las contraseñas no coinciden. Revisa que sean iguales.');
      return;
    }

    setState(() => _estaCargando = true);
    HapticFeedback.mediumImpact();

    try {
      final UserCredential credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: pass);

      final User? user = credencial.user;

      if (user != null) {
        await user.updateDisplayName(nombre);
        try {
          await user.sendEmailVerification();
        } catch (_) {}

        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'nombre_completo': nombre,
              'rol': rolSeleccionado,
              'identificador': matricula,
              'carrera_area': areaSeleccionada,
              'correo': correo,
              'telefono': telefono,
              'fecha_registro': FieldValue.serverTimestamp(),
              'alergia': 'Sin restricciones alimentarias 😋',
              'puntos': 0,
            });

        await FirebaseFirestore.instance
            .collection('Usuarios_Perfil')
            .doc(user.uid)
            .set({
              'patoEquipadoId': 'estudiante',
              'coleccionPatos': {'estudiante': 1},
              'puntosGastadosEnGachapon': 0,
            });

        if (mounted) {
          _mostrarDialogoExito(nombre.split(' ').first);
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error en el registro.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este correo institucional ya tiene una cuenta registrada.';
      } else if (e.code == 'weak-password') {
        msg = 'La contraseña es muy débil.';
      }
      _mostrarAlerta(msg);
    } catch (e) {
      _mostrarAlerta('Error inesperado al registrar.');
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  void _mostrarDialogoExito(String primerNombre) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  color: colorExito,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¡Bienvenido, $primerNombre! 🦆',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Tu cuenta del TESE fue creada con éxito y te regalamos tu primer Patito Estudiante 🎓.\n\nTambién enviamos un correo de verificación a tu bandeja institucional.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: colorTextoOscuro,
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVerdeTese,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NavegacionEstudiante(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Entrar al Menú Ahora 🍔',
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
  }

  void _mostrarAlerta(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(fontSize: 13.5)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
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
    String labelId =
        rolSeleccionado == 'Estudiante'
            ? 'Matrícula Oficial'
            : 'No. de Empleado';
    IconData iconId =
        rolSeleccionado == 'Estudiante'
            ? Icons.badge_outlined
            : Icons.work_outline;

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Registro Institucional',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _decoracionCampo(
                      'Rol en el TESE',
                      Icons.groups_outlined,
                    ),
                    value: rolSeleccionado,
                    items:
                        opcionesRol
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => rolSeleccionado = val!),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoracionCampo(
                      'Nombre Completo',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _matriculaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoracionCampo(labelId, iconId),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _decoracionCampo(
                      'Carrera / División',
                      Icons.school_outlined,
                    ),
                    value: areaSeleccionada,
                    items:
                        kCarrerasTese
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(
                          () => areaSeleccionada = val ?? kCarrerasTese[0],
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Institucional (@tese.edu.mx)',
                      hintText: 'tu.correo@tese.edu.mx',
                      prefixIcon: const Icon(
                        Icons.alternate_email,
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
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _decoracionCampo(
                      'Teléfono (10 dígitos, opcional)',
                      Icons.phone_outlined,
                    ).copyWith(counterText: ''),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _ocultarPass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña (mínimo 6 caracteres)',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: colorVerdeTese,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorTextoGris,
                        ),
                        onPressed:
                            () => setState(() => _ocultarPass = !_ocultarPass),
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
                    controller: _confirmPassCtrl,
                    obscureText: _ocultarPass,
                    decoration: _decoracionCampo(
                      'Confirmar Contraseña',
                      Icons.lock_clock_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                onPressed: _estaCargando ? null : _registrarUsuario,
                child:
                    _estaCargando
                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : Text(
                          'Crear Cuenta y Entrar',
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
}
