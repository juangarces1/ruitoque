import 'package:flutter/foundation.dart';
import 'package:ruitoque/Models/Preferences/jugadorpreferences.dart';
import 'package:ruitoque/Models/jugador.dart';



class JugadorProvider with ChangeNotifier {
  Jugador _jugador = Jugador(id: 0, nombre: '', handicap: 0, pin: 0, tarjetas: []);

  Jugador get jugador => _jugador;

  // Constructor que carga al jugador desde preferencias si está disponible
  JugadorProvider() {
    _loadJugador();
  }

  Future<void> _loadJugador() async {
    Jugador? jugadorGuardado = await JugadorPreferences.recuperarJugador();
    if (jugadorGuardado != null) {
      _jugador = jugadorGuardado;
      notifyListeners(); // Notificar a los widgets para que se actualicen
    }
  }

  // Establecer un nuevo jugador y guardar en preferencias si necesario
  Future<void> setJugador(Jugador nuevoJugador, {bool isRemembered = true}) async {
    _jugador = nuevoJugador;
    if (isRemembered) {
      await JugadorPreferences.guardarJugador(nuevoJugador, true); // Guardar en preferencias
    }
    notifyListeners(); // Notifica a los oyentes sobre el cambio de estado
  }

  // Borrar jugador de preferencias y resetear en el provider
  Future<void> borrarJugador() async {
    await JugadorPreferences.borrarJugador();
    _jugador = Jugador(id: 0, nombre: '', handicap: 0, pin: 0, tarjetas: []);
    notifyListeners();
  }
}
