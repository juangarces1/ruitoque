class CreateTorneoDto {
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int campoId;
  final List<int> jugadoresIds;

  CreateTorneoDto({
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.campoId,
    required this.jugadoresIds,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'campoId': campoId,
        'jugadoresIds': jugadoresIds,
      };
}