// unirse_a_ronda_card.dart
import 'package:flutter/material.dart';
import 'package:ruitoque/constans.dart';

class UnirseARondaCard extends StatelessWidget {
  final VoidCallback onTap;

  const UnirseARondaCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: kGradientHome,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child:  const Center(
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 30,),
                     Text('Unirse a Ronda', style: kTextStyleBlancoNuevaFuente,),
                       SizedBox(width: 30,),
                    //   AspectRatio(
                    //   aspectRatio: 1,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(20.0),
                    //     child: FittedBox(
                    //       fit: BoxFit.cover,
                    //       child: SizedBox(
                    //         width: 60, // Ajusta según sea necesario
                    //         height: 60,
                    //         child: Image.asset('assets/iconSwing.webp'),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                     ],                  
                  ),
                
              ),
            ),
          ),
        );    
  }
}
