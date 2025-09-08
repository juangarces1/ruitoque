import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/Providers/cordenada_provider.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/cordenada.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => JugadorProvider(), // Ahora solo necesitas crear el provider sin parámetros
        ),
        ChangeNotifierProvider(
          create: (context) => CordenadaProvider(Cordenada(id: 0, latitud: 0, longitud: 0)),
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
        fontFamily: 'RobotoCondensed',
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'RobotoCondensed'),
        
      ),
      home: Consumer<JugadorProvider>(
        builder: (context, jugadorProvider, child) {
          // Si el jugador tiene un nombre, se redirige a la pantalla principal
          return jugadorProvider.jugador.nombre.isNotEmpty ? const MyHomePage() : const LoginScreen();
        },
      ),
    );
  }
}
