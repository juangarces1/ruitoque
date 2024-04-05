import 'package:ruitoque/Models/cordenada.dart';

class Hoyo {
  int id;
  Cordenada? frenteGreen;
  Cordenada? centroGreen;
  Cordenada? fondoGreen;
  Cordenada? centroHoyo;
  Cordenada? teeBlancas;
  Cordenada? teeRojas;
  Cordenada? teeAzules;
  Cordenada? teeNegras;
  Cordenada? teeAmarillas;
  int numero;
  String nombre;
  int par;
  int campoId;
  int? handicap;
  int? distanciaNegras;
  int? distamciaAzules;
  int? distanciaBlancas;
  int? distanciaAmarillas;
  int? distanciaRojas;

  Hoyo({
    required this.id,
    this.frenteGreen,
    this.centroGreen,
    this.fondoGreen,
    this.centroHoyo,
    this.teeBlancas,
    this.teeRojas,
    this.teeAzules,
    this.teeNegras,
    this.teeAmarillas,   
    this.distanciaNegras,
    this.distamciaAzules,
    this.distanciaAmarillas,
    this.distanciaBlancas,
    this.distanciaRojas,
    required this.numero,
    required this.nombre,
    required this.par,
    required this.campoId,
    this.handicap,
 
  });

 Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frenteGreen': frenteGreen?.toJson(),
      'centroGreen': centroGreen?.toJson(),
      'fondoGreen': fondoGreen?.toJson(),
      'centroHoyo': centroHoyo?.toJson(),
      'teeBlancas': teeBlancas?.toJson(),
      'teeRojas': teeRojas?.toJson(),
      'teeAzules': teeAzules?.toJson(),
      'teeNegras': teeNegras?.toJson(),
      'teeAmarillas': teeAmarillas?.toJson(),
      'numero': numero,
      'nombre': nombre,
      'par': par,
      'campoId': campoId,
      'handicap': handicap,
      'distanciaNegras': distanciaNegras,
      'distanciaAzules': distamciaAzules,
      'distanciaBlancas': distanciaBlancas,
      'distanciaAmarillas': distanciaAmarillas,
      'distanciaRojas': distanciaRojas,
    };
  }

  // Método fromJson
   factory Hoyo.fromJson(Map<String, dynamic> json) {
     return Hoyo(
       id: json['id'],
       frenteGreen: json['frenteGreen'] != null ? Cordenada.fromJson(json['frenteGreen']) : null,
       centroGreen: json['centroGreen'] != null ? Cordenada.fromJson(json['centroGreen']) : null,
       fondoGreen: json['fondoGreen'] != null ? Cordenada.fromJson(json['fondoGreen']) : null,
       centroHoyo: json['centroHoyo'] != null ? Cordenada.fromJson(json['centroHoyo']) : null,
       teeBlancas: json['teeBlancas'] != null ? Cordenada.fromJson(json['teeBlancas']) : null,
       teeRojas: json['teeRojas'] != null ? Cordenada.fromJson(json['teeRojas']) : null,
       teeAzules: json['teeAzules'] != null ? Cordenada.fromJson(json['teeAzules']) : null,
       teeNegras: json['teeNegras'] != null ? Cordenada.fromJson(json['teeNegras']) : null,
       teeAmarillas: json['teeAmarillas'] != null ? Cordenada.fromJson(json['teeAmarillas']) : null,
       numero: json['numero'],
       nombre: json['nombre'],
       par: json['par'],
       campoId: json['campoId'],
       handicap: json['handicap'],
       distanciaNegras: json['distanciaNegras'],
       distamciaAzules: json['distanciaAzules'],
       distanciaBlancas: json['distanciaBlancas'],
       distanciaAmarillas: json['distanciaAmarillas'],
       distanciaRojas: json['distanciaRojas'],
     );
   }

  // factory Hoyo.fromJson(Map<String, dynamic> json) {
  //   return Hoyo(
  //     id: json['Id'],
  //     frenteGreen: json['FrenteGreen'] != null ? Cordenada.fromJson(json['FrenteGreen']) : null,
  //     centroGreen: json['CentroGreen'] != null ? Cordenada.fromJson(json['CentroGreen']) : null,
  //     fondoGreen: json['FondoGreen'] != null ? Cordenada.fromJson(json['FondoGreen']) : null,
  //     centroHoyo: json['CentroHoyo'] != null ? Cordenada.fromJson(json['CentroHoyo']) : null,
  //     teeBlancas: json['TeeBlancas'] != null ? Cordenada.fromJson(json['TeeBlancas']) : null,
  //     teeRojas: json['TeeRojas'] != null ? Cordenada.fromJson(json['TeeRojas']) : null,
  //     teeAzules: json['TeeAzules'] != null ? Cordenada.fromJson(json['TeeAzules']) : null,
  //     teeNegras: json['TeeNegras'] != null ? Cordenada.fromJson(json['TeeNegras']) : null,
  //     teeAmarillas: json['TeeAmarillas'] != null ? Cordenada.fromJson(json['TeeAmarillas']) : null,
  //     numero: json['Numero'],
  //     nombre: json['Nombre'],
  //     par: json['Par'],
  //     campoId: json['CampoId'],
  //     handicap: json['Handicap'],
  //     distanciaNegras: json['DistanciaNegras'],
  //     distamciaAzules: json['DistanciaAzules'],
  //     distanciaBlancas: json['DistanciaBlancas'],
  //     distanciaAmarillas: json['DistanciaAmarillas'],
  //     distanciaRojas: json['DistanciaRojas'],
  //   );
  // }
  
}
