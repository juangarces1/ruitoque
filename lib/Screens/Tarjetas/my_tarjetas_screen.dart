import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/loader_component.dart';
import 'package:ruitoque/Components/tarjetas_player_card.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MyTarjetasScreen extends StatefulWidget {

  final Jugador jugador;
  // ignore: use_key_in_widget_constructors
  const MyTarjetasScreen({ required this.jugador});

  @override
  State<MyTarjetasScreen> createState() => _MyTarjetasScreenState();
}

class _MyTarjetasScreenState extends State<MyTarjetasScreen> {
  List<Tarjeta> tarjetas = [];
   bool showLoader = false;
    late double total=0;

  
  @override

  void initState() {
    super.initState();
    _getTarjetas();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          title: 'Mis Tarjetas',
          elevation: 6,
          shadowColor: Colors.white,
          automaticallyImplyLeading: true,
          foreColor: Colors.white,
          backgroundColor: kPrimaryColor,
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
            
            itemCount: tarjetas.length,
            itemBuilder: (context, index)  
            { 
              final item = tarjetas[index];
              return TarjetaPlayer(tarjeta: item, jugador: widget.jugador,);
            }        
          ),
          ),
        ),
    
        
      ),
    );
  }

  Future<void> _getTarjetas() async {
    setState(() {
      showLoader = true;
    });

    
    Response response = await ApiHelper.getTarjetasById(widget.jugador.id.toString());

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

   Jugador aux = response.result;
    if(aux.tarjetas != null){
      setState(() {
       tarjetas = aux.tarjetas!;
     });
    }

  
  }

 
}