import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_campo.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/Screens/golf_watch_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ruitoque/Screens/mi_mapa.dart';
import 'package:ruitoque/constans.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showLoader =false;
  Campo campo = Campo(id: 0, nombre: '', ubicacion: '', hoyos: []);

   @override
  void initState() {
    super.initState();
   //  _getCampo();
      _getCampoJson();
   
  }

   Future<void> _getCampo() async {
    setState(() {
      showLoader = true;
    });
    
   Response response = await ApiHelper.getCampo('1');

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
        if (mounted) {       
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content:  Text(response.message),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }  
       return;
     }
     

    setState(() {
      campo=response.result;
      
    });
  }

  @override
  Widget build(BuildContext context) {
 
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyCustomAppBar(
           
          title: 'Ruitoque Golf',
          automaticallyImplyLeading: true,   
          backgroundColor:kPrimaryColor,
          elevation: 8.0,
          shadowColor:kSecondaryColor,
          foreColor: Colors.white,
          actions: [ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                    'assets/logoApp.jpg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ), // Ícono de perfil de usuario
              ),
          ],
                 ),
        body:  SafeArea(
          child: Stack(
            children: [
              Center(
              
                child: Column(
                  
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                        const SizedBox(height: 20,),
                  
                    campo.nombre != '' ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CardCampo(campo: campo, onPressed: () => iniciarRonda(), ),
                    ) : const Text('No hay Campo'),
                       const SizedBox(height: 5,),
              
                  
                  
                  ],
                ),
              ),
              showLoader ? const LoaderComponent(loadingText: "Cargando",) : Container()
            ],
          ),
        ),
      
      ),
    );
  }

    iniciarRonda() {

      Jugador jugador = Jugador(id: 1, handicap: 24, nombre: 'JuanK Garces', pin: 2524, tarjetas: []);

      Tarjeta tarjeta = Tarjeta(id: 0, jugadorId: 1, rondaId: 1, jugador: jugador,  hoyos: [], campo: campo);

      Ronda ronda = Ronda(id: 1, fecha: DateTime.now(), tarjetas: [], campo: campo, isComplete: false);

      for (Hoyo hoyo in campo.hoyos) {
          EstadisticaHoyo aux = EstadisticaHoyo(
            id: hoyo.numero,
             hoyo: hoyo,
             hoyoId: hoyo.id, 
             golpes: 0, 
             putts: 0, 
             bunkerShots: 0, 
             acertoFairway: false, 
             falloFairwayIzquierda: false, 
             falloFairwayDerecha: false, 
             penaltyShots: 0
          );
          tarjeta.hoyos.add(aux);
      }  

      ronda.tarjetas.add(tarjeta);

      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) =>  MiRonda(ronda: ronda,)
        )
      ).then((value) {
        //   _orderTransactions();
        });
  }

  goHole(Hoyo hoyo) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) =>  GolfWatchScreen(hoyo: hoyo,)
      )
    ).then((value) {
      //   _orderTransactions();
      });
  }

  


Widget  buildCardHoyo (Hoyo hoyo) {
 return InkWell(
    onTap: () => goHole(hoyo),
   child: Card(
  
    color: const Color.fromARGB(255, 46, 46, 46),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    elevation: 10,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
         Center(
           child: Text(' ${hoyo.nombre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
           textAlign: TextAlign.center,
           ),
         ), 
       
   
             ListTile(
              title: const Text('Par', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
              subtitle: Text(
              hoyo.par.toString(),
                         style: const TextStyle(color: Colors.white, fontSize: 16, ),
              ),
              trailing: const Icon(Icons.flag_circle, color: Colors.white,),
             
                         ),
             
      
        ],
      ),
    ),
   ),
 );
}

Widget gridHoyos() {
 
      return Container(
         color: Colors.white,
        child: Padding(
           padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Dos columnas
              crossAxisSpacing: 10, // Espacio horizontal entre tarjetas
              mainAxisSpacing: 10, // Espacio vertical entre tarjetas
            ),
            itemCount: campo.hoyos.length,
            itemBuilder: (context, index) {
              return buildCardHoyo(campo.hoyos[index]);
            },
          ),
        ),
      );

}

 Future<void> _getCampoJson() async {

     String jsonString = await rootBundle.loadString('assets/ruitoque.json');
  
  // Decodificar el JSON
    final jsonResponse = json.decode(jsonString);

  // Crear una instancia de MiModelo
  setState(() {
      campo= Campo.fromJson(jsonResponse);
  });
  
  }
  


 
}