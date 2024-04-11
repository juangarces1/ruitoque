import 'package:flutter/foundation.dart';
import 'package:ruitoque/Models/jugador.dart';


class JugadorProvider with ChangeNotifier {
  Jugador _jugador;

  JugadorProvider(this._jugador);

  Jugador get jugador => _jugador;

  void setJugador(Jugador nuevoJugador) {
    _jugador = nuevoJugador;
    notifyListeners(); // Notifica a los oyentes que algo cambió
  
  }
}
