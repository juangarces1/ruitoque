import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/Preferences/jugadorpreferences.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';
import 'package:ruitoque/Screens/Temporales/my_home_pag.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JugadorPreferences.init();  // Inicializa SharedPreferences

  bool isRemembered = await JugadorPreferences.esJugadorRecordado();
  Jugador jugador;

  if (isRemembered) {
    jugador = await JugadorPreferences.recuperarJugador() ?? Jugador(id: 0, handicap: 0, nombre: '', pin: 0, tarjetas: []);
  } else {
    jugador = Jugador(id: 0, handicap: 0, nombre: '', pin: 0, tarjetas: []);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => JugadorProvider(jugador),
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
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder(
        future: _getInitialScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // O alguna pantalla de carga
          } else {
            return snapshot.data as Widget;
          }
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen(BuildContext context) async {
    JugadorProvider jugadorProvider = Provider.of<JugadorProvider>(context, listen: false);
    return jugadorProvider.jugador.nombre.isNotEmpty ? const MyHomePage(title: 'New ') : const LoginScreen();
  }
}


