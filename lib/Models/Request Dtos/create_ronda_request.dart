import 'package:ruitoque/Models/jugador.dart';

/// Representa el cuerpo JSON que espera el DTO `CreateRondaDto` del backend.
/// Usa DateTime → ISO-8601 y nombres de clave *exactos* para evitar problemas
/// con el binder de ASP.NET Web API 2.
class CreateRondaRequest {
  CreateRondaRequest({
    required this.fecha,
    required this.campoId,
    required this.creatorId,
    required this.jugadores,
    required this.handicapPorcentaje,
    required this.teeSalida,
  });

  /// Fecha/hora local del dispositivo.  
  /// Se serializa como cadena ISO-8601 (ej. `2025-08-01T10:30:00`).
  final DateTime fecha;

  /// Id del campo donde se jugará la ronda.
  final int campoId;

  /// Id del usuario que crea la ronda.
  final int creatorId;

  /// Lista de Ids de los jugadores que participarán.
  final  List<Jugador> jugadores;

  final int handicapPorcentaje;
  final String teeSalida;

  /// Convierte a JSON con las claves **exactamente** como las define el DTO.
  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),   // ⇦ ISO-8601
        'campoId': campoId,
        'creatorID': creatorId,             // respeta la mayúscula “ID”
        'jugadores': jugadores.map((j) => j.toJson()).toList(),
        'handicapPorcentaje': handicapPorcentaje,
        'teeSalida': teeSalida,              // nuevo campo opcional
      };

  /// (Opcional) Constructor para deserializar la respuesta del servidor.
  factory CreateRondaRequest.fromJson(Map<String, dynamic> json) {
    return CreateRondaRequest(
      fecha: DateTime.parse(json['fecha'] as String),
      campoId: json['campoId'] as int,
      creatorId: json['creatorID'] as int,
      jugadores: List<Jugador>.from(json['jugadores'] as List<dynamic>),
      handicapPorcentaje: json['handicapPorcentaje'] as int,
      teeSalida: json['teeSalida'] as String? ?? '', // Maneja el caso opcional
    );
  }
}
