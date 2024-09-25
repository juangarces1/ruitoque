import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/card_jugador.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Screens/Campos/add_course_screen.dart';
import 'package:ruitoque/Screens/Campos/sekect_campo_scree.dart';
import 'package:ruitoque/Screens/Home/Components/menu_item.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';
import 'package:ruitoque/Screens/Ronda/intro_ronda_screen.dart';
import 'package:ruitoque/Screens/Tarjetas/my_tarjetas_screen.dart';
import 'package:ruitoque/constans.dart';
import 'package:ruitoque/sizeconfig.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, });
 

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showLoader =false;
  double? value = 0;
  Campo campo = Campo(id: 0, nombre: '', ubicacion: '', hoyos: [], tees: []);
  late Jugador jugador;

  @override
  void initState() {   
    super.initState();
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);  

    double posJugar =  SizeConfig.screenWidth / 2 - 40;
    return SafeArea(
      child: Scaffold(     
               
        body:  Stack(
          children: [
            
          Container(
            decoration: const BoxDecoration(
              gradient: kGradiantBandera
            ),
          ),
          SafeArea(
    
            child: Container(
            width: 250,
            
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              
             const SizedBox(
               height: 10,),
               Container(
                padding: const EdgeInsets.all(10),
                width: 50,  // Ancho del cuadrado
                height: 50, // Altura del cuadrado
                decoration: BoxDecoration(
                    // Para esquinas redondeadas, usa BorderRadius
                    borderRadius: BorderRadius.circular(10), // Puedes ajustar el radio
                    image: const DecorationImage(
                        image: AssetImage('assets/LogoGolf.png'),
                        fit: BoxFit.cover, // Cubre el área del contenedor
                    ),
                ),
            ) ,
                const SizedBox(height: 10,),
                Text(jugador.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
    
                Expanded(             
                
               child:   principalMenu(context, jugador), 
                
                ),
            ]),
          ),
          ),
    
          TweenAnimationBuilder(
            tween: Tween<double>(begin:0, end: value),
            duration: const Duration(milliseconds: 500),
             builder: (_,double val,__){
              return(Transform(transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..setEntry(0, 3, 200*val)
              ..rotateY((pi/6)*val),
              alignment: Alignment.center,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: kColorFondoOscuro,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child:MyCustomAppBar(
                        title: 'Golf Colombia',
                          automaticallyImplyLeading: true,   
                          backgroundColor:  const Color.fromARGB(255, 0, 71, 44),
                          elevation: 8.0,
                          shadowColor: const Color.fromARGB(255, 127, 140, 10),
                          foreColor: Colors.white,
                          actions: [ 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                    'assets/LogoGolf.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ), // Ícono de perfil de usuario
                              ),
                          ],
                        
                        ),
              
                  ),
                  body: Container(
                    decoration: const BoxDecoration(
                       image: DecorationImage(
                        image: AssetImage('assets/fondoHome.webp'),
                        fit: BoxFit.fill, // Ajusta la imagen para que cubra el área de 4:3
                      ),),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10 , right: 10, left: 10),
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            CardJugador(jugador: jugador,),
                          ],
                        )),

                         Positioned(
                            bottom: 3, // Ubicar al fondo
                            left: posJugar, // Inicia en el borde izquierdo
                            // Extiende hasta el borde derecho
                            child: GestureDetector(
                              onTap:  gointroRonda,
                              child: ClipOval(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.symmetric(vertical: 22), // Ajuste del padding para que el texto quede dentro del círculo
                                  color:kPcontrastMoradoColor,
                                  child: const Text(
                                    'Jugar', 
                                    style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center, // Centrar el texto dentro del círculo
                                  ),
                                ),
                              ),
                            ),
                          ),
                        showLoader ? const Center(child: MyLoader(text: 'Cargando...',opacity: 0.7,),) : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
              ));
             }
             
             ),
             
          GestureDetector(
            onHorizontalDragUpdate: (details){
              if(details.delta.dx>0){
                setState(() {
                  value = 1;
                });
              }
              else{
                setState(() {
                  value = 0;
                });
              }
            },
          ),     
         ],
        ),
       
      
     
      ),
    );
    
  }

 Widget principalMenu(BuildContext context, Jugador jugador) {
  const TextStyle myStyle = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // Definir los ítems del menú
  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Iniciar Ronda',
      leading: const CircleAvatar(
        radius: 12,
        backgroundImage: AssetImage('assets/marker.png'),
        backgroundColor: kPprimaryColor,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroRondaScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Mis Tarjetas',
      leading: const Icon(
        Icons.scoreboard_sharp,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyTarjetasScreen(jugador: jugador),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Agregar Campo',
      leading: const Icon(
        Icons.flag_circle_outlined,
        color: Colors.white
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCourseScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Editar Campo',
      leading: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectCampoScreen(),
          ),
        );
      },
      textColor: const Color(0xffadb5bd),
    ),
    MenuItem(
      title: 'Cerrar Sesión',
      leading: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      textColor: Colors.black, // Diferente color para este ítem
    ),
  ];

  return ListView.builder(
    itemCount: menuItems.length,
    itemExtent: 60, // Ajusta el tamaño según tus necesidades
    itemBuilder: (context, index) {
      final item = menuItems[index];
      return ListTile(
        textColor: item.textColor,
        leading: item.leading,
        title: Text(
          item.title,
          style: myStyle,
        ),
        onTap: item.onTap,
      );
    },
  );
}
  
  
  gointroRonda() {
     Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) =>  const IntroRondaScreen()
        ),
      );

  }


 
}