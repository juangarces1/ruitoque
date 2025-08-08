import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/shot.dart';

class EstadisticaHoyo {
   int id;
   Hoyo hoyo; // Asegúrate de que tienes una clase 'Hoyo' definida en Dart.
   int hoyoId;
   int golpes;
   int putts;
   int bunkerShots;
   int penaltyShots;
   bool acertoFairway;
   bool falloFairwayIzquierda;
   bool falloFairwayDerecha;
  
   List<Shot>? shots;
   int? handicapPlayer;
   String? nombreJugador;
   bool? isMain;
   int? handicapPorcentaje;
   

  EstadisticaHoyo({
    required this.id,
    required this.hoyo,
    required this.hoyoId,
    required this.golpes,
    required this.putts,
    required this.bunkerShots,
    required this.penaltyShots,
    required this.acertoFairway,
    required this.falloFairwayIzquierda,
    required this.falloFairwayDerecha,   
    this.shots,
    this.handicapPlayer,
    this.nombreJugador,
    this.isMain,
    this.handicapPorcentaje,
  });

  bool get acertoGreen {
    if ((golpes - putts) <= 2 ) {
      return true;
    }
    else {
      return false;
    }

  }

   int get pontajeVsPar {
    return  golpes - hoyo.par;
  }

  //make a get field nema handicapAplicado que sea el handicap del jugador multiplicado por el handicapPorcentaje
  int? get handicapAplicado {
    if (handicapPlayer != null && handicapPorcentaje != null) {
      return (handicapPlayer! * handicapPorcentaje!/100).round();
    }
    return null;
  }

   int get neto {
    // Si no hay handicapAplicado o el hoyo no tiene handicap, devolvemos golpes
    if (handicapAplicado == null || hoyo.handicap == null) {
      return golpes;
    }

    int descuento = 0;
    int aux = handicapAplicado! - hoyo.handicap!;

    // Si el hoyo entra dentro de los golpes "cubiertos" por el handicap
    if (hoyo.handicap! <= handicapAplicado!) {
      if (aux >= 0 && aux < 18) {
        descuento = 1;
      } else if (aux >= 18) {
        descuento = 2;
      }
    }
    return golpes - descuento;
  }


  

  bool get salvoElPar {
    return golpes <= hoyo.par;
  }

  bool get alcanzoGreenEnRegulacion {
    int golpesAlGreen = golpes - putts;
    int golpesEsperados = hoyo.par - 2;
    return golpesAlGreen <= golpesEsperados;
  }




  factory EstadisticaHoyo.fromJson(Map<String, dynamic> json) {
    return EstadisticaHoyo(
      id: json['id'],
     // hoyo: Hoyo(id: 0, numero: 0, nombre: '', par: 0, campoId: 0),
      hoyo: Hoyo.fromJson(json['hoyo']), // Utiliza Hoyo.fromJson si hoyo es un objeto complejo
      hoyoId: json['hoyoId'],
      golpes: json['golpes'],
      putts: json['putts'],
      bunkerShots: json['bunkerShots'],
      penaltyShots: json['penaltyShots'],
      acertoFairway: json['acertoFairway'],
      falloFairwayIzquierda: json['falloFairwayIzquierda'],
      falloFairwayDerecha: json['falloFairwayDerecha'],     
      shots: json['shots'] != null 
        ? (json['shots'] as List).map((item) => Shot.fromJson(item)).toList() 
        : [], // Li
        handicapPlayer: json['handicapPlayer'] ?? 0  ,
      nombreJugador: json['nombreJugador'],
      isMain: json['isMain'],  
      handicapPorcentaje: json['handicapPorcentaje'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
       //   'hoyo': hoyo.toJson(),
      'hoyoId': hoyoId,
      'golpes': golpes,
      'putts': putts,
      'bunkerShots': bunkerShots,
      'penaltyShots': penaltyShots,
      'acertoFairway': acertoFairway,
      'falloFairwayIzquierda': falloFairwayIzquierda,
      'falloFairwayDerecha': falloFairwayDerecha,
      'neto': neto,
      'shots': shots?.map((x) => x.toJson()).toList(),
      'handicapPlayer' : handicapPlayer,
      'nombreJugador' : nombreJugador,
      'isMain' : isMain,
      'handicapPorcentaje' : handicapPorcentaje,
    };
  }
}
