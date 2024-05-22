import 'package:flutter/material.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';

class HoyoTeesListWidget extends StatelessWidget {
  final List<HoyoTee> hoyoTees;
  final Function(HoyoTee) onDelete;

  const HoyoTeesListWidget({Key? key, required this.hoyoTees, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hoyoTees.length,
      itemBuilder: (context, index) {
        HoyoTee hoyoTee = hoyoTees[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.flag),
            title: Text('Tee: ${hoyoTee.color}'),
            subtitle: Text('Distancia: ${hoyoTee.distancia} yds - Coordenadas: (${hoyoTee.cordenada.latitud}, ${hoyoTee.cordenada.longitud})'),
            trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red,),
                  onPressed: () {
                    // Llama a la función de borrado cuando el botón es presionado
                    onDelete(hoyoTee);
                  },
                ),
          ),
        );
      },
    );
  }
}
