class Hoyo {
  int id;
  double latitudFrente;
  double longitudFrente;
  double latitudCentro;
  double longitudCentro;
  double latitudFondo;
  double longitudFondo;
  double latitudCentroHoyo;
  double longitudCentroHoyo;
  int numero;
  String nombre;
  int par;
  int campoId;
  int? handicap;

  Hoyo({
    required this.id,
    required this.latitudFrente,
    required this.longitudFrente,
    required this.latitudCentro,
    required this.longitudCentro,
    required this.latitudFondo,
    required this.longitudFondo,
    required this.latitudCentroHoyo,
    required this.longitudCentroHoyo,
    required this.numero,
    required this.nombre,
    required this.par,
    required this.campoId,
    this.handicap,
  });

  factory Hoyo.fromJson(Map<String, dynamic> json) {
    return Hoyo(
      id: json['id'],
      latitudFrente: json['latitudFrente'].toDouble(),
      longitudFrente: json['longitudFrente'].toDouble(),
      latitudCentro: json['latitudCentro'].toDouble(),
      longitudCentro: json['longitudCentro'].toDouble(),
      latitudFondo: json['latitudFondo'].toDouble(),
      longitudFondo: json['longitudFondo'].toDouble(),
      
        latitudCentroHoyo: json['latitudCentroHoyo'].toDouble(),
      longitudCentroHoyo: json['longitudCentroHoyo'].toDouble(),

      numero: json['numero'],
      nombre: json['nombre'],
      par: json['par'],
      campoId: json['campoId'],
      handicap:  json['handicap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'LatitudFrente': latitudFrente,
      'LongitudFrente': longitudFrente,
      'LatitudCentro': latitudCentro,
      'LongitudCentro': longitudCentro,
      'LatitudFondo': latitudFondo,
      'LongitudFondo': longitudFondo,
      'Numero': numero,
      'Nombre': nombre,
      'Par': par,
      'CampoId': campoId,
    };
  }
}
