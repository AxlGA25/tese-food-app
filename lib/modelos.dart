import 'package:flutter/material.dart';

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
  final List<String> ingredientes; // Los que trae de fábrica
  final List<String>
  personalizacion; // Los que eligió el alumno (Ej: "Sin Cebolla")

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

  // Truco de Senior: Esta función clona el platillo pero con los cambios del usuario
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
}
