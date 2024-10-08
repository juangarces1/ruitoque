import 'package:flutter/material.dart';
import 'package:ruitoque/Models/hoyo_tee.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/add_hoyo_tee.dart';

class HoyoTeesListWidget extends StatelessWidget {
  final List<HoyoTee> hoyoTees;
  final Function(HoyoTee) onDelete;
  final Function(HoyoTee) onUpdate;
  final Function(HoyoTee) onAddHoyo;
  final List<Tee> tees;

  const HoyoTeesListWidget({Key? key, required this.hoyoTees, required this.onDelete, required this.onUpdate, required this.tees, required this.onAddHoyo}) : super(key: key);

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      // Llama a la función de edición cuando el botón es presionado
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddHoyoTeesPage(
                              cordenada: hoyoTee.cordenada,
                              onEditTee : (tee) => onUpdate(tee),
                              onAddHoyoTee : (tee) => onAddHoyo(tee),
                              availableTees:   tees.where((t) => t.color == hoyoTee.color).toList(),
                              hoyoTee: hoyoTee,
                            ),
                          ),
                        );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Llama a la función de borrado cuando el botón es presionado
                      onDelete(hoyoTee);
                    },
                  ),
                ],
              ),
            ),

        );
      },
    );
  }
}
