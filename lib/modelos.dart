import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // LA MAGIA DE FIREBASE

class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;
  final String categoria;
  final IconData icono;
  final String descripcion;
  final double calificacion;
  final String tiempoPrep;
  final bool popular;
  final List<String> ingredientes;
  final List<String> personalizacion;

  Platillo({
    required this.id,
    required this.nombre,
    required this.local,
    required this.precio,
    this.categoria = 'Comida',
    this.icono = Icons.fastfood,
    this.descripcion = '',
    this.calificacion = 4.5,
    this.tiempoPrep = '10 min',
    this.popular = false,
    this.ingredientes = const [],
    this.personalizacion = const [],
  });

  Platillo copyWith({List<String>? personalizacion}) {
    return Platillo(
      id: id,
      nombre: nombre,
      local: local,
      precio: precio,
      categoria: categoria,
      icono: icono,
      descripcion: descripcion,
      calificacion: calificacion,
      tiempoPrep: tiempoPrep,
      popular: popular,
      ingredientes: ingredientes,
      personalizacion: personalizacion ?? this.personalizacion,
    );
  }

  // ========================================================
  // ✨ TRADUCTOR FIREBASE -> FLUTTER
  // Toma el "Documento" de la nube y lo convierte en un Platillo
  // ========================================================
  factory Platillo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Platillo(
      id: doc.id, // El ID de letras raras que autogeneró Firebase
      nombre: data['nombre'] ?? 'Sin Nombre',
      local: data['local'] ?? 'Cafetería',
      precio: (data['precio'] ?? 0).toDouble(), // Asegura que sea decimal
      categoria: data['categoria'] ?? 'Comida',
      descripcion: data['descripcion'] ?? '',
      calificacion: (data['calificacion'] ?? 5.0).toDouble(),
      tiempoPrep: data['tiempoPrep'] ?? '15 min',
      popular: data['popular'] ?? false,

      // Si la base de datos trae ingredientes, los lee. Si no, pone lista vacía.
      ingredientes:
          data['ingredientes'] != null
              ? List<String>.from(data['ingredientes'])
              : [],

      // Lógica de íconos automáticos basados en el texto de Firebase
      icono: _iconoPorCategoria(data['categoria']),
    );
  }

  // Función auxiliar para decidir qué ícono dibujar
  static IconData _iconoPorCategoria(String? categoria) {
    if (categoria == 'Desayunos') return Icons.breakfast_dining;
    if (categoria == 'Bebidas') return Icons.local_drink;
    if (categoria == 'Postres') return Icons.cake;
    return Icons.lunch_dining; // Por defecto
  }
}
