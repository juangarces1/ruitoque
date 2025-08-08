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
  int handicapPlayer;
  List<EstadisticaHoyo> hoyos;
  String? teeSalida;
  String? fecha;
  String? campoNombre;
  int? posicion;

  Tarjeta({
    required this.id,
    required this.jugadorId,
    required this.rondaId,
    this.jugador,
    required this.hoyos,
    this.campo,
    this.porcentajeHandicap,
    required this.handicapPlayer,
    this.teeSalida,
    this.fecha,
    this.campoNombre,
    this.posicion,
  });

  int get puntuacionTotal => hoyos.fold(0, (total, h) => total + h.golpes);

  int get puntuacionIda => hoyos.fold(0, (total, h) => total + h.golpes);

  int get parCampo => hoyos.fold(0, (total, h) => total + h.hoyo.par);

  int get totalPutts => hoyos.fold(0, (total, h) => total + h.putts);

  int get gross => puntuacionTotal;

  int get neto => puntuacionTotal - (handicapPlayer);

  /// NUEVO: netoIda solo cuenta hoyos con golpes > 0 en la primera mitad
  int get netoIda {
    int mitad = (hoyos.length / 2).floor();
    // Tomar la mitad y filtrar hoyos con golpes > 0
    return hoyos
        .take(mitad)
        .where((h) => h.golpes > 0)
        .fold<int>(0, (total, h) => total + (h.neto ?? 0));
  }

  /// NUEVO: netoVuelta solo cuenta hoyos con golpes > 0 en la segunda mitad
  int get netoVuelta {
    int mitad = (hoyos.length / 2).floor();
    // Tomar la otra mitad y filtrar hoyos con golpes > 0
    return hoyos.length > mitad
        ? hoyos
            .skip(mitad)
            .where((h) => h.golpes > 0)
            .fold<int>(0, (total, h) => total + (h.neto ?? 0))
        : 0;
  }

  /// NUEVO: totalNeto = suma de netoIda y netoVuelta
  int get totalNeto => (netoIda) + (netoVuelta);

  // Cantidad de hoyos con golpes para determinar el par efectivo
  int get sumaParHoyosConGolpes => hoyos
      .where((hoyo) => hoyo.golpes > 0)
      .fold(0, (total, hoyo) => total + hoyo.hoyo.par);

  /// NUEVO: scorePar = totalNeto - par de los hoyos con golpes
  int get scorePar => totalNeto - sumaParHoyosConGolpes;

  String get scoreParString {
    if (scorePar == 0) {
      return 'E';
    } else if (scorePar > 0) {
      return '+$scorePar';
    } else {
      return '$scorePar';   
    }
  }

  int get parIda {
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold(0, (total, h) => total + h.hoyo.par);
  }

  int get parVuelta {
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad
        ? hoyos.skip(mitad).fold(0, (sum, hoyo) => sum + hoyo.hoyo.par)
        : 0;
  }

  int get scoreIda {
    int mitad = (hoyos.length / 2).floor();
    return hoyos.take(mitad).fold(0, (total, h) => total + h.golpes);
  }

  int get scoreVuelta {
    int mitad = (hoyos.length / 2).floor();
    return hoyos.length > mitad
        ? hoyos.skip(mitad).fold(0, (sum, hoyo) => sum + hoyo.golpes)
        : 0;
  }

  int get totalFairwaysHit => hoyos.where((h) => h.acertoFairway).length;

  int get totalFalloFairwayIzquierda =>
      hoyos.where((h) => h.falloFairwayIzquierda).length;

  int get totalFalloFairwayDerecha =>
      hoyos.where((h) => h.falloFairwayDerecha).length;

  int get hoyosConMasDeDosPutts => hoyos.where((h) => h.putts > 2).length;

  int get totalGreensEnRegulacion =>
      hoyos.where((h) => h.alcanzoGreenEnRegulacion).length;

  double get porcentajeGreensEnRegulacion {
    if (hoyos.isEmpty) return 0.0;
    return (totalGreensEnRegulacion / hoyos.length) * 100;
  }

  double get promedioPuttsPorHoyo {
    if (hoyos.isEmpty) return 0.0; // Evitar división por cero
    return totalPutts / hoyos.length;
  }

  int get fallosEnGIR =>
      hoyos.where((h) => !h.alcanzoGreenEnRegulacion).length;

  int get salvadasTrasFalloGIR =>
      hoyos.where((h) => !h.alcanzoGreenEnRegulacion && h.salvoElPar).length;

  double get porcentajeScrambling {
    if (fallosEnGIR == 0) return 0.0; // Evitar división por cero
    return (salvadasTrasFalloGIR / fallosEnGIR) * 100;
  }

  String get porcentajeAciertoFairway {
    if (hoyos.isEmpty) return '0%';
    int totalAciertos = hoyos.where((h) => h.acertoFairway).length;
    double porcentaje = (totalAciertos / hoyos.length) * 100;
    return '${porcentaje.toStringAsFixed(0)}%';
  }

  int get longestShotDistance {
    int maxDistance = 0;
    for (var hoyo in hoyos) {
      if (hoyo.shots != null) {
        for (var shot in hoyo.shots!) {
          if (shot.distancia > maxDistance) {
            maxDistance = shot.distancia;
          }
        }
      }
    }
    return maxDistance;
  }

   /// Calcula la mitad “entera” del handicap (descartando decimales)
  int get _handicapHalfFloor => handicapPlayer ~/ 2;

  /// Calcula la otra mitad (incluye el +1 si el handicap es impar)
  int get _handicapHalfCeil => (handicapPlayer + 1) ~/ 2;

  /// Neto simple total = gross – handicap completo
  int get netoSimpleTotal => gross - handicapPlayer;

  /// Neto simple Ida = scoreIda – *primera* mitad del handicap
  /// (por convención suele usarse la parte “ceil” en los primeros 9 hoyos)
  int get netoSimpleIda => scoreIda - _handicapHalfCeil;

  /// Neto simple Vuelta = scoreVuelta – *segunda* mitad del handicap
  int get netoSimpleVuelta => scoreVuelta - _handicapHalfFloor;

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'],
      jugadorId: json['jugadorId'],
      rondaId: json['rondaId'],
      jugador: json['jugador'] != null ? Jugador.fromJson(json['jugador']) : null,
      fecha: json['fecha'],
      campoNombre: json['campoNombre'],
      hoyos: (json['hoyos'] as List)
          .map((h) => EstadisticaHoyo.fromJson(h))
          .toList(),
      teeSalida: json['teeSalida'],
      handicapPlayer: json['handicapPlayer'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jugadorId': jugadorId,
        'rondaId': rondaId,
        'teeSalida': teeSalida,
        'hoyos': hoyos.map((hoyo) => hoyo.toJson()).toList(),
        'handicapPlayer': handicapPlayer,
      };

    void asignarPosicion(int nuevaPosicion) {
    posicion = nuevaPosicion;
  }

  /// Cambia el handicap del jugador **y** actualiza instantáneamente
/// todos los hoyos para mantenerlos sincronizados.
void actualizarHandicapJugador(int nuevoHcp,) {
  handicapPlayer    = nuevoHcp;
 

  // Aplica porcentaje (90 %, 100 %, etc.)
  

  for (final h in hoyos) {
     h.handicapPlayer      = nuevoHcp;
    
  }
}

  
  @override
  String toString() {
    return 'Tarjeta(id: $id, jugadorId: $jugadorId, rondaId: $rondaId, handicapPlayer: $handicapPlayer, hoyos: $hoyos)';
  }
}
