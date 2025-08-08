import 'package:flutter/material.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/constans.dart';

class CardItemCampo extends StatelessWidget {
  final Campo campo;
  final VoidCallback onTap;
  final bool isSelected;

  const CardItemCampo({
    super.key,
    required this.campo,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(
                color: kPprimaryColor,
                width: 3,
              )
            : Border.all(
                color: Colors.transparent,
                width: 0,
              ),
        color: isSelected
            ? kPsecondaryColor
            : const Color.fromARGB(255, 242, 239, 239),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? kPprimaryColor
                : Colors.black12,
            blurRadius: isSelected ? 18 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        trailing: Icon(
          Icons.golf_course_outlined,
          color: isSelected ? kPprimaryColor : kPOcre,
          size: 30,
        ),
        title: Text(
          '${campo.nombre}     Par ${campo.par.toString()}' ,
          style: kTextStyleNegroRobotoSize20.copyWith(
            color: isSelected ? Colors.white : kPcontrastMoradoColor ,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle:  campo.ubicacion.isNotEmpty
            ? Text(
               campo.ubicacion,
                style:  TextStyle(
                  color: isSelected ? Colors.white : kPcontrastMoradoColor ,
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: isSelected
            ? const Icon(
                Icons.check_circle,
                color: kPprimaryColor,
                size: 32,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      ),
    );
  }
}
