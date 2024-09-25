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
   int? neto;
   List<Shot>? shots;
   int? handicapPlayer;


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
    this.shots,
    this.handicapPlayer,
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
 
    int descuento = 0;
    int aux = handicapPlayer! - hoyo.handicap!;
    if (hoyo.handicap! <= handicap) {
     
     if (aux > 0 && aux < 18){
       descuento=1;
     } 
     if(aux >= 18){
        descuento=2;
     }
    }
    neto = golpes - descuento;
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
      neto: json['neto'],
      shots: json['shots'] != null 
        ? (json['shots'] as List).map((item) => Shot.fromJson(item)).toList() 
        : [], // Li
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
    };
  }
}
