import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Components/my_loader.dart';

void main() {
  testWidgets('el loader es una píldora pequeña con el texto', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MyLoader(opacity: 1, text: 'Cargando...'))));
    expect(find.text('Cargando...'), findsOneWidget);
    final tamano = tester.getSize(find.byType(ClipRRect));
    expect(tamano.height, lessThanOrEqualTo(56));
    // El ancho depende del texto (y la fuente de pruebas es más ancha que la real).
    expect(tamano.width, lessThan(300));
  });

  testWidgets('sin texto muestra "Calculando..."', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MyLoader(opacity: 1))));
    expect(find.text('Calculando...'), findsOneWidget);
  });
}
