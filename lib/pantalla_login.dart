import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colores.dart';
import 'pantalla_menu.dart';

// ==========================================
// 1. PANTALLA DE LOGIN REAL CON FIREBASE
// ==========================================
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

  void _iniciarSesion() async {
    final correo = _correoCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mostrarAlerta('Por favor completa todos los campos.');
      return;
    }

    // 🔒 Candado de Dominio Institucional TESE
    if (!correo.endsWith('@tese.edu.mx') &&
        !correo.endsWith('@ecatepec.tecnm.mx')) {
      _mostrarAlerta(
        'Ingresa tu correo institucional del TESE (@tese.edu.mx).',
      );
      return;
    }

    setState(() => _estaCargando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavegacionEstudiante()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión.';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta registrada con este correo.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensaje = 'Contraseña o correo incorrectos.';
      } else if (e.code == 'network-request-failed') {
        mensaje = 'Revisa tu conexión a internet.';
      }
      _mostrarAlerta(mensaje);
    } catch (_) {
      _mostrarAlerta('Ocurrió un error inesperado. Inténtalo de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  void _mostrarAlerta(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(fontSize: 13.5)),
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
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
                'Ingresa con tu cuenta institucional TESE',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: colorTextoGris,
                ),
              ),
              const SizedBox(height: 16),
              ZoomIn(
                child: Image.asset(
                  'assets/patito_login.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
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
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Institucional (@tese.edu.mx)',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _ocultarPassword,
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
                    const SizedBox(height: 24),
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
                        onPressed: _estaCargando ? null : _iniciarSesion,
                        child:
                            _estaCargando
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'Ingresar a Cafetería',
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
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroEstudianteScreen(),
                      ),
                    ),
                child: Text(
                  '¿No tienes cuenta? Registrarme con mi correo institucional',
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

// ==========================================================
// 2. REGISTRO CON CANDADO DE OUTLOOK Y VERIFICACIÓN
// ==========================================================
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

  String? areaSeleccionada;
  final List<String> areasTese = [
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

  void _registrarUsuario() async {
    final nombre = _nombreCtrl.text.trim();
    final matricula = _matriculaCtrl.text.trim();
    final correo = _correoCtrl.text.trim().toLowerCase();
    final telefono = _telefonoCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (nombre.isEmpty || matricula.isEmpty || correo.isEmpty || pass.isEmpty) {
      _mostrarAlerta('Por favor completa los campos obligatorios.');
      return;
    }

    // 🔒 CANDADO ESTRICTO DE CORREO INSTITUCIONAL DEL TESE
    if (!correo.endsWith('@tese.edu.mx') &&
        !correo.endsWith('@ecatepec.tecnm.mx')) {
      _mostrarAlerta(
        'Debes registrarte con tu correo institucional del TESE (@tese.edu.mx).',
      );
      return;
    }

    if (pass.length < 6) {
      _mostrarAlerta('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (pass != confirmPass) {
      _mostrarAlerta('Las contraseñas no coinciden.');
      return;
    }

    setState(() => _estaCargando = true);

    try {
      // 1. Crear el usuario en Firebase Authentication
      final UserCredential credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: pass);

      final User? user = credencial.user;

      if (user != null) {
        // 2. Enviar correo de verificación a su Outlook de Microsoft
        await user.sendEmailVerification();

        // 3. Guardar el perfil completo en Cloud Firestore
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'nombre_completo': nombre,
              'rol': rolSeleccionado,
              'identificador': matricula,
              'carrera_area':
                  areaSeleccionada ?? 'Ing. en Sistemas Computacionales',
              'correo': correo,
              'telefono': telefono,
              'fecha_registro': FieldValue.serverTimestamp(),
              'alergia': 'Sin restricciones alimentarias 😋',
              'puntos': 0,
            });

        // Inicializamos su perfil de Gachapón
        await FirebaseFirestore.instance
            .collection('Usuarios_Perfil')
            .doc(user.uid)
            .set({
              'patoEquipadoId': 'estudiante',
              'coleccionPatos': {'estudiante': 1},
              'puntosGastadosEnGachapon': 0,
            });

        if (mounted) {
          _mostrarDialogoExito();
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
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: colorExito,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  '¡Registro Exitoso!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              'Tu cuenta fue creada correctamente.\n\nTe enviamos un enlace de confirmación a tu correo institucional de Microsoft Outlook. Ya puedes iniciar sesión en la cafetería.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: colorTextoOscuro,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorVerdeTese,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Cierra diálogo
                  Navigator.pop(context); // Regresa a pantalla de login
                },
                child: Text(
                  'Ir a Iniciar Sesión',
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

  void _mostrarAlerta(String mensaje) {
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
        rolSeleccionado == 'Estudiante' ? 'Matrícula' : 'No. Empleado';
    IconData iconId =
        rolSeleccionado == 'Estudiante' ? Icons.badge : Icons.work_outline;

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
                  // 1. ROL
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _decoracionCampo(
                      'Rol en el TESE',
                      Icons.groups,
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

                  // 2. NOMBRE COMPLETO
                  TextField(
                    controller: _nombreCtrl,
                    decoration: _decoracionCampo(
                      'Nombre Completo',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. MATRÍCULA
                  TextField(
                    controller: _matriculaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoracionCampo(labelId, iconId),
                  ),
                  const SizedBox(height: 14),

                  // 4. CARRERA OFICIAL
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: _decoracionCampo(
                      'Carrera / División',
                      Icons.school_outlined,
                    ),
                    value: areaSeleccionada,
                    items:
                        areasTese
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => areaSeleccionada = val),
                  ),
                  const SizedBox(height: 14),

                  // 5. CORREO INSTITUCIONAL OBLIGATORIO
                  TextField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Institucional (@tese.edu.mx)',
                      hintText: 'tu.matricula@tese.edu.mx',
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

                  // 6. TELÉFONO
                  TextField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _decoracionCampo(
                      'Teléfono (10 dígitos)',
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 7. CONTRASEÑA
                  TextField(
                    controller: _passCtrl,
                    obscureText: _ocultarPass,
                    decoration: InputDecoration(
                      labelText: 'Crear Contraseña (mínimo 6 caracteres)',
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

                  // 8. CONFIRMAR CONTRASEÑA
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

            // BOTÓN REGISTRARME
            SizedBox(
              width: double.infinity,
              height: 52,
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Registrarme con Correo TESE',
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
