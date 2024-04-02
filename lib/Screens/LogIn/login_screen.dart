import 'package:flutter/material.dart';
import 'package:ruitoque/Screens/Temporales/my_home_pag.dart';
import 'package:ruitoque/sizeconfig.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  SafeArea(      
        child: Material(
          child: Container(
            color: const Color.fromARGB(255, 225, 225, 225),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                   const SizedBox(height: 10.0),
                Image.asset(
                    'assets/logoApp.jpg',
                    width: 100.0, // ajusta el ancho según tus necesidades
                    height: 100.0, // ajusta la altura según tus necesidades
                  ),// Logo de tu app
            
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: TextFormField(
                      
                      keyboardType: TextInputType.number,
                      obscureText: true, // para ocultar el PIN mientras se escribe
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ingresa tu PIN',
                        
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        goHome(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 18.0),
                      ),
                      child: const Text('Ingresar', style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  goHome(BuildContext context){
     Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) =>  const MyHomePage(title: 'Ruitoque' )
                    )
                  ).then((value) {
                    //   _orderTransactions();
                   });
  }
}