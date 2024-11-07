import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/skin.dart';

class SkinsResult {
  final List<Skin> skins;
  final Map<Jugador, int> skinsPorJugador;

  SkinsResult({
    required this.skins,
    required this.skinsPorJugador,
  });
}
