import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Theme/app_theme.dart';
import 'package:ruitoque/constans.dart';

void main() {
  final tema = AppTheme.claro();

  test('usa los colores de la marca', () {
    expect(tema.colorScheme.primary, kPprimaryColor);
    expect(tema.colorScheme.secondary, kPcontrastMoradoColor);
    expect(tema.colorScheme.onPrimary, Colors.white);
  });

  test('la fuente de toda la app es RobotoCondensed', () {
    expect(tema.textTheme.bodyMedium!.fontFamily, 'RobotoCondensed');
    expect(tema.textTheme.titleLarge!.fontFamily, 'RobotoCondensed');
  });

  testWidgets('un ElevatedButton sin estilo sale verde con texto blanco y 48 de alto', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: tema,
      home: Scaffold(body: Center(child: ElevatedButton(onPressed: () {}, child: const Text('Guardar')))),
    ));
    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final estilo = tema.elevatedButtonTheme.style!;
    expect(estilo.backgroundColor!.resolve({}), kPprimaryColor);
    expect(estilo.foregroundColor!.resolve({}), Colors.white);
    expect(tester.getSize(find.byWidget(boton)).height, greaterThanOrEqualTo(48));
  });

  testWidgets('un botón deshabilitado se ve apagado, no verde', (tester) async {
    final estilo = tema.elevatedButtonTheme.style!;
    expect(estilo.backgroundColor!.resolve({WidgetState.disabled}), isNot(kPprimaryColor));
  });

  testWidgets('los estilos que fija una pantalla mandan sobre el tema', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: tema,
      home: Scaffold(
        body: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {},
          child: const Text('Borrar'),
        ),
      ),
    ));
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(ElevatedButton), matching: find.byType(Material)),
    );
    expect(material.color, Colors.red);
  });

  testWidgets('los diálogos son blancos con esquinas redondeadas', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: tema,
      home: const Scaffold(body: AlertDialog(title: Text('Error'), content: Text('Algo pasó'))),
    ));
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(AlertDialog), matching: find.byType(Material)).first,
    );
    expect(material.color, Colors.white);
    expect((material.shape as RoundedRectangleBorder).borderRadius, BorderRadius.circular(20));
  });

  test('los SnackBar flotan y son oscuros', () {
    expect(tema.snackBarTheme.behavior, SnackBarBehavior.floating);
    expect(tema.snackBarTheme.backgroundColor!.computeLuminance(), lessThan(0.1));
  });
}
