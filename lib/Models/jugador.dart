import 'package:ruitoque/Models/tarjeta.dart';

class Jugador {
   int id;
   int? handicap;
   String nombre;
   int pin;
   List<Tarjeta>? tarjetas; // Asegúrate de que tienes una clase 'Tarjeta' definida en Dart.

  Jugador({
    required this.id,
    required this.handicap,
    required this.nombre,
    required this.pin,
     this.tarjetas,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      handicap: json['handicap'] ?? 0,
      nombre: json['nombre'],
      pin: json['pin'],
      tarjetas: json['tarjetas'] != null 
        ? (json['tarjetas'] as List).map((item) => Tarjeta.fromJson(item)).toList() 
        : [], // Lista vacía si 'tarjetas' es null
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
         'handicap': handicap,
        'nombre': nombre,
        'pin': pin,
      //  'tarjetas': tarjetas!.map((tarjeta) => tarjeta.toJson()).toList(),
      };
}
