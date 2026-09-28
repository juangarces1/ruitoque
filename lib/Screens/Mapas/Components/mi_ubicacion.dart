import 'dart:math';

import 'package:flutter/animation.dart';

/// Múltiplo de 50 yardas (desde 50) que se cruzó al pasar de [antes] a [ahora],
/// o null si no se cruzó ninguno. Si se cruzaron varios, el más cercano a [ahora].
int? marcaCruzada(int antes, int ahora, {int cada = 50}) {
  final a = antes ~/ cada, b = ahora ~/ cada;
  if (a == b) return null;
  final marca = (ahora > antes ? b : b + 1) * cada;
  return marca >= cada ? marca : null;
}

/// Un cuadro del anillo que late alrededor de mi posición.
class Pulso {
  final double radioMetros;
  final double opacidad;

  const Pulso(this.radioMetros, this.opacidad);
}

/// [t] va de 0 a 1 en cada latido: el anillo crece rápido al principio y se desvanece.
Pulso pulso(double t) {
  final crecimiento = Curves.easeOut.transform(t);
  return Pulso(3 + crecimiento * 18, 0.8 * pow(1 - t, 2).toDouble());
}

/// Radio del círculo de precisión: el GPS a veces reporta valores absurdos.
double radioPrecision(double precisionMetros) => precisionMetros.clamp(3, 50).toDouble();
