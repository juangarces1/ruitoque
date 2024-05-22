class Shot {
  double latitud;
  double longitud;
  int distancia;

  Shot({
    required this.latitud,
    required this.longitud,
    required this.distancia,
  });

  // Método para convertir un objeto Shot a un mapa (útil para convertir a JSON)
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
       'distancia': distancia,
    };
  }

  // Método para crear un objeto Shot desde un mapa (útil para convertir desde JSON)
  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      distancia: json['distancia'],
    );
  }
}
