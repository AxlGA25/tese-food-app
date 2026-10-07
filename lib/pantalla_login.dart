import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'colores.dart';
import 'pantalla_menu.dart'; // Para navegar a la app después del login

// ==========================================
// PANTALLA DE LOGIN
// ==========================================
class LoginEstudianteScreen extends StatelessWidget {
  const LoginEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Text(
                  'Inicio de Sesión',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorVerdeTese,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Entra y pide sin hacer fila',
                style: GoogleFonts.poppins(fontSize: 14, color: colorTextoGris),
              ),
              const SizedBox(height: 16),
              ZoomIn(
                child: Image.asset(
                  'assets/patito_login.png',
                  height: 150,
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
                    FadeInLeft(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Matrícula / No. Empleado',
                          prefixIcon: const Icon(
                            Icons.badge,
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
                    ),
                    const SizedBox(height: 16),
                    FadeInRight(
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(
                            Icons.lock,
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
                    ),
                    const SizedBox(height: 26),
                    FadeInUp(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            elevation: 4,
                            shadowColor: colorVerdeTese.withValues(alpha: 0.5),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed:
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const NavegacionEstudiante(),
                                ),
                              ),
                          child: Text(
                            'Ingresar',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const RegistroEstudianteScreen(),
                        ),
                      ),
                  child: Text(
                    '¿No tienes cuenta? Crear una',
                    style: GoogleFonts.poppins(
                      color: colorAmarilloTese,
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
    );
  }
}

// ==========================================
// PANTALLA DE REGISTRO (MULTIRROL)
// ==========================================
// ==========================================
// PANTALLA DE REGISTRO (MULTIRROL ACTUALIZADO)
// ==========================================
class RegistroEstudianteScreen extends StatefulWidget {
  const RegistroEstudianteScreen({super.key});

  @override
  State<RegistroEstudianteScreen> createState() =>
      _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  // VARIABLES DE ESTADO PARA LA LÓGICA INTELIGENTE
  String rolSeleccionado = 'Estudiante';
  final List<String> opcionesRol = ['Estudiante', 'Maestro', 'Directivo'];

  String? areaSeleccionada;
  // LA LISTA OFICIAL DE CARRERAS DEL TESE
  final List<String> areasTese = [
    'Ing. Aeronáutica',
    'Ing. Bioquímica',
    'Ing. Electrónica',
    'Ing. en Gestión Empresarial',
    'Ing. Industrial',
    'Ing. Informática',
    'Ing. Mecánica',
    'Ing. Mecatrónica',
    'Ing. Química',
    'Ing. en Sistemas Computacionales',
    'Lic. en Contaduría Pública',
    'Otra Área / Administrativo',
  ];

  void _simularRegistro() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const NavegacionEstudiante()),
      (route) => false,
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
    // TEXTOS DINÁMICOS SEGÚN EL ROL ELEGIDO
    String labelIdentificador =
        rolSeleccionado == 'Estudiante' ? 'Matrícula' : 'Número de Empleado';
    IconData iconIdentificador =
        rolSeleccionado == 'Estudiante' ? Icons.badge : Icons.work_outline;
    String labelArea =
        rolSeleccionado == 'Estudiante' ? 'Carrera' : 'Departamento / Academia';

    return Scaffold(
      backgroundColor: colorFondoCrema,
      appBar: AppBar(
        title: Text(
          'Crear Cuenta',
          style: GoogleFonts.poppins(
            color: colorVerdeTese,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: colorVerdeTese),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // FOTO DE PERFIL
            FadeInDown(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorAmarilloTese, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: colorVerdeTese.withValues(alpha: 0.08),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: colorVerdeTese,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorAmarilloTese,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorAmarilloTese.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // FORMULARIO CON SOMBRA
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
                  // 1. SELECTOR DE ROL
                  FadeInLeft(
                    delay: const Duration(milliseconds: 50),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: _decoracionCampo(
                        '¿Qué rol tienes?',
                        Icons.groups,
                      ),
                      value: rolSeleccionado,
                      items:
                          opcionesRol
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          rolSeleccionado = val!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. NOMBRE
                  FadeInRight(
                    delay: const Duration(milliseconds: 100),
                    child: TextField(
                      decoration: _decoracionCampo(
                        'Nombre Completo',
                        Icons.text_fields,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 3. MATRÍCULA / NÓMINA (DINÁMICO)
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: _decoracionCampo(
                        labelIdentificador,
                        iconIdentificador,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 4. CARRERA / DEPARTAMENTO OFICIAL TESE
                  FadeInRight(
                    delay: const Duration(milliseconds: 300),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: _decoracionCampo(labelArea, Icons.school),
                      value: areaSeleccionada,
                      items:
                          areasTese
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => areaSeleccionada = val),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 5. CORREO INSTITUCIONAL (¡NUEVO!)
                  FadeInLeft(
                    delay: const Duration(milliseconds: 350),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampo(
                        'Correo Institucional',
                        Icons.email,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 6. TELÉFONO
                  FadeInRight(
                    delay: const Duration(milliseconds: 400),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampo(
                        'Teléfono a 10 dígitos',
                        Icons.phone,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 7. CONTRASEÑA
                  FadeInLeft(
                    delay: const Duration(milliseconds: 500),
                    child: TextField(
                      obscureText: true,
                      decoration: _decoracionCampo(
                        'Crear Contraseña',
                        Icons.lock,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 8. CONFIRMAR CONTRASEÑA (¡NUEVO!)
                  FadeInRight(
                    delay: const Duration(milliseconds: 550),
                    child: TextField(
                      obscureText: true,
                      decoration: _decoracionCampo(
                        'Confirmar Contraseña',
                        Icons.lock_clock,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // BOTÓN REGISTRAR
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVerdeTese,
                    elevation: 4,
                    shadowColor: colorVerdeTese.withValues(alpha: 0.5),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _simularRegistro,
                  child: Text(
                    'Registrarme',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
