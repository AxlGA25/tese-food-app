<div align="center">

# 🦆🍔 TESE Hambreados

**Plataforma móvil multi-sucursal en tiempo real para pedidos anticipados, terminales de cocina (KDS) y gamificación estudiantil en el Tecnológico de Estudios Superiores de Ecatepec (TESE).**

[![Versión Oficial](https://img.shields.io/badge/Release-v1.0.0--Official-00A650?style=for-the-badge&logo=github)](https://github.com/AxlGA25/tese-food-app/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime_Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

*«Sin filas, más receso para ti.»*

</div>

---

## 📖 Descripción del Proyecto

**TESE Hambreados** nace para erradicar las largas filas durante el receso en las cafeterías y kioskos del **Tecnológico de Estudios Superiores de Ecatepec**. Permite a la comunidad estudiantil, docente y administrativa explorar el menú real de cada sucursal del campus, personalizar ingredientes, alertar sobre alergias médicas y recibir una notificación sonora (**¡CUAC!**) en cuanto su orden está lista para recoger en ventanilla.

Paralelamente, dota al personal de cada cafetería de una **Terminal de Cocina (KDS - Kitchen Display System)** aislada por sucursal para gestionar comandas en vivo, controlar su inventario y consultar la reputación de sus platillos.

---

## 🚀 Características Principales (v1.0.0)

### 🧑‍🎓 1. Módulo Estudiante
- **Bienvenida Minimalista Pastel (`FondoOndasPremium`):** Animaciones multicapa a 60 FPS con ondas orgánicas, filetes dorados y cápsulas flotantes de alimentos.
- **Autenticación Universal e Institucional:** Inicio de sesión y registro con cualquier correo electrónico válido o mediante **Google Sign-In**, con recuperación de contraseña por correo (`sendPasswordResetEmail`) y catálogo completo de carreras del TESE.
- **Guía Rápida Interactiva (Onboarding):** Mini-tutorial deslizable de 4 pasos protagonizado por el Patito TESE para guiar a los usuarios de nuevo ingreso.
- **Catálogo Multi-Sucursal en Tiempo Real:** Filtrado instantáneo por local (*Cafetería Central, Kiosko Sistemas, Kiosko Biblioteca*), categoría (*Desayunos, Comida, Bebidas, Postres*) y buscador dinámico con indicadores de stock en vivo.
- **Personalización de Ingredientes y Alergias:** Selección interactiva por ingrediente (*Normal ➔ Sin ➔ Extra*) e inyección automática de alertas médicas/alergias configuradas en el perfil del alumno.
- **Carrito Inteligente (`_GrupoCarrito`):** Agrupación automática de platillos idénticos con controles `[-]` y `[+]` topados al stock real, función *Swipe-to-Delete* y candado preventivo anti-mezcla de sucursales.
- **Seguimiento en Segundo Plano y Alerta ¡CUAC!:** Servicio nativo de monitoreo (`ongoing: true`) con vibración háptica, confeti y efecto de sonido (`cuac.mp3`) cuando la orden entra a cocina y cuando está lista para recoger.

### 🦆 2. Multiverso Gachapón HD y Gamificación
- **Sistema de Puntos y Rangos Estudiantiles:** Cada compra entregada acredita puntos 🪙 que hacen subir de rango al alumno (*Novato del Receso 🍪 ➔ Comelón Frecuente 🍟 ➔ Hambreado VIP 🥇*).
- **32 Skins Vectoriales HD (`CustomPainter`):** Dibujadas 100% mediante código con volumen 3D-Kawaii, pedestal holográfico y animaciones vivas (respiración, aleteo y parpadeo automático), divididas en **4 Universos**:
  - **🎓 Carreras TESE:** *Ing. en sistemas, Mecatrónica, Aeronáutica, Industrial, Química/Bioquímica, Gestión, Estudiante y Master Chef.*
  - **🎸 Anime & Ídolos:** *Pato Insulini Piloto, Bocchi-Pato Guitarrista (con Les Paul), Pato Hechicero Infinito (Gojo), Pato Súper Saiyajin, Streamer Pro RGB, Shinobi y Hechicero Supremo.*
  - **🕷️ Héroes & Cómics:** *Spidey-Pato, Iron-Pato Mark LXXXV (con Reactor Arc), Venom-Pato, Bati-Pato, Wolverine X, Dead-Pato y Hulk-Pato.*
  - **✨ Míticos & Clásicos:** *Emperador Dorado VIP, Diamante Celestial, Cósmico Nebulosa, Chroma RGB, Lo-Fi Beats, Matcha Latte, Frappe Rosa, Fachero, Capitán Pirata y Clásico.*
- **Inspección Holográfica y Armario de Avatar:** Vista detallada en alta definición desde la colección y equipamiento directo del patito favorito como foto de perfil.

### 👨‍🍳 3. Módulo Cafetería / Terminal de Cocina (KDS)
- **Seguridad de Doble Factor por Sucursal:** Acceso protegido mediante Código de Sucursal + PIN Maestro de 6 dígitos con bloqueo anti-fuerza bruta tras 3 intentos fallidos.
- **Tutorial Interactivo de Cocina:** Guía visual paso a paso integrada en la terminal para capacitar rápidamente al personal del kiosko.
- **Comandas Aisladas en Tiempo Real:** Cada sucursal recibe, cocina y entrega exclusivamente sus propios pedidos con filtros rápidos (*Todos, Nuevos, En Cocina, Listos*), cronómetro de espera y alerta visual de alergias.
- **Control de Existencias y Fotografía:** Alta, edición y baja de platillos con captura de hasta **3 fotografías reales** (cámara o galería en Base64), ajuste rápido de stock `[-]` / `[+]` y bloqueo automático de agotados.
- **Reputación Exclusiva por Sucursal:** Panel de reseñas y promedio de estrellas filtrado estrictamente por los platillos pertenecientes a cada kiosko.

---

## 🛠️ Stack Tecnológico

| Capa | Tecnologías e Implementación |
| :--- | :--- |
| **Framework & Lenguaje** | Flutter SDK `^3.7.2` • Dart (Arquitectura reactiva multiplataforma Android / iOS) |
| **Backend & Cloud (BaaS)** | **Firebase Authentication** (Email/Password & Google Sign-In) • **Cloud Firestore** (Streams NoSQL en tiempo real) |
| **UI, Animaciones & Gráficos** | `CustomPainter` (Gráficos vectoriales 2D/3D-Kawaii y ondas Bézier) • `animate_do` • `google_fonts` (Poppins) • `curved_navigation_bar` • `confetti` • `awesome_snackbar_content` |
| **Hardware & Nativos** | `flutter_local_notifications` (Canales de alta prioridad y servicio persistente) • `audioplayers` (`cuac.mp3` / `exito.mp3`) • `image_picker` (Cámara y Galería) • `HapticFeedback` |
| **Diseño & Versionado** | coreldraw (Diseño de mascota oficial y assets propios) • Git & GitHub (Versionado Semántico) |

---

## 📂 Estructura de Directorios (`lib/`)

```text
lib/
├── main.dart                        # Inicialización de Firebase Core, tema global y punto de entrada
├── colores.dart                     # Paleta institucional TESE, tonos pastel y tokens de diseño
├── modelos.dart                     # Modelo de datos Platillo y serialización con Cloud Firestore
├── pantalla_inicio.dart             # Splash Screen persistente, ondas animadas multicapa y selección de rol
├── pantalla_login.dart              # Login, Registro abierto, Google Auth y recuperación de contraseña
├── pantalla_menu.dart               # Catálogo estudiantil, Guía Interactiva, vigilante de órdenes y Mis Pedidos
├── pantalla_detalle_platillo.dart   # Galería de fotos, personalización de ingredientes y control de stock
├── pantalla_pedido.dart             # Carrito agrupado, confirmación, Sala de Espera en vivo y Reseñas
├── pantalla_perfil.dart             # Credencial TESE, alergias, estadísticas, rangos y selector de avatar
├── pantalla_gachapon.dart           # Motor gráfico de 32 Patitos, máquina de cápsulas, ruleta e inspección HD
├── cafeteria.dart                   # Login Local 2FA, KDS de comandas, inventario y reseñas por sucursal
└── servicio_notificaciones.dart     # Configuración de notificaciones nativas Android y monitoreo activo
```

---

## 🔑 Credenciales de Prueba (Terminales de Cocina KDS)

Para evaluar el aislamiento de sucursales en el módulo **Soy Cafetería / Kiosko** (también disponibles desde el botón de ayuda **Códigos** dentro de la app):

| Sucursal del Campus | Código de Sucursal | PIN Maestro (6 dígitos) |
| :--- | :---: | :---: |
| 🖥️ **Kiosko Sistemas** | `KS-SISTEMAS` | `849201` |
| 📚 **Kiosko Biblioteca** | `KB-BIBLIO` | `715309` |
| 🍽️ **Cafetería Central** | `CC-CENTRAL` | `938420` |

---

## 📦 Historial de Versiones (Changelog Completo)

El proyecto evolucionó de manera iterativa y modular desde su concepción hasta la versión oficial de producción:

- **`v1.0.0` (Official Release)** — Lanzamiento oficial de producción: Rediseño minimalista pastel con ondas animadas en inicio, Login abierto universal con pestañas visibles, **Multiverso Gachapón HD con 32 patitos animados** (parpadeo, respiración, *Bocchi-Pato, Gojo, Saiyajin, Venom, Batman, Streamer RGB*), inspección holográfica y permisos nativos completos.
- **`v0.27.0-beta`** — Implementación de Guía Rápida Interactiva (Onboarding) para estudiantes, Carrito Inteligente con agrupación de ítems (`_GrupoCarrito`), candado anti-mezcla de kioskos y protección de puntos al limpiar historial (`ocultoParaAlumno`).
- **`v0.26.0-beta`** — Terminales de Cocina Multi-Sucursal con Doble Factor (Código + PIN Maestro), bloqueo anti-fuerza bruta, aislamiento de comandas por kiosko, onboarding forzoso en Google Auth y corrección de *overflows* visuales.
- **`v0.25.0-beta` a `v0.20.0-beta`** — Integración del sistema de gamificación (**Gachapón de Patitos** con ruleta estilo apertura de cajas y `CustomPainter`), sistema de puntos por compra entregada, rangos estudiantiles y colección persistente en `Usuarios_Perfil`.
- **`v0.19.0-beta` a `v0.15.0-beta`** — Implementación de notificaciones nativas en segundo plano (`flutter_local_notifications`), alerta sonora personalizada **¡CUAC!**, captura de hasta 3 fotografías en Base64 por platillo y cálculo de calificaciones promedio con reseñas reales.
- **`v0.14.0-beta` a `v0.9.0-alpha`** — Migración completa a la nube con **Firebase Core, Firebase Auth y Cloud Firestore**, sincronizando usuarios, catálogo de platillos y comandas en tiempo real.
- **`v0.8.0-alpha`** — Diseño Premium (*Splash Screen*, *Mesh Gradient* y mejoras de UI/UX).
- **`v0.7.0-alpha`** — Integración de Identidad Visual y mascotas oficiales en el módulo de Cafetería.
- **`v0.6.0-alpha`** — Ventanas modales para la visualización del detalle de pedidos en tiempo real.
- **`v0.5.0-alpha`** — Selección de métodos de pago (*Efectivo / Terminal Bancaria*).
- **`v0.4.1-alpha`** — Dashboard Administrativo: Gestión de Menú con `BottomNavigationBar`.
- **`v0.4.0-alpha`** — Formulario de registro estudiantil con validaciones.
- **`v0.2.2-alpha`** — Generador de códigos únicos de orden (`#TESE-XXXXX`) y sala de espera dinámica.
- **`v0.1.0-alpha`** — Estructura base del proyecto, mockups de login y enrutamiento principal.
- **`v0.0.3-alpha`** — *Fix:* Configuración y resolución del entorno Java/Gradle para compilación en Android.

---

## ⚙️ Cómo ejecutar este proyecto localmente

1. **Requisitos previos:** Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.7.2`) y **Java 17 (JDK)**.
2. **Clonar este repositorio:**
   ```bash
   git clone https://github.com/AxlGA25/tese-food-app.git
   ```
3. **Entrar a la carpeta del proyecto:**
   ```bash
   cd tese-food-app
   ```
4. **Instalar las dependencias:**
   ```bash
   flutter pub get
   ```
5. **Ejecutar en emulador o dispositivo físico:**
   ```bash
   flutter run
   ```
6. **Generar APK de producción (Opcional):**
   ```bash
   flutter build apk --release
   ```

---

## 👥 Equipo de Desarrollo

Proyecto desarrollado con orgullo en el **Tecnológico de Estudios Superiores de Ecatepec (TESE)** por:

- **Axel Guerrero Alonso** — *Arquitectura de Software, Backend en Firebase, Motor Gráfico CustomPainter & Full-Stack Flutter* ([@AxlGA25](https://github.com/AxlGA25))
- **Dana Patricia Calderón García** — *Diseño UI/UX, Identidad Visual, Flujos de Experiencia Estudiantil & Co-Desarrollo Flutter*
