import 'package:flutter/material.dart';

class GolfScoreCard extends StatelessWidget {
  const GolfScoreCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E3A5F), // Un azul oscuro para parecerse al diseño
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Columna izquierda (Hoyo y par/distancia)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1', // Número de hoyo
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'P4 522', // Par y yardas
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
          
              // Columna central (Nombre y jugada)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'ZALATORIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Línea tipo “1 2 3 4 FOR BIRDIE”
                  Row(
                    children: [
                      for (int i = 1; i <= 4; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            '$i',
                            style: TextStyle(
                              color: i == 3
                                  ? Colors.lightBlueAccent
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Text(
                        'FOR BIRDIE',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          
              // Columna derecha (Posición y score)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'T4',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'E', // Score
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
