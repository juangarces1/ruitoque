
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ruitoque/constans.dart';


class MyLoader extends StatelessWidget {
  final String text;
  final double opacity;

  // ignore: use_key_in_widget_constructors
  const MyLoader({this.text = '', required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Center(      
        child: Opacity(
           opacity: opacity,
          child: Container(          
            width: 210,
            height: 150,
            decoration: BoxDecoration(
              color:  kPcontrastAzulColor,
              borderRadius: BorderRadius.circular(10),
              border:  Border.all(color: const Color.fromARGB(255, 5, 44, 25)),
            ),
            child: Column(            
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitPulsingGrid(
                  color: kTextColorWhite,
                ),
                const SizedBox(height: 20,),
                Text(text, style: const TextStyle(
                  color: kTextColorWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
          ),
        ),
      );    
  }
}