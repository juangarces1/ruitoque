import 'package:flutter/material.dart';
import 'package:ruitoque/Models/tee.dart';
import 'package:ruitoque/Screens/Campos/add_edit_teepage.dart'; // Asegúrate de importar la pantalla de agregar/editar Tee

class TeesListWidget extends StatelessWidget {
  final List<Tee> tees;
  final Function(Tee) onTeeDelete;
  final Function(Tee) onTeeEdit; 
  const TeesListWidget({Key? key, required this.tees, required this.onTeeDelete, required this.onTeeEdit,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tees.length,
      itemBuilder: (context, index) {
        final tee = tees[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Color: ${tee.color}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue), // Icono de editar
                  onPressed: () {
                    // Navegar a la pantalla de edición de Tee
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTeePage(
                          tee: tee, // Pasar el Tee actual a la pantalla de edición
                          onTeeAdded: (Tee updatedTee) {
                            onTeeEdit(updatedTee); // Llamar a la función para editar el Tee
                          },
                          onTeeUpdated: onTeeEdit,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), // Icono de eliminar
                  onPressed: () {
                    // Lógica para eliminar el Tee
                    onTeeDelete(tee);
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
