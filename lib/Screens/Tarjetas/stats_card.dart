import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/constans.dart';

class TarjetaStatsWidget extends StatelessWidget {
  final Tarjeta tarjeta;

  const TarjetaStatsWidget({Key? key, required this.tarjeta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle titleStyle = TextStyle(fontSize: 16, color: Color.fromARGB(255, 83, 83, 83));
    const TextStyle valueStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    final Color iconColor = Theme.of(context).primaryColor;
    return Scaffold(
     
     appBar: MyCustomAppBar(
          title: 'Estadísticas de la Tarjeta',
          elevation: 6,
          shadowColor: Colors.white,
          automaticallyImplyLeading: true,
          foreColor: Colors.white,
          backgroundColor: kPprimaryColor,
          actions: <Widget>[
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipOval(child:  Image.asset(
                  'assets/LogoGolf.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),), // Ícono de perfil de usuario
            ),
          ],      
        ),

    body: Container(
      decoration: const BoxDecoration(
        gradient: kPrimaryGradientColor
      ),
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 6,
        color: const Color.fromARGB(255, 226, 225, 225),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            children: [
             
          
                 const Text('FairWays',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
                   
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Fallos a la izquierda
                  _buildStatItem(
                     imagePath: 'assets/FalloIzq.png',
                    label: 'Izquierda',
                    value: '${tarjeta.totalFalloFairwayIzquierda}',
                    iconColor: iconColor,
                    titleStyle: titleStyle,
                    valueStyle: valueStyle,
                     isCentered: true,
                  ),
                  // Fairways acertados
                  _buildStatItem(
                  imagePath: 'assets/Centro.png',
                    label: 'Centro',
                    value: '${tarjeta.totalFairwaysHit}',
                    iconColor: iconColor,
                    titleStyle: titleStyle,
                    valueStyle: valueStyle,
                     isCentered: true,
                  ),
                  // Fallos a la derecha
                  _buildStatItem(
                    imagePath: 'assets/FalloDerecha.png',
                    label: 'Derecha',
                    value: '${tarjeta.totalFalloFairwayDerecha}',
                    iconColor: Colors.red,
                    titleStyle: titleStyle,
                    valueStyle: valueStyle,
                     isCentered: true,
                  ),
                ],
              ),
                const SizedBox(height: 5),
                const Divider(thickness: 3,),
                const SizedBox(height: 5),
                const Text('Putts',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),     
                            const SizedBox(height: 10),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    imagePath: 'assets/putt.webp',
                    label: 'Total',
                    value: '${tarjeta.totalPutts}',
                    iconColor: iconColor,
                    titleStyle: titleStyle,
                    valueStyle: valueStyle,
                     isCentered: true,
                  ),
                   _buildStatItem(
                  icon: Icons.plus_one,
                  label: 'Hoyos Sobre 2',
                  value: '${tarjeta.hoyosConMasDeDosPutts}',
                  iconColor: Colors.orange,
                  titleStyle: titleStyle,
                  valueStyle: valueStyle,
                  isCentered: true,
                ),
                 _buildStatItem(
                  imagePath: 'assets/putt.webp',
                  label: 'Promedio',
                  value: '${tarjeta.promedioPuttsPorHoyo}',
                  iconColor: Colors.orange,
                  titleStyle: titleStyle,
                  valueStyle: valueStyle,
                  isCentered: true,
                ),
                 
                ],
              ),
              const SizedBox(height: 5),
               const Divider(thickness: 3,),
              const SizedBox(height: 5),
              // Tercera fila
                     
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.grass, // Puedes elegir otro icono o una imagen
                      label: 'Greens en Regulación',
                      value: '${tarjeta.totalGreensEnRegulacion}',
                      iconColor: iconColor,
                      titleStyle: titleStyle,
                      valueStyle: valueStyle,
                      isCentered: true,
                    ),
                    _buildStatItem(
                      icon: Icons.percent,
                      label: 'Porcentaje GIR',
                      value: '${tarjeta.porcentajeGreensEnRegulacion.toStringAsFixed(1)}%',
                      iconColor: iconColor,
                      titleStyle: titleStyle,
                      valueStyle: valueStyle,
                       isCentered: true,
                    ),
                  ],
                ),// Nueva fila con la estadística de hoyos con más de 2 putts
                 
                const SizedBox(height: 5),
                 const Divider(thickness: 3,),
                const SizedBox(height: 5),   
                  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                     imagePath: 'assets/iconSwing.webp',
                    label: 'Golpe más largo',
                    value: '${tarjeta.longestShotDistance} m',
                    iconColor: iconColor,
                    titleStyle: titleStyle,
                    valueStyle: valueStyle,
                     isCentered: true,
                  ),
                    _buildStatItem(
                      icon: Icons.shield, // Usa un icono que represente defensa o salvación
                      label: 'Scrambling',
                      value: '${tarjeta.porcentajeScrambling.toStringAsFixed(1)}%',
                      iconColor: Colors.blue,
                      titleStyle: titleStyle,
                      valueStyle: valueStyle,
                       isCentered: true,
                    ),
                  ],
                ),// Nue
                
              ],
            ),
          ),
        ),
    )
    );
  }

 Widget _buildStatItem({
  IconData? icon,
  String? imagePath,
  required String label,
  required String value,
  required Color iconColor,
  required TextStyle titleStyle,
  required TextStyle valueStyle,
  bool isCentered = false,
}) {
  return Column(
    crossAxisAlignment:
        isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    children: [
      if (imagePath != null)
        Image.asset(
          imagePath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        //  color: iconColor, // Aplica color si es necesario
        )
      else if (icon != null)
        Icon(icon, size: 36, color: iconColor),
      const SizedBox(height: 8),
      Text(
        label,
        style: titleStyle,
        textAlign: isCentered ? TextAlign.center : TextAlign.left,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: valueStyle,
        textAlign: isCentered ? TextAlign.center : TextAlign.left,
      ),
    ],
  );
}

}
