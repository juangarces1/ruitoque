import 'package:ruitoque/Models/hoyo.dart';

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
   int? neto;


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
    this.neto,
    
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

   void calcularNetoPorHoyo(Hoyo hoyo, double handicap) {
    // int golpesDeHandicapParaHoyo = _calcularGolpesDeHandicapParaHoyo(hoyo);
    // return golpes - golpesDeHandicapParaHoyo;
    int descuento = 0;
    if (hoyo.handicap! <= handicap) {
     
      descuento = 1;
    }
    neto = golpes - descuento;
  }



  // Opcional: Si necesitas un método para convertir un mapa JSON en una instancia de EstadisticaHoyo
  factory EstadisticaHoyo.fromJson(Map<String, dynamic> json) {
    return EstadisticaHoyo(
      id: json['id'],
      hoyo: Hoyo.fromJson(json['hoyo']), // Asegúrate de tener un método 'fromJson' en la clase Hoyo.
      hoyoId: json['hoyoId'],
      golpes: json['golpes'],
      putts: json['putts'],
      bunkerShots: json['bunkerShots'],
      penaltyShots: json['penaltyShots'],
      acertoFairway: json['acertoFairway'],
      falloFairwayIzquierda: json['falloFairwayIzquierda'],
      falloFairwayDerecha: json['falloFairwayDerecha'],
    
    );
  }

   Map<String, dynamic> toJson() => {
        'id': id,
        'hoyo': hoyo.toJson(), // Asegúrate de que la clase 'Hoyo' tenga un método 'toJson'.
        'hoyoId': hoyoId,
        'golpes': golpes,
        'putts': putts,
        'bunkerShots': bunkerShots,
        'penaltyShots': penaltyShots,
        'acertoFairway': acertoFairway,
        'falloFairwayIzquierda': falloFairwayIzquierda,
        'falloFairwayDerecha': falloFairwayDerecha,
      };
}
