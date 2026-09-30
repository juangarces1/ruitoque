import 'package:flutter/material.dart';
import 'package:ruitoque/Components/navegacion.dart';
import 'package:ruitoque/Screens/Campos/sekect_edit_campo.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/Screens/Jugadores/juagadores_screen.dart';
import 'package:ruitoque/Screens/Ronda/select_screen.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/mis_rondas_amigos_screen.dart';

/// Estructura principal de la app: 4 secciones en una barra inferior con muesca y
/// "Jugar" en el centro. Lo personal (tarjetas, rondas, sesión) está en el perfil,
/// que se abre desde el avatar de la barra superior.
class ShellScreen extends StatefulWidget {
  /// Pantallas de cada sección, en el orden de [destinos]. Configurable para tests.
  final List<Widget> pestanas;
  final VoidCallback? onJugar;

  const ShellScreen({
    super.key,
    this.pestanas = const [
      MyHomePage(),
      MisRondasDeAmigosScreen(),
      JugadoresScreen(),
      SelectEditCampo(),
    ],
    this.onJugar,
  });

  static const destinos = [
    DestinoNavegacion(icono: Icons.home_outlined, iconoActivo: Icons.home_rounded, etiqueta: 'Inicio'),
    DestinoNavegacion(icono: Icons.groups_outlined, iconoActivo: Icons.groups_rounded, etiqueta: 'Amigos'),
    DestinoNavegacion(icono: Icons.person_search_outlined, iconoActivo: Icons.person_search_rounded, etiqueta: 'Jugadores'),
    DestinoNavegacion(icono: Icons.flag_outlined, iconoActivo: Icons.flag_rounded, etiqueta: 'Campos'),
  ];

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _indice = 0;

  /// Cada sección se construye la primera vez que se abre (así no se cargan
  /// todos los datos al entrar) y después conserva su estado.
  final Set<int> _visitadas = {0};

  void _cambiar(int i) => setState(() {
        _indice = i;
        _visitadas.add(i);
      });

  void _jugar() {
    if (widget.onJugar != null) return widget.onJugar!();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelectCampoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Atrás del sistema en otra sección vuelve a Inicio antes de salir de la app.
      canPop: _indice == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cambiar(0);
      },
      child: Scaffold(
        // Es lo que se ve por la muesca alrededor de "Jugar".
        backgroundColor: ColoresNavegacion.fondo,
        body: IndexedStack(
          index: _indice,
          children: [
            for (var i = 0; i < widget.pestanas.length; i++)
              // Solo la sección visible participa en la animación del avatar al perfil.
              HeroMode(
                enabled: i == _indice,
                child: _visitadas.contains(i) ? widget.pestanas[i] : const SizedBox.shrink(),
              ),
          ],
        ),
        floatingActionButton: BotonJugar(onPressed: _jugar),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BarraNavegacion(
          destinos: ShellScreen.destinos,
          indice: _indice,
          onCambiar: _cambiar,
        ),
      ),
    );
  }
}
