import 'package:ruitoque/Models/cordenada.dart';

class HoyoTee {
  int id;
  int hoyoId; 
  Cordenada cordenada;  // Asumiendo que existe una clase Cordenada.
  String color;
  int distancia;

  HoyoTee({
    required this.id,
    required this.hoyoId,
    required this.color,
    required this.cordenada,    
    required this.distancia,
  });

  // Convertir un objeto HoyoTee a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoyoId': hoyoId,      
      'cordenada': cordenada.toJson(),
      'color':color,
      'distancia': distancia,
    };
  }

  // Crear un objeto HoyoTee desde un mapa JSON.
  factory HoyoTee.fromJson(Map<String, dynamic> json) {
    return HoyoTee(
      id: json['id'] as int,
      hoyoId: json['hoyoId'] as int,    
      cordenada: Cordenada.fromJson(json['cordenada']),
      color: json['color'],
      distancia: json['distancia'] as int,
    );
  }
}
