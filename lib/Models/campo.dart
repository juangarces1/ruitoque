import 'package:ruitoque/Models/hoyo.dart';

class Campo {
  int id;
  String nombre;
  String ubicacion;
  List<Hoyo> hoyos;

  Campo({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.hoyos,
  });

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id: json['Id'],
      nombre: json['Nombre'],
      ubicacion: json['Ubicacion'],
      hoyos: (json['Hoyos'] as List).map((hoyoJson) => Hoyo.fromJson(hoyoJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Nombre': nombre,
      'Ubicacion': ubicacion,
      'Hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
    };
  }

  int get numeroHoyos => hoyos.length;

  int get par => hoyos.fold(0, (sum, hoyo) => sum + hoyo.par);

  int get ida => hoyos.take(9).fold(0, (sum, hoyo) => sum + hoyo.par);


  int get vuelta => hoyos.skip(hoyos.length - 9).fold(0, (sum, hoyo) => sum + hoyo.par);

}
