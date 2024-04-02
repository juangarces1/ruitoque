import 'package:ruitoque/Models/tarjeta.dart';

class Jugador {
  final int id;
  final int handicap;
  final String nombre;
  final int pin;
  final List<Tarjeta> tarjetas; // Asegúrate de que tienes una clase 'Tarjeta' definida en Dart.

  Jugador({
    required this.id,
    required this.handicap,
    required this.nombre,
    required this.pin,
    required this.tarjetas,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      handicap: json['handicap'],
      nombre: json['nombre'],
      pin: json['pin'],
      tarjetas: (json['tarjetas'] as List).map((item) => Tarjeta.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
         'handicap': handicap,
        'nombre': nombre,
        'pin': pin,
        'tarjetas': tarjetas.map((tarjeta) => tarjeta.toJson()).toList(),
      };
}
