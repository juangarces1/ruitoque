import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tee.dart';

class Campo {
  int id;
  String nombre;
  String ubicacion;
  List<Hoyo> hoyos;
  List<Tee> tees;

  Campo({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.hoyos,
    required this.tees,
  });

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id: json['id'],
      nombre: json['nombre'],
      ubicacion: json['ubicacion'],
      hoyos: json['hoyos'] != null
        ? (json['hoyos'] as List).map((hoyoJson) => Hoyo.fromJson(hoyoJson)).toList()
        : [],
      tees: json['tees'] != null
        ? (json['tees'] as List).map((teeJson) => Tee.fromJson(teeJson)).toList()
        : [],  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Nombre': nombre,
      'Ubicacion': ubicacion,
      'Hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
      'tees': tees.map((tee) => tee.toJson()).toList(),
    };
  }

  int get numeroHoyos => hoyos.length;

  int get par => hoyos.fold(0, (sum, hoyo) => sum + hoyo.par);

  // int get ida => hoyos.take(9).fold(0, (sum, hoyo) => sum + hoyo.par);


  // int get vuelta => hoyos.skip(hoyos.length - 9).fold(0, (sum, hoyo) => sum + hoyo.par);

  int get ida {
    // Calcula la mitad de los hoyos, redondeando hacia abajo si es impar.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold(0, (sum, hoyo) => sum + hoyo.par);
  }

  int get vuelta {
    // Inicia desde la mitad hasta el final.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad ? hoyos.skip(mitad).fold(0, (sum, hoyo) => sum + hoyo.par) : 0;
  }

}
