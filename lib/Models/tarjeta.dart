import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';


class Tarjeta {
   int id;
   int jugadorId;
   int rondaId;
   Jugador jugador; 
   Campo? campo;
   int? porcentajeHandicap;
   List<EstadisticaHoyo> hoyos; 

  Tarjeta({
    required this.id,
    required this.jugadorId,
    required this.rondaId,
    required this.jugador,   
    required this.hoyos,
    this.campo,
    this.porcentajeHandicap,
   
  });

  

  int get puntuacionTotal => hoyos.fold(0, (total, h) => total + h.golpes);

  int get puntuacionIda => hoyos.fold(0, (total, h) => total + h.golpes);

  int get parCampo => hoyos.fold(0, (total, h) => total + h.hoyo.par);

  int get totalPutts => hoyos.fold(0, (total, h) => total + h.putts);

  int get gross => puntuacionTotal;

  int get neto =>  puntuacionTotal - jugador.handicap ;

  

  int? get netoIda => hoyos.take(9).fold<int>(0, (total, h) => total + (h.neto ?? 0));

  int? get netoVuelta => hoyos.skip(hoyos.length - 9).fold<int>(0, (total, h) => total + (h.neto ?? 0));

  int get totalNeto => (netoIda ?? 0) + (netoVuelta ?? 0);

  

  int get sumaParHoyosConGolpes => hoyos
    .where((hoyo) => hoyo.golpes != 0)
    .fold(0, (total, hoyo) => total + hoyo.hoyo.par);

   int get scorePar =>   totalNeto - sumaParHoyosConGolpes;


 

  String get  scoreParString {
     
      if(scorePar == 0){
        return 'E';
      }
      else {
        return scorePar.toString();
      }
  }

  int get scoreIda  => hoyos.take(9).fold(0, (total, h) => total + h.golpes);

  int get scoreVuelta => hoyos.skip(hoyos.length - 9).fold(0, (sum, hoyo) => sum + hoyo.golpes);

  String get porcentajeAciertoFairway {
    if (hoyos.isEmpty) return '0%';

    int totalAciertos = hoyos.where((h) => h.acertoFairway).length;
    double porcentaje = (totalAciertos / hoyos.length) * 100;
    return '${porcentaje.toStringAsFixed(0)}%';
  }

 

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'],
      jugadorId: json['jugadorId'],
      rondaId: json['rondaId'],
      jugador: Jugador.fromJson(json['jugador']),
    
      hoyos: (json['hoyos'] as List).map((h) => EstadisticaHoyo.fromJson(h)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jugadorId': jugadorId,
        'rondaId': rondaId,
        'jugador': jugador.toJson(),
       
        'hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
      };
}
