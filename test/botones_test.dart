import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Components/botones.dart';
import 'package:ruitoque/Theme/app_theme.dart';
import 'package:ruitoque/constans.dart';

Widget _app(Widget child) =>
    MaterialApp(theme: AppTheme.claro(), home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('al tocar llama la acción', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(BotonApp(texto: 'Guardar', onPressed: () => llamadas++)));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(llamadas, 1);
  });

  testWidgets('deshabilitado no responde', (tester) async {
    await tester.pumpWidget(_app(const BotonApp(texto: 'Guardar', onPressed: null)));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(find.byKey(const Key('boton_app_semantica'))).properties.enabled, isFalse);
  });

  testWidgets('una acción asíncrona muestra carga, luego ✓, y vuelve al texto', (tester) async {
    await tester.pumpWidget(_app(BotonApp(
      texto: 'Guardar',
      onPressed: () => Future.delayed(const Duration(seconds: 1)),
    )));
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('mientras carga ignora toques repetidos', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(_app(BotonApp(
      texto: 'Guardar',
      onPressed: () {
        llamadas++;
        return Future.delayed(const Duration(seconds: 1));
      },
    )));
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(BotonApp));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(llamadas, 1);
  });

  testWidgets('si la acción falla no muestra ✓', (tester) async {
    await tester.pumpWidget(_app(BotonApp(
      texto: 'Guardar',
      onPressed: () async {
        await Future.delayed(const Duration(milliseconds: 200));
        throw Exception('sin conexión');
      },
    )));
    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('al presionar se hunde y al soltar vuelve', (tester) async {
    await tester.pumpWidget(_app(BotonApp(texto: 'Jugar', onPressed: () {})));
    double escala() => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(escala(), 1);
    final gesto = await tester.startGesture(tester.getCenter(find.byType(BotonApp)));
    await tester.pump();
    expect(escala(), lessThan(1));
    await gesto.up();
    await tester.pump();
    expect(escala(), 1);
  });

  testWidgets('tiene el alto mínimo cómodo para el pulgar', (tester) async {
    await tester.pumpWidget(_app(BotonApp(texto: 'Ok', onPressed: () {}, compacto: true)));
    expect(tester.getSize(find.byType(BotonApp)).height, greaterThanOrEqualTo(44));
    await tester.pumpWidget(_app(BotonApp(texto: 'Ok', onPressed: () {})));
    await tester.pumpAndSettle(); // el alto se anima de 44 a 56
    expect(tester.getSize(find.byType(BotonApp)).height, 56);
  });

  testWidgets('expandido ocupa todo el ancho disponible', (tester) async {
    await tester.pumpWidget(_app(SizedBox(width: 300, child: BotonApp(texto: 'Jugar', onPressed: () {}, expandido: true))));
    expect(tester.getSize(find.byType(BotonApp)).width, 300);
  });

  testWidgets('todas las variantes se dibujan', (tester) async {
    for (final v in VarianteBoton.values) {
      await tester.pumpWidget(_app(BotonApp(texto: v.name, variante: v, icono: Icons.flag, onPressed: () {})));
      expect(find.text(v.name), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    }
  });

  testWidgets('el principal es verde sólido, sin degradado', (tester) async {
    await tester.pumpWidget(_app(BotonApp(texto: 'Jugar', onPressed: () {})));
    final caja = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration as BoxDecoration;
    expect(caja.gradient, isNull);
    expect(caja.color, kPprimaryColor);
  });

  testWidgets('el principal tiene relieve que se apaga al presionar', (tester) async {
    await tester.pumpWidget(_app(BotonApp(texto: 'Jugar', onPressed: () {})));
    double brilloArriba() {
      final d = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).foregroundDecoration as BoxDecoration;
      return (d.gradient as LinearGradient).colors.first.a;
    }

    final reposo = brilloArriba();
    expect(reposo, greaterThan(0));
    final gesto = await tester.startGesture(tester.getCenter(find.byType(BotonApp)));
    await tester.pump();
    expect(brilloArriba(), lessThan(reposo));
    await gesto.up();
  });

  testWidgets('las variantes secundarias no llevan relieve', (tester) async {
    await tester.pumpWidget(_app(BotonApp(texto: 'Tonal', variante: VarianteBoton.tonal, onPressed: () {})));
    expect(tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).foregroundDecoration, isNull);
  });
}
