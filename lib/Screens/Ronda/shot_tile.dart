import 'package:flutter/material.dart';
import 'package:ruitoque/Models/shot.dart';

class ShotTile extends StatelessWidget {
  final int index;
  final Shot shot;
  final Function() onDelete;

  const ShotTile({
    Key? key,
    required this.index,
    required this.shot,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Ajusta el ancho según tus necesidades
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 75, 75, 75), // Color de fondo
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          child: Text('${index + 1}'),
        ),
        title: Text(
          '${shot.distancia}y',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
