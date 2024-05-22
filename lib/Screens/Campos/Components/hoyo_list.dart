import 'package:flutter/material.dart';
import 'package:ruitoque/Models/hoyo.dart';

class HoyosListWidget extends StatelessWidget {
  final List<Hoyo> hoyos;
   final Function(Hoyo) onDelete;

  const HoyosListWidget({Key? key, required this.hoyos, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hoyos.length,
      itemBuilder: (context, index) {
        final hoyo = hoyos[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(hoyo.nombre),
            subtitle: Text('Par: ${hoyo.par} - Handicap: ${hoyo.handicap}'),
             trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red,),
                  onPressed: () {
                    // Llama a la función de borrado cuando el botón es presionado
                    onDelete(hoyo);
                  },
                ),// Icono relevante para hoyo
          ),
        );
      },
    );
  }
}
