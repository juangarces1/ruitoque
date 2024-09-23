import 'package:flutter/material.dart';
import 'package:ruitoque/Models/jugador.dart';

class CardJugador extends StatelessWidget {
  final Jugador jugador;
  const CardJugador({super.key, required this.jugador});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xC3F2EFEF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
         
          children: <Widget>[
             Text('Hola!! ${jugador.nombre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('Handicap', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                jugador.handicap.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.edit, color: Colors.amber),
            ),
            // Aquí puedes agregar más ListTile si tienes más información para mostrar
          ],
        ),
      ),
    );
  }
}
