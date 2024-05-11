import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tee.dart';

class HoyoTee {
  int id;
  int hoyoId;
  Hoyo? hoyo;  // Asumiendo que existe una clase Hoyo.
  Cordenada cordenada;  // Asumiendo que existe una clase Cordenada.
  Tee? tee;  // Asumiendo que existe una clase Tee.
  int distancia;

  HoyoTee({
    required this.id,
    required this.hoyoId,
    this.hoyo,
    required this.cordenada,
    this.tee,
    required this.distancia,
  });

  // Convertir un objeto HoyoTee a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoyoId': hoyoId,
      'hoyo': hoyo?.toJson(),
      'cordenada': cordenada.toJson(),
      'tee': tee?.toJson(),
      'distancia': distancia,
    };
  }

  // Crear un objeto HoyoTee desde un mapa JSON.
  factory HoyoTee.fromJson(Map<String, dynamic> json) {
    return HoyoTee(
      id: json['id'] as int,
      hoyoId: json['hoyoId'] as int,
      hoyo: json['hoyo'] != null ? Hoyo.fromJson(json['hoyo']) : null,
      cordenada: Cordenada.fromJson(json['cordenada']),
      tee: json['tee'] != null ? Tee.fromJson(json['tee']) : null,
      distancia: json['distancia'] as int,
    );
  }
}
