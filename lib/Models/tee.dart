class Tee {
  int id;
  int campoId;
  String color;
 
  Tee({
    required this.id,
    required this.campoId,
    required this.color,
  
  });

  // Convertir un objeto Tee a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campoId': campoId,
      'color': color,
      // Asumiendo que la clase Campo también tiene un método toJson.
    };
  }

  // Crear un objeto Tee desde un mapa JSON.
  factory Tee.fromJson(Map<String, dynamic> json) {
    return Tee(
      id: json['id'] as int,
      campoId: json['campoId'] as int,
      color: json['color'] as String,
    
    );
  }
}