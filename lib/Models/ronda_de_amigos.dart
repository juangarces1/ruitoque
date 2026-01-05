import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/ronda.dart';

class RondaDeAmigos {
  int id;
  String nombre;
  DateTime fecha;
  int creatorId;                    // Quien creó la RondaDeAmigos
  int? campoId;
  Campo? campo;
  String teeSeleccionado;
  int handicapPorcentaje;
  List<Ronda> rondas;               // Lista de grupos/rondas
  bool isComplete;

  RondaDeAmigos({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.creatorId,
    this.campoId,
    this.campo,
    required this.teeSeleccionado,
    required this.handicapPorcentaje,
    required this.rondas,
    required this.isComplete,
  });

  factory RondaDeAmigos.fromJson(Map<String, dynamic> json) {
    return RondaDeAmigos(
      id: json['id'],
      nombre: json['nombre'],
      fecha: DateTime.parse(json['fecha']),
      creatorId: json['creatorId'],
      campoId: json['campoId'],
      campo: json['campo'] != null ? Campo.fromJson(json['campo']) : null,
      teeSeleccionado: json['teeSeleccionado'],
      handicapPorcentaje: json['handicapPorcentaje'],
      rondas: json['rondas'] != null
          ? (json['rondas'] as List).map((item) => Ronda.fromJson(item)).toList()
          : [],
      isComplete: json['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'fecha': fecha.toIso8601String(),
        'creatorId': creatorId,
        'campoId': campoId,
        'teeSeleccionado': teeSeleccionado,
        'handicapPorcentaje': handicapPorcentaje,
        'rondas': rondas.map((ronda) => ronda.toJson()).toList(),
        'isComplete': isComplete,
      };

  /// Cantidad de grupos en esta ronda de amigos
  int get cantidadGrupos => rondas.length;

  /// Cantidad total de jugadores en todos los grupos
  int get cantidadJugadores {
    int total = 0;
    for (var ronda in rondas) {
      total += ronda.tarjetas.length;
    }
    return total;
  }

  /// Verifica si todos los grupos han completado su ronda
  bool get todosGruposCompletos {
    if (rondas.isEmpty) return false;
    return rondas.every((ronda) => ronda.isComplete);
  }

  /// Obtiene el grupo (ronda) por número
  Ronda? getGrupoPorNumero(int numero) {
    try {
      return rondas.firstWhere((r) => r.numeroGrupo == numero);
    } catch (e) {
      return null;
    }
  }

  /// Agrega un nuevo grupo
  void agregarGrupo(Ronda grupo) {
    grupo.numeroGrupo = rondas.length + 1;
    grupo.rondaDeAmigosId = id;
    rondas.add(grupo);
  }

  /// Elimina un grupo y re-numera los restantes
  void eliminarGrupo(int numeroGrupo) {
    rondas.removeWhere((r) => r.numeroGrupo == numeroGrupo);
    // Re-numerar grupos
    for (int i = 0; i < rondas.length; i++) {
      rondas[i].numeroGrupo = i + 1;
    }
  }
}
