import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tee.dart';

class AddCourse  {
  
  List<Hoyo> hoyos;
  List<Tee> tees;
  Cordenada inicio;

  AddCourse({
    required this.hoyos,
    required this.tees,
    required this.inicio,
  });

  // Método para convertir un objeto Shot a un mapa (útil para convertir a JSON)
  Map<String, dynamic> toJson() {
    return {
      'hoyos': hoyos,
      'tees': tees,
      'inicio': inicio,
    };
  }

  // Método para crear un objeto Shot desde un mapa (útil para convertir desde JSON)
  
}
