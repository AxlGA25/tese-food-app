# 🦆🍔 TESE Hambreados

Aplicación multiplataforma diseñada para optimizar los tiempos de receso de los estudiantes del Tecnológico de Estudios Superiores de Ecatepec, permitiendo realizar pedidos anticipados a la cafetería escolar para evitar filas y agilizar la entrega de alimentos.

---

## 🚀 Características Principales

**🧑‍🎓 Módulo Estudiante:**
* **Splash Screen Premium:** Animaciones de entrada fluidas y diseño "Glass Waves".
* **Menú Digital en Tiempo Real:** Catálogo interactivo con promociones en formato carrusel.
* **Carrito de Compras Inteligente:** Sumatoria en tiempo real, función *Swipe-to-Delete* y selección de método de pago (Efectivo/Terminal).
* **Seguimiento Animado:** Sala de espera inmersiva con cambio de estados dinámicos (Recibido -> En Preparación -> Listo) acompañados de la mascota oficial.

**🏪 Módulo Cafetería (Administrativo):**
* **Acceso Seguro:** Login rápido mediante Código Único (PIN) para agilizar la entrada de los empleados.
* **Dashboard de Comandas:** Tarjetas interactivas con el detalle completo del pedido, notas del cliente y método de pago.
* **Gestión de Estados:** Flujo de preparación con actualización visual instantánea.
* **Gestión de Menú:** Panel para dar de alta nuevos platillos o marcarlos como "Agotados".

---

## 🛠️ Stack Tecnológico

**Frontend & UI/UX:**
* Framework: **Flutter (iOS & Android)**
* Lenguaje: **Dart**
* Librerías UI: `animate_do` (Animaciones), `google_fonts` (Tipografías), `google_nav_bar` (Navegación), `carousel_slider` (Promociones).

**Backend & Base de Datos (Fase de Integración):**
* **Firebase** (Authentication, Cloud Firestore, Storage)

**Herramientas & Control de Versiones:**
* **Git / GitHub** (Desarrollo bajo filosofía de control de versiones semántico).
* **Krita** (Diseño de assets y mascota oficial de la app).

---

## 👥 Equipo de Desarrollo

* **Axel Guerrero Alonso**
* **Dana Patricia Calderón García**

---

## 📦 Historial de Versiones (Changelog)
El proyecto se desarrolla de manera progresiva y modular.

* **`v0.8.0`** - Diseño Premium (Splash Screen, Mesh Gradient y UI/UX avanzada).
* **`v0.7.0`** - Integración de Identidad Visual (Mascotas en módulo de Cafetería).
* **`v0.6.0`** - Ventanas modales para detalle de pedidos en tiempo real.
* **`v0.5.0`** - Selección de métodos de pago (Efectivo / Tarjeta).
* **`v0.4.1`** - Dashboard Administrativo: Gestión de Menú (BottomNavigationBar).
* **`v0.4.0`** - Formulario de registro estudiantil validado.
* **`v0.2.2`** - Generador de códigos de orden y sala de espera dinámica.
* **`v0.1.0`** - Estructura base, mockups de login y enrutamiento principal.
* **`v0.0.3`** - Fix: Resolución de entorno Java/Gradle para compilación en Android.

---

## ⚙️ Cómo ejecutar este proyecto localmente

1. **Requisitos previos:** Tener instalado Flutter y **Java 17 (JDK)**.
2. Clonar este repositorio: `git clone [URL_DEL_REPO]`
3. Entrar a la carpeta del proyecto: `cd tese-food-app`
4. Instalar dependencias: `flutter pub get`
5. Ejecutar en emulador o dispositivo físico: `flutter run`
