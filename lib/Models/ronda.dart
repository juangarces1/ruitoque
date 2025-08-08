import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/fede_amigos.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/skin.dart';
import 'package:ruitoque/Models/skin_result.dart';
import 'package:ruitoque/Models/stable_ford_hoyo.dart';
import 'package:ruitoque/Models/stableford_result.dart';
import 'package:ruitoque/Models/tarjeta.dart';

class Ronda {
   int id;
   DateTime fecha;
   List<Tarjeta> tarjetas; // Asegúrate de que tienes una clase 'Tarjeta' definida en Dart.
   Campo campo; // Asegúrate de que tienes una clase 'Campo' definida en Dart.
   int? handicapPorcentaje;
   int? campoId;
   bool isComplete;
   int? creatorId;
   int? torneoId;
   List<Skin>? skins = [];
   StablefordResult? stablefordResult; 
   FedeAmigosResult? fedeAmigosResult;

  Ronda({
    required this.id,
    required this.fecha,
    required this.tarjetas,
    required this.campo,
    required this.handicapPorcentaje,
    this.campoId,
    required this.isComplete,
    this.creatorId,
    this.skins,
    this.stablefordResult,
    this.fedeAmigosResult,
    this.torneoId,
  });

  factory Ronda.fromJson(Map<String, dynamic> json) {
    return Ronda(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      tarjetas: (json['tarjetas'] as List).map((item) => Tarjeta.fromJson(item)).toList(),
      campo: Campo.fromJson(json['campo']),
      campoId: json['campoId'],
      isComplete: json['isComplete'],
      creatorId: json['creatorId'],
      handicapPorcentaje: json['handicapPorcentaje'],
      torneoId: 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'tarjetas': tarjetas.map((tarjeta) => tarjeta.toJson()).toList(),
       // 'campo': campo.toJson(),
        'campoId': campoId,
        'isComplete': isComplete,
        'creatorId': creatorId,
        'handicapPorcentaje': handicapPorcentaje,
        'torneoId': torneoId,
      };

    void calcularSkins() {     
      SkinsResult resultado = _calcularSkins();
      skins = resultado.skins;
    // Opcional: Puedes almacenar skinsPorJugador si lo deseas
  }   

   void calcularStableford() {
    stablefordResult = _calcularStableford(this);
  }

   StablefordResult _calcularStableford(Ronda ronda) {
    List<StablefordHoyo> puntosPorHoyo = [];
    Map<Jugador, int> puntosTotalesPorJugador = {};

    if (ronda.tarjetas.isEmpty) {
      return StablefordResult(puntosPorHoyo: puntosPorHoyo, puntosTotalesPorJugador: puntosTotalesPorJugador);
    }

    // Asumiendo que todos los Tarjetas tienen la misma cantidad de hoyos
    int totalHoyos = ronda.tarjetas.first.hoyos.length;

    for (int i = 0; i < totalHoyos; i++) {
      List<MapEntry<Jugador, int>> puntosHoyo = [];

      for (Tarjeta tarjeta in ronda.tarjetas) {
        EstadisticaHoyo estadistica = tarjeta.hoyos[i];
        // Asegurarse de que el jugador y el neto estén disponibles
        if (tarjeta.jugador != null) {
          int diferencia = estadistica.neto - estadistica.hoyo.par;
          int puntos = _asignarPuntosStableford(diferencia);
          puntosHoyo.add(MapEntry(tarjeta.jugador!, puntos));

          // Actualizar puntos totales por jugador
          if (puntosTotalesPorJugador.containsKey(tarjeta.jugador!)) {
            puntosTotalesPorJugador[tarjeta.jugador!] = puntosTotalesPorJugador[tarjeta.jugador!]! + puntos;
          } else {
            puntosTotalesPorJugador[tarjeta.jugador!] = puntos;
          }

          // Agregar puntos por hoyo
          puntosPorHoyo.add(StablefordHoyo(
            holeNumber: estadistica.hoyo.numero,
            jugador: tarjeta.jugador!,
            puntos: puntos,
          ));
        }
      }
    }

    return StablefordResult(
      puntosPorHoyo: puntosPorHoyo,
      puntosTotalesPorJugador: puntosTotalesPorJugador,
    );
  }

  int _asignarPuntosStableford(int diferencia) {
    // Diferencia = golpes - par
    // Eagle: diferencia <= -2 -> 4 puntos
    // Birdie: diferencia == -1 -> 3 puntos
    // Par: diferencia == 0 -> 2 puntos
    // Bogey: diferencia == 1 -> 1 punto
    // Doble Bogey o más: diferencia >= 2 -> 0 puntos

    if (diferencia <= -2) {
      return 4; // Eagle
    } else if (diferencia == -1) {
      return 3; // Birdie
    } else if (diferencia == 0) {
      return 2; // Par
    } else if (diferencia == 1) {
      return 1; // Bogey
    } else {
      return 0; // Doble Bogey o más
    }
  }



    
  SkinsResult _calcularSkins() {
    List<Skin> skins = [];
    Map<Jugador, int> skinsPorJugador = {};

    if (tarjetas.isEmpty) {
      return SkinsResult(skins: skins, skinsPorJugador: skinsPorJugador);
    }

    // Asumiendo que todos los Tarjetas tienen la misma cantidad de hoyos
    int totalHoyos = tarjetas.first.hoyos.length;

    for (int i = 0; i < totalHoyos; i++) {
      List<MapEntry<Jugador, int>> puntajesPorHoyo = [];

      for (Tarjeta tarjeta in tarjetas) {
        EstadisticaHoyo estadistica = tarjeta.hoyos[i];
        // Asegurarse de que el jugador y el neto estén disponibles
        if (tarjeta.jugador != null) {
          puntajesPorHoyo.add(MapEntry(tarjeta.jugador!, estadistica.neto));
        }
      }

      if (puntajesPorHoyo.isEmpty) {
        continue; // No hay datos para este hoyo
      }

      // Encontrar el puntaje mínimo
      int minScore = puntajesPorHoyo.map((e) => e.value).reduce((a, b) => a < b ? a : b);

      // Encontrar todos los jugadores que tienen el puntaje mínimo
      List<MapEntry<Jugador, int>> ganadores = puntajesPorHoyo
          .where((entry) => entry.value == minScore)
          .toList();

      if (ganadores.length == 1) {
        // Solo un ganador, se otorga un skin
        Jugador ganador = ganadores.first.key;
        Skin skin = Skin(
          holeNumber: i + 1,
          ganador: ganador,
          scoreNeto: minScore,
        );
        skins.add(skin);

        // Actualizar el conteo de skins por jugador
        if (skinsPorJugador.containsKey(ganador)) {
          skinsPorJugador[ganador] = skinsPorJugador[ganador]! + 1;
        } else {
          skinsPorJugador[ganador] = 1;
        }
      }
      // Si hay más de un ganador (empate), no se otorga ningún skin
    }

    return SkinsResult(skins: skins, skinsPorJugador: skinsPorJugador);
  }

   void  calcularFedeAmigos() {
    // Inicializar puntos por jugador
    Map<Jugador, double> puntosPorJugador = {};
    for (Tarjeta tarjeta in tarjetas) {
      if (tarjeta.jugador != null) {
        puntosPorJugador[tarjeta.jugador!] = 0.0;
      }
    }

    // Lista para almacenar los ganadores de los hoyos
    List<FedeAmigosHoyoGanado> hoyosGanados = [];

    // Número total de hoyos
    int totalHoyos = tarjetas.first.hoyos.length;

    // 1. Determinar ganadores de cada hoyo y asignar puntos
    for (int i = 0; i < totalHoyos; i++) {
      // Mapear jugador a su puntaje neto en el hoyo
      Map<Jugador, int> netScores = {};

      for (Tarjeta tarjeta in tarjetas) {
        if (tarjeta.jugador != null) {
          EstadisticaHoyo hoyo = tarjeta.hoyos[i];
          netScores[tarjeta.jugador!] = hoyo.neto;
                }
      }

      // Encontrar el puntaje neto mínimo
      int minNetScore = netScores.values.reduce((a, b) => a < b ? a : b);

      // Obtener jugadores empatados con el puntaje mínimo
      List<Jugador> tiedPlayers = netScores.entries
          .where((entry) => entry.value == minNetScore)
          .map((entry) => entry.key)
          .toList();

      Jugador holeWinner;

      if (tiedPlayers.length == 1) {
        // Ganador único
        holeWinner = tiedPlayers.first;
      } else {
        // Realizar desempate
        holeWinner = _resolveTie(tiedPlayers, i, totalHoyos);
      }

      // Asignar 1 punto al ganador del hoyo
      puntosPorJugador[holeWinner] = puntosPorJugador[holeWinner]! + 1.0;

      // Añadir a la lista de hoyos ganados
      hoyosGanados.add(FedeAmigosHoyoGanado(
          holeNumber: i + 1, ganador: holeWinner));
    }

    // 2. Asignar puntos para netIda, netVuelta y totalNeto
   List<PosicionCategoria> posicionesIda = _assignPointsAndPositionsForCategory('netIda', puntosPorJugador);
    List<PosicionCategoria> posicionesVuelta = _assignPointsAndPositionsForCategory('netVuelta', puntosPorJugador);
    List<PosicionCategoria> posicionesTotal = _assignPointsAndPositionsForCategory('totalNeto', puntosPorJugador);

    // Almacenar el resultado
    fedeAmigosResult = FedeAmigosResult(
      puntosPorJugador: puntosPorJugador,
      hoyosGanados: hoyosGanados,
      posicionesIda: posicionesIda,
      posicionesVuelta: posicionesVuelta,
      posicionesTotal: posicionesTotal,
    );
  }

  Jugador _resolveTie(List<Jugador> tiedPlayers, int currentHoleIndex, int totalHoyos) {
    int nextHoleIndex = currentHoleIndex;
    while (true) {
      nextHoleIndex = (nextHoleIndex + 1) % totalHoyos;

      // Mapear jugador a su puntaje neto en el siguiente hoyo
      Map<Jugador, int> netScoresNextHole = {};

      for (Tarjeta tarjeta in tarjetas) {
        if (tarjeta.jugador != null && tiedPlayers.contains(tarjeta.jugador)) {
          EstadisticaHoyo hoyo = tarjeta.hoyos[nextHoleIndex];
          netScoresNextHole[tarjeta.jugador!] = hoyo.neto;
                }
      }

      // Encontrar el puntaje neto mínimo entre los jugadores empatados
      int minNetScore = netScoresNextHole.values.reduce((a, b) => a < b ? a : b);

      tiedPlayers = netScoresNextHole.entries
          .where((entry) => entry.value == minNetScore)
          .map((entry) => entry.key)
          .toList();

      if (tiedPlayers.length == 1) {
        // Se encontró un ganador
        return tiedPlayers.first;
      }

      // Si hemos vuelto al hoyo original y aún hay empate, elegir el primer jugador
      if (nextHoleIndex == currentHoleIndex) {
        return tiedPlayers.first;
      }
    }
  }

    // 2. Asignar 4 puntos para la Primera Vuelta (Ida)
      List<PosicionCategoria> _assignPointsAndPositionsForCategory(String category, Map<Jugador, double> puntosPorJugador) {
    // Mapear jugador a su puntaje neto en la categoría
    Map<Jugador, int> netScores = {};

    for (Tarjeta tarjeta in tarjetas) {
      if (tarjeta.jugador != null) {
        int netScore;
        if (category == 'netIda') {
          netScore = tarjeta.netoSimpleIda;
        } else if (category == 'netVuelta') {
          netScore = tarjeta.netoSimpleVuelta;
        } else if (category == 'totalNeto') {
          netScore = tarjeta.netoSimpleTotal;
        } else {
          netScore = 999;
        }
        netScores[tarjeta.jugador!] = netScore;
      }
    }

    // Ordenar jugadores por puntaje neto ascendente
    List<MapEntry<Jugador, int>> sortedPlayers = netScores.entries.toList();
    sortedPlayers.sort((a, b) => a.value.compareTo(b.value));

    // Puntos por posición
    Map<int, double> pointsPerPosition = {
      1: 2.0,
      2: 1.0,
      3: 1.0,
    };

    int index = 0;
    int position = 1;
    List<PosicionCategoria> posiciones = [];

    while (index < sortedPlayers.length && position <= 3) {
      int currentScore = sortedPlayers[index].value;
      List<Jugador> tiedPlayers = [];

      // Recopilar jugadores con el mismo puntaje
      while (index < sortedPlayers.length && sortedPlayers[index].value == currentScore) {
        tiedPlayers.add(sortedPlayers[index].key);
        index++;
      }

      // Calcular puntos totales para las posiciones empatadas
      double totalPoints = 0.0;
      int numPositions = 0;
      for (int p = position; p <= 3 && numPositions < tiedPlayers.length; p++, numPositions++) {
        totalPoints += pointsPerPosition[p] ?? 0.0;
      }

      double pointsPerPlayer = totalPoints / tiedPlayers.length;

      // Asignar puntos a los jugadores empatados
      for (Jugador jugador in tiedPlayers) {
        puntosPorJugador[jugador] = puntosPorJugador[jugador]! + pointsPerPlayer;
      }

      // Almacenar la posición y los jugadores
      posiciones.add(PosicionCategoria(posicion: position, jugadores: tiedPlayers));

      // Actualizar posición
      position += tiedPlayers.length;
    }

    return posiciones;
  }
  
  void calcularYAsignarPosiciones() {
  // Ordenar tarjetas por scorePar
    tarjetas.sort((a, b) => a.scorePar.compareTo(b.scorePar));

    int posicionActual = 1;

    for (int i = 0; i < tarjetas.length; i++) {
      if (i > 0 && tarjetas[i].scorePar == tarjetas[i - 1].scorePar) {
        // Misma posición para empates
        tarjetas[i].asignarPosicion(posicionActual);
      } else {
        // Nueva posición
        posicionActual = i + 1;
        tarjetas[i].asignarPosicion(posicionActual);
      }
    }
  }


}


  


