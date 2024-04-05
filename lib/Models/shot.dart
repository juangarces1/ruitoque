class Shot {
  double latitud;
  double longitud;

  Shot({
    required this.latitud,
    required this.longitud,
  });

  // Método para convertir un objeto Shot a un mapa (útil para convertir a JSON)
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // Método para crear un objeto Shot desde un mapa (útil para convertir desde JSON)
  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
    );
  }
}
