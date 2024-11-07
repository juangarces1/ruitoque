
import 'dart:convert';

import 'package:ruitoque/Models/jugador.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JugadorPreferences {
  static const String _keyJugador = 'jugador';
  static const String _keyIsRemembered = 'isRemembered';

  static Future<void> init() async {
       final prefs = await SharedPreferences.getInstance();
  }


  static Future<void> guardarJugador(Jugador jugador, bool isRemembered) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jugadorJson = jsonEncode(jugador.toJson());
    await prefs.setString(_keyJugador, jugadorJson);
    await prefs.setBool(_keyIsRemembered, isRemembered);
  }

  static Future<Jugador?> recuperarJugador() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jugadorJson = prefs.getString(_keyJugador);
    if (jugadorJson != null) {
      return Jugador.fromJson(jsonDecode(jugadorJson));
    }
    return null;
  }

  static Future<bool> esJugadorRecordado() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsRemembered) ?? false;
  }

  static Future<void> borrarJugador() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJugador);
    await prefs.remove(_keyIsRemembered);
  }
}
