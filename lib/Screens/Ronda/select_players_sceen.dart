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
import 'package:ruitoque/Screens/Ronda/ronda_rapida.dart';
import 'package:ruitoque/constans.dart';

class SelectPlayersScreen extends StatefulWidget {
  final Campo campoSeleccionado;
  final String teeSeleccionado;
  final int porcentajeHandicap;

  const SelectPlayersScreen({
    Key? key,
    required this.campoSeleccionado,
    required this.teeSeleccionado, required this.porcentajeHandicap,
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

   // Controladores para la creación de nuevo jugador
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _handicapController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

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
      handicapPorcentaje: widget.porcentajeHandicap,
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
          handicapPorcentaje: widget.porcentajeHandicap,
        );
        tarjeta.hoyos.add(aux);
      }

      ronda.tarjetas.add(tarjeta);
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MiRonda(ronda: ronda),
        ),
        
      );
    }
  }

void _showCreateJugadorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Jugador'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
                TextField(
                  controller: _handicapController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Handicap',
                  ),
                ),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4 dígitos)',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Crear'),
              onPressed: () async {
                final String nombre = _nombreController.text.trim();
                final String handicapStr = _handicapController.text.trim();
                final String pin = _pinController.text.trim();

                if (nombre.isEmpty || handicapStr.isEmpty || pin.length != 4) {
                  mostrarSnackBar(
                      context, 'Por favor, complete todos los campos correctamente.');
                  return;
                }

                // Parseamos el handicap a int.
                final int? handicap = int.tryParse(handicapStr);
                if (handicap == null) {
                  mostrarSnackBar(context, 'El hándicap debe ser un número válido.');
                  return;
                }

                // Aquí podrías llamar a una API para crear el jugador o
                // simplemente añadirlo a la lista local de jugadores.
                // Ejemplo de añadir localmente a la lista:
                Jugador nuevoJugador = Jugador(
                  id: 0, // Este ID se ajustaría según tu lógica o API
                  nombre: nombre,
                  handicap: handicap,
                  pin: int.parse(pin), 
                );

                Response response = await ApiHelper.post('api/Players/', nuevoJugador.toJson());

                if (!response.isSuccess) {
                  mostrarSnackBar(context, response.message);
                  return;
                }

                setState(() {
                  jugadores.add(nuevoJugador);
                });

                // Si lo deseas, podrías recargar la lista de jugadores desde
                // tu API para asegurarte de que está todo sincronizado.
                // await getJugadores();

                // Limpiamos controladores y cerramos el diálogo
                _nombreController.clear();
                _handicapController.clear();
                _pinController.clear();
                Navigator.of(context).pop();

                mostrarSnackBar(context, 'Jugador creado con éxito.');
              },
            ),
          ],
        );
      },
    );
  }

   Future<void> goRondaRapida() async {
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
      handicapPorcentaje: widget.porcentajeHandicap,
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
          handicapPorcentaje: widget.porcentajeHandicap,
        );
        tarjeta.hoyos.add(aux);
      }

      ronda.tarjetas.add(tarjeta);
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RondaRapida(ronda: ronda, ruta: 'Inicio',),
        ),       
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DefaultButton(
                  text: const Text(
                    'Iniciar Ronda',
                    style: kTextStyleBlancoNuevaFuente20,
                    textAlign: TextAlign.center,
                  ),
                  press: () => goRonda(),
                  gradient: kPrimaryGradientColor,
                  color: kPsecondaryColor,
                ),
                  DefaultButton(
                  text: const Text(
                    'Totalizar',
                    style: kTextStyleBlancoNuevaFuente20,
                    textAlign: TextAlign.center,
                  ),
                  press: () => goRondaRapida(),
                  gradient: kSecondaryGradient,
                  color: kPsecondaryColor,
                ),
              ],
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
        elevation: 4.0,
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
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateJugadorDialog();
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
