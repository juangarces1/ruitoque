import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/avatar_perfil.dart';
import 'package:ruitoque/Components/navegacion.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Screens/Perfil/perfil_screen.dart';
import 'package:ruitoque/Screens/Shell/shell_screen.dart';
import 'package:ruitoque/Theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cuenta cuántas veces se construyó cada pestaña falsa (para probar la carga diferida).
final construidas = <String, int>{};

class _Pestana extends StatefulWidget {
  final String nombre;
  const _Pestana(this.nombre);

  @override
  State<_Pestana> createState() => _PestanaState();
}

class _PestanaState extends State<_Pestana> {
  int toques = 0;

  @override
  void initState() {
    super.initState();
    construidas[widget.nombre] = (construidas[widget.nombre] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MyCustomAppBar(title: widget.nombre, actions: const [AvatarPerfil()]),
        body: Center(
          child: TextButton(onPressed: () => setState(() => toques++), child: Text('${widget.nombre}: $toques')),
        ),
      );
}

Future<JugadorProvider> _provider() async {
  SharedPreferences.setMockInitialValues({});
  final p = JugadorProvider();
  await p.setJugador(Jugador(id: 1, nombre: 'Juank', handicap: 27, pin: 6774, tarjetas: []), isRemembered: false);
  return p;
}

Future<void> _montar(WidgetTester tester, {VoidCallback? onJugar}) async {
  construidas.clear();
  final provider = await _provider();
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.claro(),
      home: ShellScreen(
        pestanas: const [_Pestana('Inicio'), _Pestana('Amigos'), _Pestana('Jugadores'), _Pestana('Campos')],
        onJugar: onJugar,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la barra muestra las 4 secciones y Jugar', (tester) async {
    await _montar(tester);
    for (final e in ['Inicio', 'Amigos', 'Jugadores', 'Campos', 'Jugar']) {
      expect(find.descendant(of: find.byType(BarraNavegacion), matching: find.text(e)), findsOneWidget);
    }
    expect(find.byType(BotonJugar), findsOneWidget);
  });

  testWidgets('cambiar de sección muestra esa pantalla', (tester) async {
    await _montar(tester);
    await tester.tap(find.descendant(of: find.byType(BarraNavegacion), matching: find.text('Campos')));
    await tester.pumpAndSettle();
    expect(find.text('Campos: 0'), findsOneWidget);
  });

  testWidgets('las secciones se construyen al abrirlas y conservan su estado', (tester) async {
    await _montar(tester);
    expect(construidas.keys, ['Inicio']);

    await tester.tap(find.text('Inicio: 0'));
    await tester.pump();
    await tester.tap(find.descendant(of: find.byType(BarraNavegacion), matching: find.text('Amigos')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BarraNavegacion), matching: find.text('Inicio')));
    await tester.pumpAndSettle();

    expect(find.text('Inicio: 1'), findsOneWidget);
    expect(construidas, {'Inicio': 1, 'Amigos': 1});
  });

  testWidgets('atrás en otra sección vuelve a Inicio', (tester) async {
    await _montar(tester);
    await tester.tap(find.descendant(of: find.byType(BarraNavegacion), matching: find.text('Jugadores')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Inicio: 0'), findsOneWidget);
  });

  testWidgets('Jugar ejecuta su acción', (tester) async {
    var jugado = false;
    await _montar(tester, onJugar: () => jugado = true);
    await tester.tap(find.byType(BotonJugar));
    await tester.pumpAndSettle();
    expect(jugado, isTrue);
  });

  testWidgets('el avatar muestra la inicial y abre el perfil con Mis Tarjetas y Mis Rondas', (tester) async {
    await _montar(tester);
    expect(find.descendant(of: find.byType(AvatarPerfil), matching: find.text('J')), findsOneWidget);

    await tester.tap(find.byType(AvatarPerfil));
    await tester.pumpAndSettle();

    expect(find.byType(PerfilScreen), findsOneWidget);
    expect(find.text('Juank'), findsOneWidget);
    expect(find.text('Hándicap 27'), findsOneWidget);
    expect(find.text('Mis Tarjetas'), findsOneWidget);
    expect(find.text('Mis Rondas'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('cerrar sesión pide confirmación y borra al jugador', (tester) async {
    await _montar(tester);
    final provider = Provider.of<JugadorProvider>(tester.element(find.byType(ShellScreen)), listen: false);
    await tester.tap(find.byType(AvatarPerfil));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(provider.jugador.nombre, isEmpty);
    expect(find.byType(PerfilScreen), findsNothing);
  });
}
