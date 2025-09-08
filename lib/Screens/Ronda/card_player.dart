import 'package:flutter/material.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
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
    
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: widget.isSelected ? kPsecondaryColor.withOpacity(0.28) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: widget.isSelected
                ? Border.all(
                    color: kPprimaryColor.withOpacity(0.8),
                    width: 2.8,
                  )
                : Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? kPprimaryColor.withOpacity(0.25)
                    : Colors.black12,
                blurRadius: widget.isSelected ? 14 : 5,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => widget.onSelected(!widget.isSelected),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPprimaryColor,
                    radius: 27,
                    child: Text(
                      widget.jugador.nombre.isNotEmpty
                          ? widget.jugador.nombre[0].toUpperCase()
                          : "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.jugador.nombre,
                          style:  TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.isSelected ? Colors.white : kPprimaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'HCP: ${widget.jugador.handicap ?? "-"}',
                          style:  TextStyle(
                            fontSize: 18,
                            color: widget.isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                  const SizedBox(width: 6),
                  Tooltip(
                    message: "Editar Handicap",
                    child: IconButton(
                      icon: const Icon(Icons.sports_golf, color: kBlueColorLogo),
                      splashRadius: 22,
                      onPressed: () => mostrarEditarHandicapDialog(context, widget.jugador),
                    ),
                  ),
                  Tooltip(
                    message: "Editar Nombre",
                    child: IconButton(
                      icon: const Icon(Icons.drive_file_rename_outline, color: kPprimaryColor),
                      splashRadius: 22,
                      onPressed: () => mostrarEditarNombreDialog(context, widget.jugador),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Overlay check flotante solo si está seleccionado
        if (widget.isSelected)
          Positioned(
            right: 18,
            top: 6,
            child: AnimatedOpacity(
              opacity: widget.isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPprimaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: kPprimaryColor.withOpacity(0.27),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
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

  // ---------- Diálogo para editar handicap ----------
  Future<void> mostrarEditarHandicapDialog(BuildContext context, Jugador jugador) async {
    int updatedHandicap = jugador.handicap ?? 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.sports_golf, color: kBlueColorLogo),
                  SizedBox(width: 10),
                  Text('Editar Handicap'),
                ],
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28),
                    onPressed: () {
                      setStateDialog(() {
                        if (updatedHandicap > 0) updatedHandicap--;
                      });
                    },
                  ),
                  Text(
                    '$updatedHandicap',
                    style: const TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: kBlueColorLogo, size: 28),
                    onPressed: () {
                      setStateDialog(() {
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
                  onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      setState(() {
                        jugador.handicap = updatedHandicap;
                      });
                      await actualizarJugadorCompleto(jugador);
                    },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------- Diálogo para editar nombre ----------
  Future<void> mostrarEditarNombreDialog(BuildContext context, Jugador jugador) async {
    TextEditingController controller = TextEditingController(text: jugador.nombre);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.drive_file_rename_outline, color: kPprimaryColor),
              SizedBox(width: 10),
              Text('Editar Nombre'),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: "Nombre",
              border: OutlineInputBorder(),
            ),
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
              onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    jugador.nombre = controller.text.trim();
                  });
                  await actualizarJugadorCompleto(jugador);
                },
            ),
          ],
        );
      },
    );
  }

  Future<void> actualizarJugadorCompleto(Jugador jugador) async {
  setState(() => showLoader = true);

  final resp = await ApiHelper.put("/api/players/${jugador.id}", jugador.toJson());

  setState(() => showLoader = false);

  if (resp.isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Actualización exitosa")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${resp.message}")),
    );
  }
}
}
