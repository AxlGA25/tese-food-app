import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;
  final String categoria;
  final IconData icono;
  final String descripcion;
  final double calificacion;
  final int numCalificaciones;
  final String tiempoPrep;
  final bool popular;
  final List<String> ingredientes;
  final List<String> personalizacion;
  final List<String> fotos; // 📸 Lista de 1 a 3 fotos en Base64

  Platillo({
    required this.id,
    required this.nombre,
    required this.local,
    required this.precio,
    this.categoria = 'Comida',
    this.icono = Icons.fastfood,
    this.descripcion = '',
    this.calificacion = 0.0,
    this.numCalificaciones = 0,
    this.tiempoPrep = '10 min',
    this.popular = false,
    this.ingredientes = const [],
    this.personalizacion = const [],
    this.fotos = const [],
  });

  Platillo copyWith({List<String>? personalizacion, List<String>? fotos}) {
    return Platillo(
      id: id,
      nombre: nombre,
      local: local,
      precio: precio,
      categoria: categoria,
      icono: icono,
      descripcion: descripcion,
      calificacion: calificacion,
      numCalificaciones: numCalificaciones,
      tiempoPrep: tiempoPrep,
      popular: popular,
      ingredientes: ingredientes,
      personalizacion: personalizacion ?? this.personalizacion,
      fotos: fotos ?? this.fotos,
    );
  }

  // ========================================================
  // ✨ TRADUCTOR FIREBASE -> FLUTTER
  // ========================================================
  factory Platillo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>? ?? {};

    return Platillo(
      id: doc.id,
      nombre: data['nombre'] ?? 'Sin Nombre',
      local: data['local'] ?? 'Cafetería',
      precio: (data['precio'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? 'Comida',
      descripcion: data['descripcion'] ?? '',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      numCalificaciones: (data['numCalificaciones'] ?? 0) as int,
      tiempoPrep: data['tiempoPrep'] ?? '15 min',
      popular: data['popular'] ?? false,
      ingredientes:
          data['ingredientes'] != null
              ? List<String>.from(data['ingredientes'])
              : [],
      // Leemos la lista de fotos (si no tiene, deja lista vacía)
      fotos: data['fotos'] != null ? List<String>.from(data['fotos']) : [],
      icono: _iconoPorCategoria(data['categoria']),
    );
  }

  static IconData _iconoPorCategoria(String? categoria) {
    if (categoria == 'Desayunos') return Icons.breakfast_dining;
    if (categoria == 'Bebidas') return Icons.local_drink;
    if (categoria == 'Postres') return Icons.cake;
    return Icons.lunch_dining;
  }
}
