import 'package:flutter/material.dart';
import 'package:ruitoque/Models/jugador.dart';

class CardJugador extends StatelessWidget {
  final Jugador jugador;
  const CardJugador({super.key, required this.jugador});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 242, 239, 239),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpansionTile(
          title: Text(jugador.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: <Widget>[
            ListTile(
              title: const Text('Handicap', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                jugador.handicap.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.green),
            ),
            // Aquí puedes agregar más ListTile si tienes más información para mostrar
          ],
        ),
      ),
    );
  }
}
