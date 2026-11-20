import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'colores.dart';

class _VarianteIng {
  String nombre;
  bool activo;
  _VarianteIng(this.nombre, this.activo);
}

void mostrarTutorialCafeteria(BuildContext context) {
  final pasos = [
    (
      Icons.toggle_on_rounded,
      colorExito,
      'Interruptor Abierto / Cerrado',
      'Apágalo al terminar el turno. Los alumnos verán la sucursal cerrada al instante.',
    ),
    (
      Icons.soup_kitchen_rounded,
      const Color(0xFFEA580C),
      '🍳 Comandas (Cocina)',
      'Toca una tarjeta para ver detalles/alergias y avanza su estado: Cocinar ➔ Listo ➔ Entregar.',
    ),
    (
      Icons.point_of_sale_rounded,
      colorVerdeTese,
      '💰 Historial y Corte de Caja',
      'Toca las tarjetas de Vendido, Efectivo, Tarjeta o Cancelados para filtrar tus cobros del día.',
    ),
    (
      Icons.restaurant_menu_rounded,
      const Color(0xFF0284C7),
      '🍔 Menú e Inventario',
      'Sube platillos con foto, define puntos de Gachapón, activa/desactiva ingredientes (✅/❌) y ajusta stock con - y +.',
    ),
    (
      Icons.star_rounded,
      const Color(0xFFF59E0B),
      '⭐ Opiniones',
      'Consulta las estrellas y comentarios que dejan los estudiantes sobre tus platillos.',
    ),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder:
        (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
              const SizedBox(height: 14),
              Text(
                'Guía Rápida de tu Cafetería 💡',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: colorVerdeTese,
                ),
              ),
              const SizedBox(height: 12),
              ...pasos.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorFondoCrema,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: p.$2.withValues(alpha: 0.14),
                        child: Icon(p.$1, color: p.$2, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.$3,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: colorTextoOscuro,
                              ),
                            ),
                            Text(
                              p.$4,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: colorTextoGris,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVerdeTese,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '¡Entendido!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
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

class TabMenuCafeteria extends StatefulWidget {
  final String nombreLocal;
  const TabMenuCafeteria({super.key, required this.nombreLocal});

  @override
  State<TabMenuCafeteria> createState() => _TabMenuCafeteriaState();
}

class _TabMenuCafeteriaState extends State<TabMenuCafeteria> {
  final List<String> _categorias = [
    'Todos',
    'Desayunos',
    'Comida',
    'Bebidas',
    'Postres',
  ];
  String _filtroCat = 'Todos';

  String _extraerOrigenImagen(Map<String, dynamic> data) {
    final fotos = data['fotos'];
    if (fotos is List && fotos.isNotEmpty) {
      final primera = fotos.first.toString().trim();
      if (primera.isNotEmpty) {
        return primera;
      }
    }
    final candidatos = [
      data['imagenBase64'],
      data['fotoBase64'],
      data['imagen'],
      data['imagenUrl'],
      data['foto'],
    ];
    for (final c in candidatos) {
      if (c != null && c.toString().trim().isNotEmpty) {
        return c.toString().trim();
      }
    }
    return '';
  }

  Uint8List? _decodificarBase64Seguro(String raw) {
    if (raw.isEmpty) {
      return null;
    }
    try {
      final limpio = raw.contains(',') ? raw.split(',').last.trim() : raw;
      return base64Decode(limpio);
    } catch (_) {
      return null;
    }
  }

  Widget _construirImagen(String origen, {double iconSize = 28}) {
    final fallback = Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: colorVerdeTese.withValues(alpha: 0.7),
        size: iconSize,
      ),
    );
    if (origen.isEmpty) {
      return fallback;
    }
    if (origen.startsWith('http://') || origen.startsWith('https://')) {
      return Image.network(
        origen,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (origen.startsWith('assets/')) {
      return Image.asset(
        origen,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    final bytes = _decodificarBase64Seguro(origen);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }

  Future<void> _confirmarEliminar(String docId, String nombre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Eliminar platillo?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
            ),
            content: Text(
              'Se quitará "$nombre" del menú de ${widget.nombreLocal}.',
              style: GoogleFonts.poppins(fontSize: 13, color: colorTextoGris),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await FirebaseFirestore.instance
          .collection('Menu_Platillos')
          .doc(docId)
          .delete();
    }
  }

  void _abrirEditorPlatillo({String? docId, Map<String, dynamic>? existente}) {
    final esEdicion = docId != null && existente != null;
    final nombreCtrl = TextEditingController(
      text: (existente?['nombre'] ?? '').toString(),
    );
    final descCtrl = TextEditingController(
      text: (existente?['descripcion'] ?? '').toString(),
    );
    final precioCtrl = TextEditingController(
      text: existente != null ? (existente['precio'] ?? '').toString() : '',
    );
    final stockCtrl = TextEditingController(
      text:
          existente != null
              ? (existente['existencias'] ?? 15).toString()
              : '15',
    );
    final puntosCtrl = TextEditingController(
      text: existente != null ? (existente['puntos'] ?? 10).toString() : '10',
    );
    final nuevoIngCtrl = TextEditingController();

    final List<_VarianteIng> variantes = [];
    if (existente != null && existente['ingredientesConfig'] is List) {
      for (final item in (existente['ingredientesConfig'] as List)) {
        if (item is Map) {
          final n = (item['nombre'] ?? '').toString().trim();
          if (n.isNotEmpty) {
            variantes.add(_VarianteIng(n, (item['activo'] ?? true) as bool));
          }
        }
      }
    } else if (existente != null && existente['ingredientes'] is List) {
      for (final item in (existente['ingredientes'] as List)) {
        final n = item.toString().trim();
        if (n.isNotEmpty) {
          variantes.add(_VarianteIng(n, true));
        }
      }
    }

    String categoria = (existente?['categoria'] ?? 'Comida').toString();
    if (!_categorias.skip(1).contains(categoria)) {
      categoria = 'Comida';
    }

    String imagenActual =
        existente != null ? _extraerOrigenImagen(existente) : '';
    bool fotoModificada = false;
    bool guardando = false;
    final picker = ImagePicker();

    InputDecoration campo(String label, String hint) => InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: GoogleFonts.poppins(fontSize: 11.5, color: colorTextoGris),
      filled: true,
      fillColor: colorFondoCrema,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (contextModal, setModal) {
              Future<void> tomarFoto(ImageSource src) async {
                final img = await picker.pickImage(
                  source: src,
                  maxWidth: 600,
                  imageQuality: 55,
                );
                if (img != null) {
                  final bytes = await img.readAsBytes();
                  setModal(() {
                    imagenActual = base64Encode(bytes);
                    fotoModificada = true;
                  });
                }
              }

              void agregarVariante() {
                final texto = nuevoIngCtrl.text.trim();
                if (texto.isEmpty) {
                  return;
                }
                HapticFeedback.selectionClick();
                setModal(() {
                  variantes.add(_VarianteIng(texto, true));
                  nuevoIngCtrl.clear();
                });
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: MediaQuery.of(contextModal).viewInsets.bottom + 22,
                ),
                child: SingleChildScrollView(
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
                      const SizedBox(height: 12),
                      Text(
                        esEdicion ? 'Editar Platillo ✏️' : 'Nuevo Platillo 🍽️',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: colorVerdeTese,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 145,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorFondoCrema,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorVerdeTese.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child:
                            imagenActual.isNotEmpty
                                ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: _construirImagen(
                                        imagenActual,
                                        iconSize: 40,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.black
                                            .withValues(alpha: 0.6),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          onPressed:
                                              () => setModal(() {
                                                imagenActual = '';
                                                fotoModificada = true;
                                              }),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 36,
                                      color: colorVerdeTese.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sin foto todavía (opcional)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colorTextoGris,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorVerdeTese,
                                side: const BorderSide(color: colorVerdeTese),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => tomarFoto(ImageSource.camera),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 17,
                              ),
                              label: Text(
                                'Cámara',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorVerdeTese,
                                side: const BorderSide(color: colorVerdeTese),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => tomarFoto(ImageSource.gallery),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 17,
                              ),
                              label: Text(
                                'Galería',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nombreCtrl,
                        decoration: campo(
                          '1. Nombre del producto',
                          'Ej. Chilaquiles verdes con pollo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: campo(
                          '2. ¿Qué incluye? (Descripción breve)',
                          'Ej. Con crema, queso, cebolla y frijoles',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioCtrl,
                              keyboardType: TextInputType.number,
                              decoration: campo('3. Precio (\$)', '45'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: campo('4. Stock', '20'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: puntosCtrl,
                              keyboardType: TextInputType.number,
                              decoration: campo('5. Pts 🪙', '15'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: categoria,
                        decoration: campo('6. Categoría', ''),
                        items:
                            _categorias
                                .skip(1)
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModal(() => categoria = v);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '7. Ingredientes y variantes',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: colorTextoOscuro,
                        ),
                      ),
                      Text(
                        'Toca cada opción para cambiar entre ✅ Disponible y ❌ No disponible:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colorTextoGris,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nuevoIngCtrl,
                              onSubmitted: (_) => agregarVariante(),
                              decoration: campo(
                                'Agregar ingrediente o variante',
                                'Ej. Crema, Cebolla, Queso extra...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorVerdeTese,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                              ),
                              onPressed: agregarVariante,
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (variantes.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorFondoCrema,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sin ingredientes agregados aún. Escribe uno arriba y toca "+".',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: colorTextoGris,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(variantes.length, (i) {
                            final item = variantes[i];
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModal(() => item.activo = !item.activo);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                                decoration: BoxDecoration(
                                  color:
                                      item.activo
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color:
                                        item.activo
                                            ? colorExito
                                            : Colors.redAccent,
                                    width: 1.4,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.activo
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      size: 17,
                                      color:
                                          item.activo
                                              ? colorExito
                                              : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.nombre,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            item.activo
                                                ? colorVerdeOscuro
                                                : Colors.red.shade900,
                                        decoration:
                                            item.activo
                                                ? TextDecoration.none
                                                : TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setModal(() => variantes.removeAt(i));
                                      },
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorVerdeTese,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                              guardando
                                  ? null
                                  : () async {
                                    if (nombreCtrl.text.trim().isEmpty ||
                                        precioCtrl.text.trim().isEmpty) {
                                      return;
                                    }
                                    setModal(() => guardando = true);
                                    final precio =
                                        double.tryParse(
                                          precioCtrl.text.trim(),
                                        ) ??
                                        0;
                                    final stock =
                                        int.tryParse(stockCtrl.text.trim()) ??
                                        10;
                                    final puntos =
                                        int.tryParse(puntosCtrl.text.trim()) ??
                                        10;

                                    final ingredientesActivos =
                                        variantes
                                            .where((v) => v.activo)
                                            .map((v) => v.nombre)
                                            .toList();
                                    final ingredientesConfig =
                                        variantes
                                            .map(
                                              (v) => {
                                                'nombre': v.nombre,
                                                'activo': v.activo,
                                              },
                                            )
                                            .toList();

                                    final Map<String, dynamic> payload = {
                                      'nombre': nombreCtrl.text.trim(),
                                      'descripcion': descCtrl.text.trim(),
                                      'precio': precio,
                                      'existencias': stock,
                                      'categoria': categoria,
                                      'local': widget.nombreLocal,
                                      'puntos': puntos.clamp(0, 500),
                                      'ingredientes': ingredientesActivos,
                                      'ingredientesConfig': ingredientesConfig,
                                      'tiempo':
                                          (existente?['tiempo'] ?? '10-15 min')
                                              .toString(),
                                      'popular':
                                          (existente?['popular'] ?? false)
                                              as bool,
                                    };

                                    if (fotoModificada || !esEdicion) {
                                      payload['fotos'] =
                                          imagenActual.isNotEmpty
                                              ? [imagenActual]
                                              : <String>[];
                                      payload['imagenBase64'] = imagenActual;
                                    }

                                    final col = FirebaseFirestore.instance
                                        .collection('Menu_Platillos');
                                    if (esEdicion) {
                                      await col.doc(docId).update(payload);
                                    } else {
                                      await col.add(payload);
                                    }
                                    HapticFeedback.mediumImpact();
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            guardando
                                ? 'Guardando...'
                                : (esEdicion
                                    ? 'Guardar Cambios'
                                    : 'Publicar en el Menú'),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
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
        final filtrados =
            _filtroCat == 'Todos'
                ? docs
                : docs.where((d) {
                  final m = d.data() as Map<String, dynamic>;
                  return (m['categoria'] ?? 'Comida') == _filtroCat;
                }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colorVerdeTese,
            onPressed: () => _abrirEditorPlatillo(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Nuevo Platillo',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: colorVerdeTese,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Usa - / + para tu stock o toca ✏️ para editar foto, puntos Gachapón e ingredientes (✅/❌).',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorVerdeOscuro,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final cat = _categorias[i];
                    final activo = _filtroCat == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: activo ? Colors.white : colorTextoOscuro,
                        ),
                      ),
                      selected: activo,
                      selectedColor: colorVerdeTese,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => _filtroCat = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    filtrados.isEmpty
                        ? Center(
                          child: Text(
                            'Sin platillos en "$_filtroCat". Toca "+ Nuevo Platillo".',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: colorTextoGris,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 86),
                          itemCount: filtrados.length,
                          itemBuilder: (_, idx) {
                            final doc = filtrados[idx];
                            final data = doc.data() as Map<String, dynamic>;
                            final nombre =
                                (data['nombre'] ?? 'Platillo').toString();
                            final cat =
                                (data['categoria'] ?? 'Comida').toString();
                            final precio = (data['precio'] ?? 0).toDouble();
                            final stock = (data['existencias'] ?? 0) as int;
                            final puntos = (data['puntos'] ?? 0) as int;
                            final origenImg = _extraerOrigenImagen(data);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color:
                                      stock == 0
                                          ? Colors.redAccent.withValues(
                                            alpha: 0.4,
                                          )
                                          : Colors.grey.shade100,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 68,
                                      height: 68,
                                      color: colorFondoCrema,
                                      child: _construirImagen(origenImg),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.5,
                                            color: colorTextoOscuro,
                                          ),
                                        ),
                                        Text(
                                          '$cat • \$${precio.toStringAsFixed(0)} MXN',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: colorVerdeTese,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    stock > 0
                                                        ? const Color(
                                                          0xFFE8F5E9,
                                                        )
                                                        : const Color(
                                                          0xFFFFEBEE,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                stock > 0
                                                    ? 'Stock: $stock'
                                                    : 'Agotado',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      stock > 0
                                                          ? colorExito
                                                          : Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF8E1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '🪙 $puntos pts',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(
                                                    0xFFB45309,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap:
                                                  () => _abrirEditorPlatillo(
                                                    docId: doc.id,
                                                    existente: data,
                                                  ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                  color: colorVerdeTese,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap:
                                                  () => _confirmarEliminar(
                                                    doc.id,
                                                    nombre,
                                                  ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 18,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorFondoCrema,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap:
                                              () => FirebaseFirestore.instance
                                                  .collection('Menu_Platillos')
                                                  .doc(doc.id)
                                                  .update({
                                                    'existencias':
                                                        FieldValue.increment(1),
                                                  }),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.add_rounded,
                                              color: colorVerdeTese,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap:
                                              stock > 0
                                                  ? () => FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                        'Menu_Platillos',
                                                      )
                                                      .doc(doc.id)
                                                      .update({
                                                        'existencias':
                                                            FieldValue.increment(
                                                              -1,
                                                            ),
                                                      })
                                                  : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.remove_rounded,
                                              color:
                                                  stock > 0
                                                      ? Colors.redAccent
                                                      : Colors.grey.shade400,
                                              size: 18,
                                            ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
