import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Screens/Perfil/perfil_screen.dart';
import 'package:ruitoque/constans.dart';

/// Inicial del jugador en un círculo; en la barra superior abre el perfil.
/// El mismo widget, más grande, es el encabezado del perfil (transición Hero).
class AvatarPerfil extends StatelessWidget {
  final double diametro;

  /// Si es false solo se dibuja (p. ej. dentro del propio perfil).
  final bool abrePerfil;

  const AvatarPerfil({super.key, this.diametro = 36, this.abrePerfil = true});

  static const heroTag = 'avatar_perfil';

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<JugadorProvider, String>((p) => p.jugador.nombre);
    final inicial = nombre.isEmpty ? '?' : nombre.characters.first.toUpperCase();

    final avatar = Hero(
      tag: heroTag,
      child: Container(
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kPcontrastMoradoColor,
          border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: diametro > 50 ? 3 : 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          inicial,
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: diametro * 0.45,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );

    if (!abrePerfil) return avatar;
    return Semantics(
      button: true,
      label: 'Mi perfil',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => const PerfilScreen(),
            transitionsBuilder: (_, animacion, __, hijo) => FadeTransition(opacity: animacion, child: hijo),
          ));
        },
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: avatar),
      ),
    );
  }
}
