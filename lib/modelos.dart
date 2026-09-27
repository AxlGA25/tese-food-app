import 'package:flutter/material.dart';

class Platillo {
  final String id;
  final String nombre;
  final String local;
  final double precio;
  final String categoria;
  final IconData icono;
  Platillo({
    required this.id,
    required this.nombre,
    required this.local,
    required this.precio,
    this.categoria = 'Comida',
    this.icono = Icons.fastfood,
  });
}
