import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Helpers/osm_golf.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/buscar_campo_osm_screen.dart';

const _briceno = CampoOsm(
  nombre: 'Briceño 18',
  descripcion: 'Briceño 18, Variante, Sopó, Colombia',
  sur: 4.93, norte: 4.94, oeste: -73.98, este: -73.96,
  osmTipo: 'way', osmId: 1,
);

BorradorCampo _borrador({required int hoyos}) => BorradorCampo(
      campo: Campo(
        id: 0,
        nombre: 'Briceño 18',
        ubicacion: 'Sopó, Colombia',
        hoyos: [for (var n = 1; n <= hoyos; n++) Hoyo(id: 0, numero: n, nombre: 'Hoyo $n', par: 4, campoId: 0)],
        tees: hoyos == 0 ? [] : [Tee(id: 0, campoId: 0, color: 'Blanco')],
      ),
      greensConContorno: hoyos,
      avisos: hoyos == 0 ? const [] : const ['18 hoyos no traían handicap: quedaron en 0.'],
    );

Future<void> _abrir(
  WidgetTester tester, {
  required Future<List<CampoOsm>> Function(String) buscar,
  Future<BorradorCampo> Function(CampoOsm)? importar,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: BuscarCampoOsmScreen(buscar: buscar, importar: importar ?? (_) async => _borrador(hoyos: 18)),
  ));
}

Future<void> _buscar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al buscar lista los campos encontrados', (tester) async {
    String? consultado;
    await _abrir(tester, buscar: (t) async {
      consultado = t;
      return [_briceno];
    });

    expect(find.textContaining('Busca un campo'), findsOneWidget);
    await _buscar(tester, ' Briceño ');

    expect(consultado, 'Briceño');
    expect(find.text('Briceño 18'), findsOneWidget);
    expect(find.text('Briceño 18, Variante, Sopó, Colombia'), findsOneWidget);
  });

  testWidgets('sin resultados lo dice en vez de dejar la pantalla vacía', (tester) async {
    await _abrir(tester, buscar: (_) async => []);
    await _buscar(tester, 'Ruitoque');

    expect(find.text('No apareció ningún campo de golf'), findsOneWidget);
  });

  testWidgets('si la consulta falla ofrece reintentar', (tester) async {
    var intentos = 0;
    await _abrir(tester, buscar: (_) async {
      if (intentos++ == 0) throw Exception('sin red');
      return [_briceno];
    });
    await _buscar(tester, 'Briceño');

    expect(find.textContaining('No se pudo consultar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Briceño 18'), findsOneWidget);
  });

  testWidgets('al elegir un campo muestra qué tan completo viene', (tester) async {
    await _abrir(tester, buscar: (_) async => [_briceno]);
    await _buscar(tester, 'Briceño');
    await tester.tap(find.text('Briceño 18'));
    await tester.pumpAndSettle();

    expect(find.text('18 hoyos · par 72 · 18 greens dibujados'), findsOneWidget);
    expect(find.text('18 hoyos no traían handicap: quedaron en 0.'), findsOneWidget);
    expect(find.text('Revisar y guardar'), findsOneWidget);
  });

  testWidgets('un campo con solo el contorno ofrece crearlo a mano', (tester) async {
    await _abrir(tester, buscar: (_) async => [_briceno], importar: (_) async => _borrador(hoyos: 0));
    await _buscar(tester, 'Briceño');
    await tester.tap(find.text('Briceño 18'));
    await tester.pumpAndSettle();

    expect(find.textContaining('solo tiene el contorno'), findsOneWidget);
    expect(find.text('Crear a mano'), findsOneWidget);
  });
}
