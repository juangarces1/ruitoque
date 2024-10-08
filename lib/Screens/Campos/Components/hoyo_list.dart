import 'package:flutter/material.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/agregar_hoyos_screen.dart';

class HoyosListWidget extends StatelessWidget {
  final List<Hoyo> hoyos;
  final List<Tee> tees;
   final Function(Hoyo) onDelete;
    final Function(Hoyo) onUpdate;
   
  const HoyosListWidget({Key? key, required this.hoyos, required this.onDelete, required this.onUpdate, required this.tees,}) : super(key: key);

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
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Asegura que el Row ocupe solo el espacio necesario
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue), // Nuevo botón de editar
                  onPressed: () {
                    // Aquí llamas a la función de edición o navegas a otra pantalla
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgregarHoyosScreen(                         
                          onAgregarHoyo: onUpdate,
                          onUpdateHoyo: onUpdate,
                          tees: tees,
                          hoyo: hoyo
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), // Botón de eliminar
                  onPressed: () {
                    // Llama a la función de borrado cuando el botón es presionado
                    onDelete(hoyo);
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
