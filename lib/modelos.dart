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
  });
}
