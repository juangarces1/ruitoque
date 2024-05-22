import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/jugador.dart';


class Tarjeta {
   int id;
   int jugadorId;
   int rondaId;
   Jugador? jugador; 
   Campo? campo;
   int? porcentajeHandicap;
   List<EstadisticaHoyo> hoyos; 
   String? teeSalida;
   String? fecha;
   String? campoNombre;
   

  Tarjeta({
    required this.id,
    required this.jugadorId,
    required this.rondaId,
    this.jugador,   
    required this.hoyos,
    this.campo,
    this.porcentajeHandicap,
    this.teeSalida,
    this.fecha,
    this.campoNombre,
  });

  

  int get puntuacionTotal => hoyos.fold(0, (total, h) => total + h.golpes);

  int get puntuacionIda => hoyos.fold(0, (total, h) => total + h.golpes);

  int get parCampo => hoyos.fold(0, (total, h) => total + h.hoyo.par);

  int get totalPutts => hoyos.fold(0, (total, h) => total + h.putts);

  int get gross => puntuacionTotal;

  int get neto =>  puntuacionTotal - jugador!.handicap! ;

  int? get netoIda {
    // Toma la mitad de los hoyos, redondeando hacia abajo si el número es impar.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold<int>(0, (total, h) => total + (h.neto ?? 0));
  }

  int? get netoVuelta {
    // Si hay menos de 9 hoyos, netoVuelta debería ser 0 o la suma de los restantes.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad ? hoyos.skip(mitad).fold<int>(0, (total, h) => total + (h.neto ?? 0)) : 0;
  }

  // int? get netoIda => hoyos.take(9).fold<int>(0, (total, h) => total + (h.neto ?? 0));

  // int? get netoVuelta => hoyos.skip(hoyos.length - 9).fold<int>(0, (total, h) => total + (h.neto ?? 0));

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

  int get parIda {
    // Toma la mitad de los hoyos, redondeando hacia abajo si el número total es impar.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold(0, (total, h) => total + h.hoyo.par);
  }

  int get parVuelta {
    // Inicia desde la mitad hasta el final. Si hay menos hoyos que la mitad, retorna 0.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad ? hoyos.skip(mitad).fold(0, (sum, hoyo) => sum + hoyo.hoyo.par) : 0;
  }

    int get scoreIda {
    // Toma la mitad de los hoyos, redondeando hacia abajo si el número total es impar.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold(0, (total, h) => total + h.golpes);
  }

  int get scoreVuelta {
    // Inicia desde la mitad hasta el final. Si hay menos hoyos que la mitad, retorna 0.
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad ? hoyos.skip(mitad).fold(0, (sum, hoyo) => sum + hoyo.golpes) : 0;
  }

  // int get scoreIda  => hoyos.take(9).fold(0, (total, h) => total + h.golpes);

  // int get scoreVuelta => hoyos.skip(hoyos.length - 9).fold(0, (sum, hoyo) => sum + hoyo.golpes);

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
     // jugador:  json['tarjetas'] != null ? Jugador.fromJson(json['jugador']) : null,
      fecha: json['fecha'],
      campoNombre:  json['campoNombre'],
      hoyos: (json['hoyos'] as List).map((h) => EstadisticaHoyo.fromJson(h)).toList(),
      teeSalida:  json['teeSalida'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jugadorId': jugadorId,
        'rondaId': rondaId,
      //  'jugador': jugador.toJson(),
        'teeSalida' : teeSalida,
        'hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
      };
}
