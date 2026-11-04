
class Producto {
  String id;
  String nombre;
  double precio;
  int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  void aplicarDescuento(double porcentaje) {
    if (porcentaje < 0 || porcentaje > 100) {
      throw ArgumentError(
        'El descuento debe estar entre 0 y 100',
      );
    }

    precio = precio - (precio * porcentaje / 100);
  }

  String obtenerDetalles() {
    return '$nombre - Precio: \$${precio.toStringAsFixed(2)}';
  }
}

