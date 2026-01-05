import 'package:flutter/material.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Screens/Campos/add_course_screen.dart';
import 'package:ruitoque/Screens/Campos/sekect_edit_campo.dart';
import 'package:ruitoque/Screens/Jugadores/juagadores_screen.dart';
import 'package:ruitoque/Screens/LogIn/login_screen.dart';
import 'package:ruitoque/Screens/Ronda/mis_rondas_screen.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/mis_rondas_amigos_screen.dart';
import 'package:ruitoque/Screens/Tarjetas/my_tarjetas_screen.dart';
import 'package:ruitoque/constans.dart';

class GolfDrawer extends StatelessWidget {
  final Jugador jugador;
  const GolfDrawer({super.key, required this.jugador});

  @override
  Widget build(BuildContext context) {
   
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: kGradiantBandera),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/LogoGolf.png', width: 60, height: 60),
              ),
              const SizedBox(height: 10),
              Text(jugador.nombre, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _drawerItem(Icons.scoreboard, 'Mis Tarjetas', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MyTarjetasScreen(jugador: jugador)));
                    }),
                    _drawerItem(Icons.sports_golf, 'Mis Rondas', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MisRondasScreen()));
                    }),
                    _drawerItem(Icons.groups, 'Ronda de Amigos', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MisRondasDeAmigosScreen()));
                    }),

                     _drawerItem(Icons.person, 'Jugadores', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JugadoresScreen()));
                    }, textColor: Colors.black),

                    _drawerItem(Icons.flag_circle_outlined, 'Agregar Campo', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen()));
                    }),
                    _drawerItem(Icons.edit, 'Editar Campo', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectEditCampo()));
                    }),
                    _drawerItem(Icons.logout, 'Cerrar Sesión', () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }, textColor: Colors.black),

                   
                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color textColor = const Color(0xffadb5bd)}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      onTap: onTap,
      textColor: textColor,
    );
  }
}