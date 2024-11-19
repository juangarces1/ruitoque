import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Ronda/card_player.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/constans.dart';

class SelectPlayersScreen extends StatefulWidget {
  final Campo campoSeleccionado;
  final String teeSeleccionado;

  const SelectPlayersScreen({
    Key? key,
    required this.campoSeleccionado,
    required this.teeSeleccionado,
  }) : super(key: key);

  @override
  SelectPlayersScreenState createState() => SelectPlayersScreenState();
}

class SelectPlayersScreenState extends State<SelectPlayersScreen> {
  bool showLoader = false;
  List<Jugador> jugadores = [];
  List<Jugador> jugadoresSeleccionados = [];
  late Jugador jugadorActual;
  bool isJugadoresLoaded = false;

  @override
  void initState() {
    super.initState();
    getJugadores();
    jugadorActual = Provider.of<JugadorProvider>(context, listen: false).jugador;
    jugadoresSeleccionados.add(jugadorActual);
  }

  Future<void> getJugadores() async {
    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.getPlayers();

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(response.message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return;
    }

    setState(() {
      jugadores = response.result;
      jugadores.removeWhere((j) => j.id == jugadorActual.id);
      isJugadoresLoaded = true;
    });
  }

  void mostrarSnackBar(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> goRonda() async {
    if (jugadoresSeleccionados.isEmpty) {
      mostrarSnackBar(context, 'Por favor, seleccione al menos un jugador.');
      return;
    }

    Ronda ronda = Ronda(
      id: 0,
      fecha: DateTime.now(),
      tarjetas: [],
      campo: widget.campoSeleccionado,
      campoId: widget.campoSeleccionado.id,
      isComplete: false,
      creatorId: jugadorActual.id,
    );

    for (Jugador jugadorItem in jugadoresSeleccionados) {
      Tarjeta tarjeta = Tarjeta(
        handicapPlayer: jugadorItem.handicap!,
        id: 0,
        jugadorId: jugadorItem.id,
        rondaId: 0,
        jugador: jugadorItem,
        hoyos: [],
        campo: widget.campoSeleccionado,
        teeSalida: widget.teeSeleccionado,
      );

      for (Hoyo hoyo in widget.campoSeleccionado.hoyos) {
        EstadisticaHoyo aux = EstadisticaHoyo(
          id: 0,
          hoyo: hoyo,
          hoyoId: hoyo.id,
          golpes: 0,
          putts: 0,
          bunkerShots: 0,
          acertoFairway: false,
          falloFairwayIzquierda: false,
          falloFairwayDerecha: false,
          penaltyShots: 0,
          shots: [],
          handicapPlayer: jugadorItem.handicap,
          nombreJugador: jugadorItem.nombre,
          isMain: jugadorItem.id == jugadorActual.id ? true : false,
        );
        tarjeta.hoyos.add(aux);
      }

      ronda.tarjetas.add(tarjeta);
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MiRonda(ronda: ronda),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _getContent() {
    return Container(
        decoration: const BoxDecoration(
              gradient: kPrimaryGradientColor
             ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Seleccione Jugadores:',
                style: kTextStyleBlancoNuevaFuente20,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
           
              child: isJugadoresLoaded
                  ? ListView(
                      children: [
                        // Mostrar al jugador actual primero
                        PlayerCard(
                          jugador: jugadorActual,
                          isSelected: true,
                          onSelected: (value) {
                            // No permitir deseleccionar al jugador actual
                            mostrarSnackBar(
                                context, 'No puede deseleccionar al jugador principal.');
                          },
                        ),
                        const SizedBox(height: 10),
                        // Mostrar otros jugadores
                        ...jugadores.map((jugadorItem) {
                          bool isSelected = jugadoresSeleccionados.contains(jugadorItem);
      
                          return Column(
                            children: [
                              PlayerCard(
                                jugador: jugadorItem,
                                isSelected: isSelected,
                                onSelected: (bool? value) {
                                  setState(() {
                                    if (value != null && value) {
                                      jugadoresSeleccionados.add(jugadorItem);
                                    } else {
                                      jugadoresSeleccionados.remove(jugadorItem);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: DefaultButton(
              text: const Text(
                'Iniciar Ronda',
                style: kTextStyleBlancoNuevaFuente20,
                textAlign: TextAlign.center,
              ),
              press: () => goRonda(),
              gradient: kPrimaryGradientColor,
              color: kPsecondaryColor,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: 'Agregar Jugadores',
        automaticallyImplyLeading: true,
        backgroundColor: kPprimaryColor,
        elevation: 8.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipOval(
              child: Image.asset(
                'assets/LogoGolf.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kFondoGradient),
        child: Center(
          child: showLoader
              ? const MyLoader(
                  opacity: 0.8,
                  text: 'Cargando...',
                )
              : _getContent(),
        ),
      ),
    );
  }
}
