import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/constans.dart';

class PlayerCard extends StatefulWidget {
  final Jugador jugador;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;

  const PlayerCard({
    Key? key,
    required this.jugador,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    final jugadorActual = Provider.of<JugadorProvider>(context, listen: false).jugador;
    final esJugadorActual = widget.jugador.id == jugadorActual.id;

    return Stack(
      children: [
        Card(
          color: widget.isSelected ? kPsecondaryColor.withOpacity(0.3) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 4,
          shadowColor: kPprimaryColor,
          child: InkWell(
            onTap: () => widget.onSelected(!widget.isSelected),
            borderRadius: BorderRadius.circular(20.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPprimaryColor,
                    radius: 25,
                    child: Text(
                      widget.jugador.nombre[0].toUpperCase(),
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
                      widget.jugador.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPprimaryColor,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: widget.isSelected,
                    onChanged: widget.onSelected,
                    activeColor: kPprimaryColor,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: kPprimaryColor,
                    ),
                    onPressed: () => mostrarEditarDialog(context, widget.jugador, esJugadorActual),
                    tooltip: 'Editar Handicap',
                  ),
                ],
              ),
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

  Future<void> mostrarEditarDialog(BuildContext context, Jugador jugador, bool esJugadorActual) async {
    int updatedHandicap = jugador.handicap ?? 0;

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
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 28,
                    ),
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
                    icon: const Icon(
                      Icons.add_circle,
                      color: kBlueColorLogo,
                      size: 28,
                    ),
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
                    Navigator.of(dialogContext).pop();
                    goUpdateHandicap(jugador, updatedHandicap, esJugadorActual);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> goUpdateHandicap(Jugador jugador, int updatedHandicap, bool esJugadorActual) async {
      setState(() {
        jugador.handicap=updatedHandicap;
      });
  }
}