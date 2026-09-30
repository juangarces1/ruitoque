import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruitoque/constans.dart';

/// App bar de la app: degradado de marca verde → morado, título a la izquierda con
/// subtítulo opcional y botón atrás en un círculo translúcido.
///
/// [backgroundColor], [elevation], [shadowColor] y [foreColor] se mantienen para no
/// romper las pantallas existentes, pero ya no se usan: todas las barras se ven igual.
class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? foreColor;

  const MyCustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.foreColor,
  });

  static const _alto = 60.0;
  static const _altoConSubtitulo = 68.0;

  /// Esquinas inferiores redondeadas. En pantallas con fondo oscuro conviene
  /// `extendBodyBehindAppBar: true` para que el fondo se vea detrás de las esquinas.
  static const _radio = BorderRadius.vertical(bottom: Radius.circular(24));

  static const _degradado = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [kPprimaryColor, kPcontrastMoradoColor],
  );

  double get _altoBarra => subtitle == null ? _alto : _altoConSubtitulo;

  @override
  Widget build(BuildContext context) {
    // Como en AppBar de Flutter: si la pantalla tiene menú lateral, el menú tiene prioridad.
    final tieneMenu = automaticallyImplyLeading && (Scaffold.maybeOf(context)?.hasDrawer ?? false);
    final puedeVolver = !tieneMenu && automaticallyImplyLeading && Navigator.canPop(context);
    final Widget? inicio = tieneMenu
        ? BotonBarra(icono: Icons.menu_rounded, onTap: () => Scaffold.of(context).openDrawer())
        : puedeVolver
            ? BotonBarra(icono: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).maybePop())
            : null;

    return AppBar(
      toolbarHeight: _altoBarra,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shape: const RoundedRectangleBorder(borderRadius: _radio),
      // SizedBox.expand: sin tamaño propio el degradado quedaría de 0 px (barra blanca).
      flexibleSpace: const SizedBox.expand(
        child: DecoratedBox(decoration: BoxDecoration(gradient: _degradado, borderRadius: _radio)),
      ),
      titleSpacing: inicio != null ? 4 : 16,
      leading: inicio,
      leadingWidth: inicio != null ? 60 : null,
      title: _Titulo(title: title, subtitle: subtitle),
      actions: [
        ...?actions,
        const SizedBox(width: 8),
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_altoBarra + (bottom?.preferredSize.height ?? 0));
}

class _Titulo extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _Titulo({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
      ],
    );
  }
}

/// Botón de la barra (atrás, menú, guardar, refrescar…) en un círculo blanco translúcido.
class BotonBarra extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onTap;
  final String? tooltip;

  const BotonBarra({super.key, required this.icono, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final boton = Center(
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icono, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
    return tooltip == null ? boton : Tooltip(message: tooltip!, child: boton);
  }
}

/// La misma barra de marca, pero como widget normal para pantallas que dibujan su
/// encabezado dentro del contenido (p. ej. la ronda en juego) en vez de en `appBar`.
class EncabezadoMarca extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  const EncabezadoMarca({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Material transparente: algunas pantallas (p. ej. la ronda en juego) no tienen
    // Scaffold, y sin un Material encima Flutter subraya el texto en amarillo.
    // Se extiende detrás de la barra de estado (hora, batería) con íconos blancos,
    // como hace MyCustomAppBar dentro de un Scaffold.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        type: MaterialType.transparency,
        child: _contenido(MediaQuery.paddingOf(context).top),
      ),
    );
  }

  Widget _contenido(double barraEstado) {
    return Container(
      height: barraEstado + (subtitle == null ? MyCustomAppBar._alto : MyCustomAppBar._altoConSubtitulo),
      padding: EdgeInsets.only(top: barraEstado, left: leading == null ? 16 : 10, right: 8),
      decoration: const BoxDecoration(
        gradient: MyCustomAppBar._degradado,
        borderRadius: MyCustomAppBar._radio,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(child: _Titulo(title: title, subtitle: subtitle)),
          ...actions,
        ],
      ),
    );
  }
}

/// Logo de la app en un círculo con borde, para las acciones de la barra.
class LogoAppBar extends StatelessWidget {
  const LogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset('assets/LogoGolf.png', width: 32, height: 32, fit: BoxFit.cover),
      ),
    );
  }
}
