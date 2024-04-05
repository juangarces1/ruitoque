import 'package:flutter/material.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Estadisticas/Components/arc_indicator.dart';


class GolfScoreScreen extends StatelessWidget {
  final Tarjeta tarjeta;
  const GolfScoreScreen({super.key, required this.tarjeta});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              // Circular Score Indicator
              // CircularPercentIndicator(
              //   radius: 100.0,
              //   lineWidth: 13.0,
              //   animation: true,
              //   percent: 0.9, // Aquí deberás calcular el porcentaje basado en la puntuación
              //   center:  Text(
              //     tarjeta.gross.toString(),
              //     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              //   ),
              //   footer: const Text(
              //     "¡WOW! ¡QUE GRAN RONDA, JUAN! ¡ES UN NUEVO RECORD DEL CAMPO!",
              //     textAlign: TextAlign.center,
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              //   ),
              //   circularStrokeCap: CircularStrokeCap.round,
              //   progressColor: Colors.green,
              // ),

               ElevatedButton(
               onPressed: () {
                 // TODO: Agregar lógica para el botón Siguiente
               },
               child: const Text('Siguiente'),
              ),

              const ArcIndicator(maxScore: 125, score: 90, ) ,

              // Espacio entre elementos
              // const SizedBox(height: 20),
              // // Botón de Valoración con Estrellas
              // RatingBar.builder(
              //   initialRating: 3,
              //   minRating: 1,
              //   direction: Axis.horizontal,
              //   allowHalfRating: true,
              //   itemCount: 5,
              //   itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              //   itemBuilder: (context, _) => const Icon(
              //     Icons.star,
              //     color: Colors.amber,
              //   ),
              //   onRatingUpdate: (rating) {
              //     // TODO: Agregar lógica al actualizar el rating
              //   },
              // ),
      
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[
              //       buildStatisticItem(
              //         "Calles cogidas",
              //         Icons.trending_up,
              //         Colors.black,
              //         "14/18",
              //         true,
              //       ),
                  
              //     ],
              //   ),
              //    Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[
                  
              //       buildStatisticItem(
              //         "Greenes cogidos (GIR)",
              //         Icons.golf_course,
              //         Colors.black,
              //         "9/18",
              //         false,
              //       ),
              //       buildStatisticItem(
              //         "Putting",
              //         Icons.gesture,
              //         Colors.black,
              //         "32",
              //         true,
              //       ),
              //     ],
              //   ),
              // Más widgets para las Estadísticas
              // ...
              // Botón de Navegación
               ElevatedButton(
               onPressed: () {
                 // TODO: Agregar lógica para el botón Siguiente
               },
               child: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatisticItem(String title, IconData icon, Color iconColor, String value, bool isUpwardTrend) {
  return Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Icon(
            isUpwardTrend ? Icons.arrow_upward : Icons.arrow_downward,
            color: isUpwardTrend ? Colors.green : Colors.red,
          ),
        ],
      ),
    ],
  );
}


}