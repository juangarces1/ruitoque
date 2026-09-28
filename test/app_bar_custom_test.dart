import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';

void main() {
  Future<void> montar(WidgetTester tester, Widget pantalla) =>
      tester.pumpWidget(MaterialApp(home: pantalla));

  testWidgets('el degradado ocupa toda la barra (no queda blanca)', (tester) async {
    await montar(tester, const Scaffold(appBar: MyCustomAppBar(title: 'Inicio')));
    final degradado = find.byWidgetPredicate(
      (w) => w is DecoratedBox && (w.decoration as BoxDecoration).gradient != null,
    );
    final barra = tester.getSize(find.byType(AppBar));
    expect(tester.getSize(degradado), barra);
    expect(barra.height, greaterThan(50));
  });

  testWidgets('con drawer y sin poder volver muestra el botón de menú y lo abre', (tester) async {
    await montar(
      tester,
      const Scaffold(
        drawer: Drawer(child: Text('Menú lateral')),
        appBar: MyCustomAppBar(title: 'Inicio'),
      ),
    );
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Menú lateral'), findsOneWidget);
  });

  testWidgets('en una pantalla empujada muestra atrás y vuelve', (tester) async {
    await montar(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Scaffold(appBar: MyCustomAppBar(title: 'Detalle'))),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsNothing);
  });

  testWidgets('el subtítulo aparece y agranda la barra', (tester) async {
    await montar(tester, const Scaffold(appBar: MyCustomAppBar(title: 'Mis Tarjetas', subtitle: 'Juank')));
    expect(find.text('Juank'), findsOneWidget);
    expect(tester.getSize(find.byType(AppBar)).height, greaterThan(60));
  });

  testWidgets('las esquinas inferiores son redondeadas', (tester) async {
    await montar(tester, const Scaffold(appBar: MyCustomAppBar(title: 'Inicio')));
    final degradado = tester.widget<DecoratedBox>(find.byWidgetPredicate(
      (w) => w is DecoratedBox && (w.decoration as BoxDecoration).gradient != null,
    ));
    final radio = (degradado.decoration as BoxDecoration).borderRadius as BorderRadius;
    expect(radio.bottomLeft.x, greaterThan(0));
    expect(radio.topLeft.x, 0);
  });

  testWidgets('EncabezadoMarca sin Scaffold no subraya el título', (tester) async {
    // Como la ronda en juego: MaterialApp sin Scaffold ni Material alrededor.
    await tester.pumpWidget(const MaterialApp(home: EncabezadoMarca(title: 'Los Sueños Marriot')));
    final estilo = tester.widget<DefaultTextStyle>(
      find.ancestor(of: find.text('Los Sueños Marriot'), matching: find.byType(DefaultTextStyle)).first,
    ).style;
    expect(estilo.decorationStyle, isNot(TextDecorationStyle.double));
  });

  testWidgets('EncabezadoMarca se extiende detrás de la barra de estado', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(top: 30)),
        child: Align(alignment: Alignment.topCenter, child: EncabezadoMarca(title: 'Ronda')),
      ),
    ));
    final caja = tester.getRect(find.byType(EncabezadoMarca));
    expect(caja.top, 0);
    expect(caja.height, 30 + 60);
    // El título queda debajo de la barra de estado, no detrás de ella.
    expect(tester.getRect(find.text('Ronda')).top, greaterThan(30));
  });
}
