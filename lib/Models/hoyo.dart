import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';

class Hoyo {
  int id;
  Cordenada? frenteGreen;
  Cordenada? centroGreen;
  Cordenada? fondoGreen;
  Cordenada? centroHoyo;
  
  int numero;
  String nombre;
  int par;
  int campoId;
  int? handicap;
  List<HoyoTee>? hoyotees;
 

  Hoyo({
    required this.id,
    this.frenteGreen,
    this.centroGreen,
    this.fondoGreen,
    this.centroHoyo,
    
    required this.numero,
    required this.nombre,
    required this.par,
    required this.campoId,
    this.handicap,
    this.hoyotees,
 
  });

 Map<String, dynamic> toJson() {
  final data = <String, dynamic>{
    'id'      : id,
    'numero'  : numero,
    'nombre'  : nombre,
    'par'     : par,
    'campoId' : campoId,
    'handicap': handicap,
  };

  // coordenadas del green (solo si existen)
  if (frenteGreen != null) data['frenteGreen'] = frenteGreen!.toJson();
  if (centroGreen  != null) data['centroGreen']  = centroGreen!.toJson();
  if (fondoGreen   != null) data['fondoGreen']   = fondoGreen!.toJson();
  if (centroHoyo   != null) data['centroHoyo']   = centroHoyo!.toJson();

  // hoyoTees: lista - si viene nula o vacía → array vacío
  data['hoyoTees'] = (hoyotees?.isNotEmpty ?? false)
      ? hoyotees!.map((e) => e.toJson()).toList()
      : <Map<String, dynamic>>[];

  return data;
}


  // Método fromJson
   factory Hoyo.fromJson(Map<String, dynamic> json) {
     return Hoyo(
       id: json['id'],
       frenteGreen: json['frenteGreen'] != null ? Cordenada.fromJson(json['frenteGreen']) : null,
       centroGreen: json['centroGreen'] != null ? Cordenada.fromJson(json['centroGreen']) : null,
       fondoGreen: json['fondoGreen'] != null ? Cordenada.fromJson(json['fondoGreen']) : null,
       centroHoyo: json['centroHoyo'] != null ? Cordenada.fromJson(json['centroHoyo']) : null,
      
       numero: json['numero'],
       nombre: json['nombre'],
       par: json['par'],
       campoId: json['campoId'],
       handicap: json['handicap'],
       hoyotees: json['hoyoTees'] != null
        ? (json['hoyoTees'] as List).map((hoyoTeeJson) => HoyoTee.fromJson(hoyoTeeJson)).toList()
        : [],
     
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
