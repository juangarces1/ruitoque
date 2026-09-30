import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ruitoque/constans.dart';

/// Jerarquía de botones de la app.
enum VarianteBoton {
  /// Acción principal de la pantalla: cápsula verde sólida (el degradado queda
  /// reservado para la barra, para que no se vea todo igual).
  principal,

  /// Acción secundaria sobre fondo claro: verde suave, sin borde.
  tonal,

  /// Acción secundaria sobre fondos oscuros, fotos o el mapa: translúcido con desenfoque.
  cristal,

  /// Acción menor (Cancelar, Ver más): solo texto.
  texto,

  /// Acción destructiva (Eliminar): rojo suave.
  peligro,
}

/// Botón de la app. Cápsula que se hunde y cuadra sus esquinas al presionarla,
/// con vibración. Si [onPressed] devuelve un Future, muestra carga mientras dura
/// y un ✓ al terminar bien; mientras carga ignora toques repetidos.
class BotonApp extends StatefulWidget {
  final String texto;
  final FutureOr<void> Function()? onPressed;
  final VarianteBoton variante;
  final IconData? icono;

  /// Ocupa todo el ancho disponible (p. ej. la acción fija de abajo).
  final bool expandido;

  /// 44 de alto en vez de 56, para filas de botones o diálogos.
  final bool compacto;

  const BotonApp({
    super.key,
    required this.texto,
    required this.onPressed,
    this.variante = VarianteBoton.principal,
    this.icono,
    this.expandido = false,
    this.compacto = false,
  });

  @override
  State<BotonApp> createState() => _BotonAppState();
}

enum _Estado { normal, cargando, listo }

class _BotonAppState extends State<BotonApp> {
  static const _rojo = Color(0xFFC62828);
  static const _duracionListo = Duration(milliseconds: 900);

  bool _presionado = false;

  /// Brillo del relieve; [intensidad] 1 en reposo, menos al presionar.
  static LinearGradient _brillo(double intensidad) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.30 * intensidad),
          Colors.white.withValues(alpha: 0.12 * intensidad),
          Colors.white.withValues(alpha: 0.04 * intensidad),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.08, 0.45, 0.6],
      );
  _Estado _estado = _Estado.normal;

  bool get _habilitado => widget.onPressed != null;
  double get _alto => widget.compacto ? 44 : 56;

  Future<void> _alTocar() async {
    if (!_habilitado || _estado != _Estado.normal) return;
    widget.variante == VarianteBoton.principal || widget.variante == VarianteBoton.peligro
        ? HapticFeedback.lightImpact()
        : HapticFeedback.selectionClick();

    final resultado = widget.onPressed!();
    if (resultado is! Future) return;

    setState(() => _estado = _Estado.cargando);
    try {
      await resultado;
    } catch (e) {
      // Quien llama muestra el error; el botón solo vuelve a su estado normal.
      debugPrint('BotonApp "${widget.texto}": $e');
      if (mounted) setState(() => _estado = _Estado.normal);
      return;
    }
    if (!mounted) return;
    setState(() => _estado = _Estado.listo);
    await Future.delayed(_duracionListo);
    if (mounted) setState(() => _estado = _Estado.normal);
  }

  void _presionar(bool valor) {
    if (!_habilitado || _estado != _Estado.normal) return;
    setState(() => _presionado = valor);
  }

  ({Color? fondo, Color texto, BorderSide? borde, bool desenfoque}) get _estilo {
    final esquema = Theme.of(context).colorScheme;
    if (!_habilitado) {
      return (
        fondo: esquema.onSurface.withValues(alpha: 0.10),
        texto: esquema.onSurface.withValues(alpha: 0.38),
        borde: null,
        desenfoque: false,
      );
    }
    switch (widget.variante) {
      case VarianteBoton.principal:
        return (fondo: kPprimaryColor, texto: Colors.white, borde: null, desenfoque: false);
      case VarianteBoton.tonal:
        return (
          fondo: kPprimaryColor.withValues(alpha: 0.12),
          texto: kPprimaryColor,
          borde: null,
          desenfoque: false,
        );
      case VarianteBoton.cristal:
        return (
          fondo: Colors.white.withValues(alpha: 0.16),
          texto: Colors.white,
          borde: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          desenfoque: true,
        );
      case VarianteBoton.texto:
        return (fondo: Colors.transparent, texto: kPprimaryColor, borde: null, desenfoque: false);
      case VarianteBoton.peligro:
        return (
          fondo: _rojo.withValues(alpha: 0.10),
          texto: _rojo,
          borde: null,
          desenfoque: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _estilo;
    // Cápsula en reposo; al presionar las esquinas se cuadran un poco (shape morph).
    final radio = BorderRadius.circular(_presionado ? _alto * 0.3 : _alto / 2);

    Widget contenido = Stack(
      alignment: Alignment.center,
      children: [
        // El texto se mantiene (invisible) para que el ancho no salte al cargar.
        AnimatedOpacity(
          opacity: _estado == _Estado.normal ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child:
              _Etiqueta(texto: widget.texto, icono: widget.icono, color: e.texto, compacto: widget.compacto),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (hijo, anim) => ScaleTransition(scale: anim, child: hijo),
          child: switch (_estado) {
            _Estado.cargando => SizedBox(
                key: const ValueKey('cargando'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: e.texto),
              ),
            _Estado.listo =>
              Icon(Icons.check_rounded, key: const ValueKey('listo'), color: e.texto, size: 26),
            _Estado.normal => const SizedBox.shrink(key: ValueKey('normal')),
          },
        ),
      ],
    );

    final conRelieve = widget.variante == VarianteBoton.principal && _habilitado;

    Widget boton = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      height: _alto,
      width: widget.expandido ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: widget.variante == VarianteBoton.texto ? 16 : 24),
      decoration: BoxDecoration(
        color: e.fondo,
        borderRadius: radio,
        border: e.borde == null ? null : Border.fromBorderSide(e.borde!),
        boxShadow: widget.variante == VarianteBoton.principal && _habilitado && !_presionado
            ? [
                BoxShadow(
                    color: kPprimaryColor.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))
              ]
            : null,
      ),
      // Relieve: filo de luz arriba y brillo que se desvanece hacia la mitad; al
      // presionar se apaga, reforzando la sensación de hundirse.
      foregroundDecoration: conRelieve
          ? BoxDecoration(borderRadius: radio, gradient: _brillo(_presionado ? 0.35 : 1))
          : null,
      alignment: Alignment.center,
      child: contenido,
    );

    if (e.desenfoque) {
      boton = ClipRRect(
        borderRadius: radio,
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: boton),
      );
    }

    return Semantics(
      key: const Key('boton_app_semantica'),
      button: true,
      enabled: _habilitado,
      label: widget.texto,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _presionar(true),
        onTapUp: (_) => _presionar(false),
        onTapCancel: () => _presionar(false),
        onTap: _alTocar,
        child: AnimatedScale(
          scale: _presionado ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: boton,
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final Color color;
  final bool compacto;

  const _Etiqueta({required this.texto, required this.icono, required this.color, required this.compacto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icono != null) ...[
          Icon(icono, color: color, size: compacto ? 18 : 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: compacto ? 15 : 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Acción principal fija abajo, en la zona del pulgar, en vez de un botón flotante.
/// Úsala como `bottomNavigationBar` del Scaffold.
class BarraAccionInferior extends StatelessWidget {
  final Widget child;

  const BarraAccionInferior({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: child,
      ),
    );
  }
}
