import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_ronda.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MisRondasScreen extends StatefulWidget {

 
  // ignore: use_key_in_widget_constructors
  const MisRondasScreen();

  @override
  State<MisRondasScreen> createState() => _MisRondasScreenState();
}

class _MisRondasScreenState extends State<MisRondasScreen> {
  List<Ronda> rondas = [];
   bool showLoader = false;
   late double total=0;
  
   late Jugador jugador;

  
  @override

  void initState() {
    super.initState();
     jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;   
    _getRondas();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          title: 'Mis Rondas',
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
        body: showLoader ? const LoaderComponent(loadingText: 'Cargando...',) : Container(
          decoration: const BoxDecoration(
            gradient: kPrimaryGradientColor,
          ),
          child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(3), vertical: getProportionateScreenHeight(5)),
          child: ListView.builder(
            
            itemCount: rondas.length,
            itemBuilder: (context, index)  
            { 
              final item = rondas[index];
              return CardRonda(ronda: item,);
            }        
          ),
          ),
        ),
    
        
      ),
    );
  }

  Future<void> _getRondas() async {
    setState(() {
      showLoader = true;
    });

    
    Response response = await ApiHelper.getRondasTerminadas(jugador.id);

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
       rondas = response.result;
       for (var i = 0; i < rondas.length; i++) {
        rondas[i].calcularYAsignarPosiciones();
       }
     });
    

  
  }

 
}