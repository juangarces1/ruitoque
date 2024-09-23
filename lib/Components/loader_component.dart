import 'package:flutter/material.dart';



class LoaderComponent extends StatelessWidget {
  final String gifPath;
  final double width;
  final double height;
  final Color backgroundColor;
  final String loadingText;
  final Color borderColor;
  final double borderWidth;

  const LoaderComponent({super.key, 
    this.gifPath = 'assets/LogoGolf.png',
    this.width = 100.0,
    this.height = 100.0,
    this.backgroundColor = Colors.blue,
    this.loadingText = '',
    this.borderColor = const Color.fromARGB(255, 24, 46, 83),
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
  return Center(
    child: Container(
      width: 160, // Ancho fijo
      height: 160, // Alto fijo
      decoration: BoxDecoration(
        color: backgroundColor, // Fondo sólido
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(12), // Borde redondeado
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10), // Espaciado dentro del borde
              child: Image.asset(
                gifPath,
                // Elimina el width y height para permitir que la imagen se escale dentro de los límites del contenedor
              ),
            ),
          ),
          const SizedBox(height: 10), // Espacio entre el GIF y el texto
          Text(
            loadingText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 10), 
        ],
      ),
    ),
  );
}

}
