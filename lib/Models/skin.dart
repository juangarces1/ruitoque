import 'package:ruitoque/Models/jugador.dart';

class Skin {
  final int holeNumber;
  final Jugador ganador;
  final int scoreNeto;
  
  Skin({
    required this.holeNumber,
    required this.ganador,
    required this.scoreNeto,
  });

  factory Skin.fromJson(Map<String, dynamic> json) {
    return Skin(
      holeNumber: json['holeNumber'],
      ganador: Jugador.fromJson(json['ganador']),
      scoreNeto: json['scoreNeto'],
    );
  }

  Map<String, dynamic> toJson() => {
        'holeNumber': holeNumber,
        'ganador': ganador.toJson(),
        'scoreNeto': scoreNeto,
      };

 

    
}
