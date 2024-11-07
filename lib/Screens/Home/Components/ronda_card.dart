import 'package:flutter/material.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/constans.dart';

class RondaCard extends StatelessWidget {
  final Ronda ronda;

  const RondaCard({
    Key? key,
    required this.ronda,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del campo y fecha
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Campo: ${ronda.campo.nombre}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPcontrastMoradoColor,
                ),
              ),
              subtitle: Text(
                "Fecha: ${ronda.fecha.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
           
            ),
            const SizedBox(height: 10),

            // Información de los jugadores
            const Text(
              "Jugadores:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPsecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: ronda.tarjetas.map((tarjeta) {
                Jugador jugador = tarjeta.jugador!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      // Avatar con la primera letra del jugador
                      CircleAvatar(
                        backgroundColor: kPprimaryColor,
                        radius: 20,
                        child: Text(
                          jugador.nombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Nombre del jugador
                      Expanded(
                        child: Text(
                          jugador.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPprimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Center(
              child: DefaultButton(
               text: const Text('Continuar',style: kTextStyleBlancoNuevaFuente20,),
               gradient:  kGradientHome,
               press: () => goRonda(ronda, context),
               color: kAzulBanderaColombia,
              ),
            )
          ],
        ),
      ),
    );
  }
  
  goRonda(Ronda ronda, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiRonda(ronda: ronda),
      ),
    );
  }
}
