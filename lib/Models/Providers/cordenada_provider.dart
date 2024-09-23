import 'package:flutter/material.dart';
import 'package:ruitoque/Models/cordenada.dart';
 // Asegúrate de importar tu modelo

class CordenadaProvider with ChangeNotifier {
  Cordenada _cordenada = Cordenada(id: 1, latitud: 0.0, longitud: 0.0);

  CordenadaProvider(Cordenada cordenada);

  Cordenada get cordenada => _cordenada;

  void actualizarCordenada(double nuevaLatitud, double nuevaLongitud) {
    _cordenada.latitud = nuevaLatitud;
    _cordenada.longitud = nuevaLongitud;
    notifyListeners(); // Notifica a los widgets que están escuchando
  }

  void actualizarPorObjeto(Cordenada nuevaCordenada) {
    _cordenada = nuevaCordenada;
    notifyListeners();
  }
}
