import 'package:flutter/material.dart';

class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;
  final String descripcion;
  final String tiempoPreparacion;
  final IconData icono;
  final String categoria;
  int existencias;
  final int puntos;
  final List<String> fotos;
  final double calificacion;
  final int numCalificaciones;
  final List<String> ingredientes;
  final bool popular;
  final List<String> personalizacion;

  Platillo({
    this.id = '',
    required this.nombre,
    required this.local,
    required this.precio,
    required this.descripcion,
    String? tiempoPreparacion,
    String? tiempoPrep,
    this.icono = Icons.fastfood_rounded,
    required this.categoria,
    this.existencias = 15,
    this.puntos = 10,
    this.fotos = const [],
    this.calificacion = 5.0,
    this.numCalificaciones = 1,
    this.ingredientes = const ['Queso', 'Crema', 'Salsa', 'Cebolla'],
    this.popular = false,
    this.personalizacion = const [],
  }) : tiempoPreparacion = tiempoPreparacion ?? tiempoPrep ?? '10 - 15 min';

  String get tiempo => tiempoPreparacion;
  String get tiempoPrep => tiempoPreparacion;

  Platillo copyWith({
    String? id,
    String? nombre,
    String? local,
    double? precio,
    String? descripcion,
    String? tiempoPreparacion,
    String? tiempoPrep,
    IconData? icono,
    String? categoria,
    int? existencias,
    int? puntos,
    List<String>? fotos,
    double? calificacion,
    int? numCalificaciones,
    List<String>? ingredientes,
    bool? popular,
    List<String>? personalizacion,
  }) {
    return Platillo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      local: local ?? this.local,
      precio: precio ?? this.precio,
      descripcion: descripcion ?? this.descripcion,
      tiempoPreparacion:
          tiempoPreparacion ?? tiempoPrep ?? this.tiempoPreparacion,
      icono: icono ?? this.icono,
      categoria: categoria ?? this.categoria,
      existencias: existencias ?? this.existencias,
      puntos: puntos ?? this.puntos,
      fotos: fotos ?? this.fotos,
      calificacion: calificacion ?? this.calificacion,
      numCalificaciones: numCalificaciones ?? this.numCalificaciones,
      ingredientes: ingredientes ?? this.ingredientes,
      popular: popular ?? this.popular,
      personalizacion: personalizacion ?? this.personalizacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'local': local,
      'precio': precio,
      'descripcion': descripcion,
      'tiempoPreparacion': tiempoPreparacion,
      'tiempoPrep': tiempoPreparacion,
      'tiempo': tiempoPreparacion,
      'categoria': categoria,
      'existencias': existencias,
      'puntos': puntos,
      'fotos': fotos,
      'calificacion': calificacion,
      'numCalificaciones': numCalificaciones,
      'ingredientes': ingredientes,
      'popular': popular,
      'personalizacion': personalizacion,
    };
  }

  factory Platillo.fromMap(Map<String, dynamic> map, String documentId) {
    final String cat = (map['categoria'] ?? 'Comida').toString();
    IconData ic = Icons.fastfood_rounded;
    if (cat == 'Desayunos') ic = Icons.egg_alt_rounded;
    if (cat == 'Bebidas') ic = Icons.local_cafe_rounded;
    if (cat == 'Postres') ic = Icons.icecream_rounded;

    return Platillo(
      id: documentId,
      nombre: (map['nombre'] ?? 'Platillo TESE').toString(),
      local: (map['local'] ?? 'Cafetería Central').toString(),
      precio: (map['precio'] ?? 0.0).toDouble(),
      descripcion: (map['descripcion'] ?? 'Preparado al momento').toString(),
      tiempoPreparacion:
          (map['tiempoPreparacion'] ??
                  map['tiempoPrep'] ??
                  map['tiempo'] ??
                  '10 - 15 min')
              .toString(),
      icono: ic,
      categoria: cat,
      existencias: (map['existencias'] ?? 0) as int,
      puntos: (map['puntos'] ?? 10) as int,
      fotos: map['fotos'] != null ? List<String>.from(map['fotos']) : const [],
      calificacion: (map['calificacion'] ?? 5.0).toDouble(),
      numCalificaciones: (map['numCalificaciones'] ?? 1) as int,
      ingredientes:
          map['ingredientes'] != null
              ? List<String>.from(map['ingredientes'])
              : const ['Queso', 'Crema', 'Salsa', 'Cebolla'],
      popular: map['popular'] == true || ((map['calificacion'] ?? 5.0) >= 4.7),
      personalizacion:
          map['personalizacion'] != null
              ? List<String>.from(map['personalizacion'])
              : const [],
    );
  }

  factory Platillo.fromFirestore(Map<String, dynamic> map, String documentId) {
    return Platillo.fromMap(map, documentId);
  }
}
