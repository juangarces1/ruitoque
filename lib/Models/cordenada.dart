class Cordenada  {
  int id;
  double latitud;
  double longitud;

  Cordenada({
    required this.id,
    required this.latitud,
    required this.longitud,
  });

  // Método para convertir un objeto Shot a un mapa (útil para convertir a JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  // Método para crear un objeto Shot desde un mapa (útil para convertir desde JSON)
  factory Cordenada.fromJson(Map<String, dynamic> json) {
    return Cordenada(
      id:  json['id'].toInt(),
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
    );
  }
}
