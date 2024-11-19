import 'package:flutter/material.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/constans.dart';

class CardItemCampo extends StatelessWidget {
  final Campo campo;
  final VoidCallback onTap;
  const CardItemCampo({super.key, required this.campo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  Card(
        color: const Color.fromARGB(255, 242, 239, 239),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8,
      child: ListTile(
        trailing: const Icon(Icons.golf_course_outlined, color: kPOcre,),
        title: Text(
          campo.nombre,
          style: kTextStyleNegroRobotoSize20,
        ),
        onTap: onTap
      ),
    );
  }
}