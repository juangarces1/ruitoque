import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/Preferences/jugadorpreferences.dart';
import 'package:ruitoque/Models/Providers/cordenada_provider.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JugadorPreferences.init(); // Inicializa SharedPreferences

  bool isRemembered = await JugadorPreferences.esJugadorRecordado();
  Jugador jugador;
  Cordenada cordenada = Cordenada(id: 0, latitud: 0, longitud: 0);
  if (isRemembered) {
    jugador = await JugadorPreferences.recuperarJugador() ??
        Jugador(id: 0, handicap: 0, nombre: '', pin: 0, tarjetas: []);
  } else {
    jugador = Jugador(id: 0, handicap: 0, nombre: '', pin: 0, tarjetas: []);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => JugadorProvider(jugador),
        ),
        ChangeNotifierProvider(
          create: (context) => CordenadaProvider(cordenada), // Aquí inicializas tu CordenadaProvider
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruitoque App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'RobotoCondensed', // Aplica la fuente globalmente
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'RobotoCondensed',
            ),
        // Opcional: Puedes personalizar aún más el textTheme si lo deseas
        // Por ejemplo:
        // textTheme: TextTheme(
        //   headline1: TextStyle(fontFamily: 'RobotoCondensed', fontWeight: FontWeight.bold, fontSize: 32),
        //   bodyText1: TextStyle(fontFamily: 'RobotoCondensed', fontSize: 16),
        //   // Añade más estilos según tus necesidades
        // ),
      ),
      home: FutureBuilder(
        future: _getInitialScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(), // Pantalla de carga
              ),
            );
          } else {
            return snapshot.data as Widget;
          }
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen(BuildContext context) async {
    JugadorProvider jugadorProvider =
        Provider.of<JugadorProvider>(context, listen: false);
    return jugadorProvider.jugador.nombre.isNotEmpty
        ? const MyHomePage()
        : const LoginScreen();
  }
}
