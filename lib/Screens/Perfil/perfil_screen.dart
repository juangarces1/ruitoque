import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/avatar_perfil.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Screens/Catalogo/catalogo_screen.dart';
import 'package:ruitoque/Screens/Ronda/mis_rondas_screen.dart';
import 'package:ruitoque/Screens/Tarjetas/my_tarjetas_screen.dart';
import 'package:ruitoque/constans.dart';

/// Lo que es solo mío: mis tarjetas, mis rondas y la sesión.
/// Se abre tocando el avatar de la barra superior.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jugador = context.watch<JugadorProvider>().jugador;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Encabezado(nombre: jugador.nombre, handicap: jugador.handicap ?? 0),
          const SizedBox(height: 20),
          _Grupo(
            children: [
              _Opcion(
                icono: Icons.scoreboard_outlined,
                titulo: 'Mis Tarjetas',
                subtitulo: 'Tus rondas jugadas y estadísticas',
                onTap: () => _abrir(context, MyTarjetasScreen(jugador: jugador)),
              ),
              _Opcion(
                icono: Icons.sports_golf,
                titulo: 'Mis Rondas',
                subtitulo: 'Rondas guardadas para continuar',
                onTap: () => _abrir(context, const MisRondasScreen()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Grupo(
            children: [
              if (kDebugMode)
                _Opcion(
                  icono: Icons.palette_outlined,
                  titulo: 'Catálogo de componentes',
                  subtitulo: 'Solo en modo debug',
                  onTap: () => _abrir(context, const CatalogoScreen()),
                ),
              _Opcion(
                icono: Icons.logout_rounded,
                titulo: 'Cerrar sesión',
                peligro: true,
                onTap: () => _cerrarSesion(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('Tendrás que ingresar tu PIN de nuevo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    // Borra la sesión guardada; main.dart muestra el login al no haber jugador.
    final jugadorProvider = context.read<JugadorProvider>();
    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    await jugadorProvider.borrarJugador();
  }
}

/// Encabezado con el degradado de marca: avatar grande, nombre y hándicap.
class _Encabezado extends StatelessWidget {
  final String nombre;
  final int handicap;

  const _Encabezado({required this.nombre, required this.handicap});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPprimaryColor, kPcontrastMoradoColor],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BotonBarra(
                icono: Icons.arrow_back_rounded,
                tooltip: 'Atrás',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            const AvatarPerfil(diametro: 88, abrePerfil: false),
            const SizedBox(height: 12),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Hándicap $handicap',
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  final List<Widget> children;

  const _Grupo({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 64),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final bool peligro;
  final VoidCallback onTap;

  const _Opcion({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.peligro = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = peligro ? const Color(0xFFC62828) : kPprimaryColor;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icono, color: color, size: 20),
      ),
      title: Text(
        titulo,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: peligro ? color : null),
      ),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      trailing: peligro ? null : const Icon(Icons.chevron_right_rounded),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
