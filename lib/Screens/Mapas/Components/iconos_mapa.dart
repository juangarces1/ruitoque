import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Dibuja la etiqueta de distancia de un tramo ("150y") como PNG, para usarla
/// como ícono de un marcador: así va pegada al mapa y no flota encima de él.
Future<Uint8List> dibujarEtiquetaPng(String texto, {required double pixelRatio}) async {
  final pr = pixelRatio;
  final painter = TextPainter(
    text: TextSpan(
      text: texto,
      style: TextStyle(color: Colors.white, fontSize: 14 * pr, fontWeight: FontWeight.bold),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final sombra = 4 * pr; // margen para que la sombra no se recorte
  final caja = Rect.fromLTWH(
    sombra,
    sombra,
    painter.width + 20 * pr,
    painter.height + 12 * pr,
  );
  final forma = RRect.fromRectAndRadius(caja, Radius.circular(12 * pr));

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas
    ..drawRRect(
      forma.shift(Offset(0, 2 * pr)),
      Paint()
        ..color = Colors.black45
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * pr),
    )
    ..drawRRect(forma, Paint()..color = Colors.black.withOpacity(0.65))
    ..drawRRect(
      forma,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pr,
    );
  painter.paint(canvas, Offset(caja.left + 10 * pr, caja.top + 6 * pr));

  final imagen = await recorder.endRecording().toImage(
        (caja.right + sombra).ceil(),
        (caja.bottom + sombra).ceil(),
      );
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
  imagen.dispose();
  return bytes!.buffer.asUint8List();
}

/// Punto redondo con borde (la bola en vuelo o dónde cayó cada golpe), como PNG.
Future<Uint8List> dibujarPuntoPng({
  required Color relleno,
  required Color borde,
  required double diametro,
  required double pixelRatio,
}) async {
  final lado = (diametro * pixelRatio).ceil();
  final centro = Offset(lado / 2, lado / 2);
  final grosorBorde = 2 * pixelRatio;
  final radio = lado / 2 - grosorBorde / 2;

  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawCircle(centro, radio, Paint()..color = relleno)
    ..drawCircle(
      centro,
      radio,
      Paint()
        ..color = borde
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorBorde,
    );

  final imagen = await recorder.endRecording().toImage(lado, lado);
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
  imagen.dispose();
  return bytes!.buffer.asUint8List();
}
