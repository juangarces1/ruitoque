import 'package:flutter/material.dart';
import 'package:ruitoque/Models/tarjeta.dart';

class CardResumenTarjeta extends StatelessWidget {
  final Tarjeta tarjeta;
  const CardResumenTarjeta
({super.key, required this.tarjeta});

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
          title: const Text('Resumen Ronda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: <Widget>[
            ListTile(
              title: const Text('Score', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                tarjeta.puntuacionTotal.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.green),
            ),
             ListTile(
              title: const Text('Gross', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                tarjeta.gross.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.green),
            ),
             ListTile(
              title: const Text('Neto', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                tarjeta.neto.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.green),
            ),
               ListTile(
              title: const Text('Putts', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                tarjeta.totalPutts.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              trailing: const Icon(Icons.golf_course, color: Colors.green),
            ),
             ListTile(
              title: const Text('Fairways Acertados', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text(
                tarjeta.porcentajeAciertoFairway,
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
