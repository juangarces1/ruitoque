import 'package:flutter/material.dart';
import 'package:ruitoque/Models/campo.dart';

class CardCampo extends StatelessWidget {
  final Campo campo;
  final Function onPressed;
  const CardCampo({super.key, required this.campo, required this.onPressed});

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
          title: Text('Campo: ${campo.nombre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: <Widget>[
            ListTile(
              title: const Text('Hoyos', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                campo.numeroHoyos.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.flag, color: Colors.green),
            ),
            ListTile(
              title: const Text('Par Campo', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                campo.par.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.numbers, color: Colors.deepPurpleAccent),
            ),
              ElevatedButton(onPressed:  () => onPressed(),
                     child: const Text('Iniciar Ronda')
                     ),
          ],
        ),
      ),
    );
  }
}
