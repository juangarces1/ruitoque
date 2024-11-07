import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/constans.dart';

class CardJugador extends StatefulWidget {
  
  const CardJugador({super.key,});

  @override
  State<CardJugador> createState() => _CardJugadorState();
}

class _CardJugadorState extends State<CardJugador> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    final jugadorProvider = Provider.of<JugadorProvider>(context);
    final jugador = jugadorProvider.jugador;
    return Stack(
      children: [
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          shadowColor: kPprimaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: kPprimaryColor,
                      radius: 25,
                      child: Text(
                        jugador.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        jugador.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPprimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildHandicapTile(jugador),
                const SizedBox(height: 10),
                
              ],
            ),
          ),
        ),
        if (showLoader)
          const MyLoader(
            opacity: 1,
            text: 'Actualizando...',
          ),
      ],
    );
  }

  Widget _buildHandicapTile(Jugador jugador) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Handicap',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                jugador.handicap.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 22, 88, 48),
                ),
                onPressed: () => mostrarEditarDialog(context, jugador),
                tooltip: 'Editar Handicap',
              ),
            ],
          ),
        ],
      ),
    );
  }




  Future<void> mostrarEditarDialog(BuildContext context, Jugador jugador) async {
    int updatedHandicap = jugador.handicap!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: kPprimaryColor,
                  ),
                  SizedBox(width: 10),
                  Text('Editar Handicap'),
                ],
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28,),
                    onPressed: () {
                      setState(() {
                        if (updatedHandicap > 0) {
                          updatedHandicap--;
                        }
                      });
                    },
                  ),
                  Text(
                    '$updatedHandicap',
                    style: const TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: kBlueColorLogo, size: 28,),
                    onPressed: () {
                      setState(() {
                        updatedHandicap++;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kPprimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Guardar'),
                  onPressed: () {
                    goUpdate(updatedHandicap);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> goUpdate(int valorActualizado) async {
    setState(() {
      showLoader = true;
    });

     final jugadorProvider = Provider.of<JugadorProvider>(context, listen: false);

    jugadorProvider.setJugador(
      jugadorProvider.jugador.copyWith(handicap: -1), // Un valor temporal para el estado de carga, indica que está actualizando
    );

    Response response = await ApiHelper.updateHandicap(
            jugadorProvider.jugador.id, valorActualizado);

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
      
      jugadorProvider.setJugador(
        jugadorProvider.jugador.copyWith(handicap: jugadorProvider.jugador.handicap),
      );
      return;
    
    }

    Fluttertoast.showToast(
      msg: "Handicap actualizado exitosamente.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: kPcontrastMoradoColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    jugadorProvider.setJugador(
      jugadorProvider.jugador.copyWith(handicap: valorActualizado),
    );
  }
}
