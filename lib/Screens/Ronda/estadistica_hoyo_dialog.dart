import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/constans.dart';

class EstadisticaHoyoDialog extends StatefulWidget {
  final List<EstadisticaHoyo> estadisticasHoyo;
  final Function(List<EstadisticaHoyo>) onGuardar;

  const EstadisticaHoyoDialog({
    Key? key,
    required this.estadisticasHoyo,
    required this.onGuardar,
  }) : super(key: key);

  @override
  State<EstadisticaHoyoDialog> createState() => _EstadisticaHoyoDialogState();
}

class _EstadisticaHoyoDialogState extends State<EstadisticaHoyoDialog> {
  late List<EstadisticaHoyo> estadisticasHoyo;

  // Tokens visuales (dark)
  static const _bgSurface = Color(0xFF0F1115); 
  static const _bgElev2 = Color(0xFF1B202B);
  static const _textPrimary = Color(0xFFE8EAED);
  static const _textSecondary = Color(0xFFAEB4BE);
  static const _borderMuted = Color(0x1AFFFFFF); // 10% white

  TextStyle get _titleHoyo =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: .2);
  TextStyle get _subHoyo =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary, letterSpacing: 1.0);
  TextStyle get _playerName =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary);
  TextStyle get _labelUpper =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary, letterSpacing: 1.0);
  TextStyle get _valueBig =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary);

  @override
  void initState() {
    super.initState();
    estadisticasHoyo = List.from(widget.estadisticasHoyo);
  }

  // ----------- LÓGICA EXISTENTE (no tocada) -----------
  void _incrementarCampo(EstadisticaHoyo estadistica, String campo) {
    setState(() {
      if (campo == 'golpes') {
        estadistica.golpes++;
      } else if (campo == 'putts') {
        estadistica.putts++;
      } else if (campo == 'bunkerShots') {
        estadistica.bunkerShots++;
      } else if (campo == 'penaltyShots') {
        estadistica.penaltyShots++;
      }
    });
  }

  void _decrementarCampo(EstadisticaHoyo estadistica, String campo) {
    setState(() {
      if (campo == 'golpes' && estadistica.golpes > 0) {
        estadistica.golpes--;
      } else if (campo == 'putts' && estadistica.putts > 0) {
        estadistica.putts--;
      } else if (campo == 'bunkerShots' && estadistica.bunkerShots > 0) {
        estadistica.bunkerShots--;
      } else if (campo == 'penaltyShots' && estadistica.penaltyShots > 0) {
        estadistica.penaltyShots--;
      }
    });
  }

  void _cambiarEstadoFairway(String direccion, EstadisticaHoyo e) {
    setState(() {
      e.acertoFairway = direccion == 'centro';
      e.falloFairwayIzquierda = direccion == 'izquierda';
      e.falloFairwayDerecha = direccion == 'derecha';
    });
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hoyo = widget.estadisticasHoyo.first.hoyo;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: _bgSurface,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header sticky
                _HeaderDark(
                  title: 'Hoyo ${hoyo.numero}',
                  subtitle: 'Par ${hoyo.par}',
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Divider(height: 1, color: _borderMuted),
                // Contenido scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: estadisticasHoyo.map((e) {
                        // defaults visuales (no cambian tu lógica)
                        if (e.golpes == 0) e.golpes = e.hoyo.par;
                        if (e.isMain == true && e.putts == 0) e.putts = 2;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlayerCard(
                            name: e.nombreJugador ?? 'Jugador',
                            par: e.hoyo.par,
                            isMain: e.isMain ?? false,
                            fairway: e.hoyo.par != 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Fairway (par != 3) solo si principal
                                if (e.hoyo.par != 3 && (e.isMain ?? false)) ...[
                                  Text('FAIRWAY', style: _labelUpper),
                                  const SizedBox(height: 8),
                                  _FairwaySegmented(
                                    leftActive: e.falloFairwayIzquierda,
                                    centerActive: e.acertoFairway,
                                    rightActive: e.falloFairwayDerecha,
                                    onLeft: () => _cambiarEstadoFairway('izquierda', e),
                                    onCenter: () => _cambiarEstadoFairway('centro', e),
                                    onRight: () => _cambiarEstadoFairway('derecha', e),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Grid de contadores
                                LayoutBuilder(
                                  builder: (ctx, c) {
                                    final isNarrow = c.maxWidth < 360;
                                    final grid = SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isNarrow ? 1 : 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                        mainAxisExtent: 140, 
                                    );
                                    return GridView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: grid,
                                      children: [
                                        _CounterCard(
                                          label: 'GOLPES',
                                          value: e.golpes,
                                          onAdd: () => _incrementarCampo(e, 'golpes'),
                                          onRemove: () => _decrementarCampo(e, 'golpes'),
                                          valueStyle: _valueBig,
                                        ),
                                        if (e.isMain == true)
                                          _CounterCard(
                                            label: 'PUTTS',
                                            value: e.putts,
                                            onAdd: () => _incrementarCampo(e, 'putts'),
                                            onRemove: () => _decrementarCampo(e, 'putts'),
                                            valueStyle: _valueBig,
                                          ),
                                        if (e.isMain == true)
                                          _CounterCard(
                                            label: 'BUNKER',
                                            value: e.bunkerShots,
                                            onAdd: () => _incrementarCampo(e, 'bunkerShots'),
                                            onRemove: () => _decrementarCampo(e, 'bunkerShots'),
                                            valueStyle: _valueBig,
                                          ),
                                        if (e.isMain == true)
                                          _CounterCard(
                                            label: 'CASTIGO',
                                            value: e.penaltyShots,
                                            onAdd: () => _incrementarCampo(e, 'penaltyShots'),
                                            onRemove: () => _decrementarCampo(e, 'penaltyShots'),
                                            valueStyle: _valueBig,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Barra inferior sticky
                const Divider(height: 1, color: _borderMuted),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    children: [
                      // Resumen mini: usa info del primer jugador principal si quieres; aquí solo decorativo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _bgElev2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderMuted),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag_circle, size: 18, color: _textSecondary),
                            SizedBox(width: 8),
                            Text('Resumen del hoyo', style: TextStyle(color: _textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPsecondaryColor,
                          foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          widget.onGuardar(estadisticasHoyo);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header oscuro, pegajoso, con título/subtítulo
class _HeaderDark extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  const _HeaderDark({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onClose,
  }) : super(key: key);

  static const _bgElev2 = Color(0xFF1B202B);
  static const _textPrimary = Color(0xFFE8EAED);
  static const _textSecondary = Color(0xFFAEB4BE);
  static const _borderMuted = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgElev2,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          const Icon(Icons.golf_course, color: _textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary, letterSpacing: 1.0)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            style: IconButton.styleFrom(
              backgroundColor: _bgElev2,
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.close, color: _textSecondary),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

/// Card por jugador, con avatar + nombre y cuerpo
class _PlayerCard extends StatelessWidget {
  final String name;
  final int par;
  final bool isMain;
  final bool fairway;
  final Widget child;

  const _PlayerCard({
    Key? key,
    required this.name,
    required this.par,
    required this.isMain,
    required this.fairway,
    required this.child,
  }) : super(key: key);

  static const _bgElev1 = Color(0xFF151922);
  static const _textPrimary = Color(0xFFE8EAED);
  static const _textSecondary = Color(0xFFAEB4BE);
  static const _borderMuted = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    String initials() {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
      return (parts[0].isNotEmpty ? parts[0][0] : '') +
          (parts[1].isNotEmpty ? parts[1][0] : '');
    }

    return Container(
      decoration: BoxDecoration(
        color: _bgElev1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderMuted),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header de jugador
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kPprimaryColor.withOpacity(.15),
                child: Text(
                  initials(),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: _textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _borderMuted),
                ),
                child: Text('Par $par', style: const TextStyle(fontSize: 12, color: _textSecondary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Fairway estilo segmented (Izq / Centro / Der)
class _FairwaySegmented extends StatelessWidget {
  final bool leftActive;
  final bool centerActive;
  final bool rightActive;
  final VoidCallback onLeft;
  final VoidCallback onCenter;
  final VoidCallback onRight;

  const _FairwaySegmented({
    Key? key,
    required this.leftActive,
    required this.centerActive,
    required this.rightActive,
    required this.onLeft,
    required this.onCenter,
    required this.onRight,
  }) : super(key: key);

  static const _track = Color(0xFF1B202B);
  static const _textPrimary = Color(0xFFE8EAED);
  static const _textSecondary = Color(0xFFAEB4BE);
  static const _borderMuted = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    Widget seg({
      required bool active,
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      BorderRadius? radius,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active ? kPprimaryColor.withOpacity(.14) : _track,
              borderRadius: radius,
              border: Border.all(color: active ? kPprimaryColor.withOpacity(.6) : _borderMuted),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: active ? _textPrimary : _textSecondary),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? _textPrimary : _textSecondary,
                      letterSpacing: 1.0,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _track,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderMuted),
      ),
      child: Row(
        children: [
          seg(
            active: leftActive,
            icon: Icons.arrow_back,
            label: 'IZQ',
            onTap: onLeft,
            radius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          ),
          seg(
            active: centerActive,
            icon: Icons.radio_button_checked,
            label: 'CEN',
            onTap: onCenter,
          ),
          seg(
            active: rightActive,
            icon: Icons.arrow_forward,
            label: 'DER',
            onTap: onRight,
            radius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}

/// Counter card: etiqueta + valor grande + stepper redondeado
class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final TextStyle valueStyle;

  const _CounterCard({
    Key? key,
    required this.label,
    required this.value,
    required this.onAdd,
    required this.onRemove,
    required this.valueStyle,
  }) : super(key: key);

  static const _bgElev2 = Color(0xFF1B202B);
  static const _textSecondary = Color(0xFFAEB4BE);
  static const _borderMuted = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    Widget stepBtn(IconData icon, VoidCallback onPressed, {bool filled = false}) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: filled ? kPprimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: filled ? Colors.transparent : _borderMuted),
          ),
          child: Icon(icon, size: 20, color: filled ? Colors.white : _textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _bgElev2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderMuted),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textSecondary, letterSpacing: 1.0)),
          const Spacer(),
          Center(child: Text('$value', style: valueStyle)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _borderMuted),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                stepBtn(Icons.remove, onRemove),
                const SizedBox(width: 6),
                Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                stepBtn(Icons.add, onAdd, filled: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
