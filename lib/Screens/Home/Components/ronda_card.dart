import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/constans.dart';

class RondaCard extends StatelessWidget {
  final Ronda ronda;
  final VoidCallback? onDeleted;

  const RondaCard({
    Key? key,
    required this.ronda,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fechaText = "${ronda.fecha.day.toString().padLeft(2, '0')}/"
        "${ronda.fecha.month.toString().padLeft(2, '0')}/"
        "${ronda.fecha.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
            elevation: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado con color
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                  decoration: const BoxDecoration(
                    color: kPprimaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        ronda.campo.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        fechaText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Cuerpo de la tarjeta
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jugadores:",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: kPsecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: ronda.tarjetas.map((tarjeta) {
                          final jugador = tarjeta.jugador!;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: kPprimaryColor,
                                  radius: 18,
                                  child: Text(
                                    jugador.nombre.isNotEmpty
                                        ? jugador.nombre[0].toUpperCase()
                                        : "-",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    jugador.nombre,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: kPprimaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: DefaultButton(
                          text: const Text('Continuar', style: kTextStyleBlancoNuevaFuente20),
                          gradient: kGradientHome,
                          press: () => goRonda(ronda, context),
                          color: kAzulBanderaColombia,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Botón eliminar flotante (circular rojo)
      
        ],
      ),
    );
  }

  void goRonda(Ronda ronda, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiRonda(ronda: ronda),
      ),
    );
  }

 
  
}
