import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Estadisticas/golf_score_screen.dart';
import 'package:ruitoque/constans.dart';

// Paleta oscura centralizada
const Color _cardBg      = Color(0xFF1A1A1D); // gris-casi-negro
const Color _headerBg    = Color(0xFF222228);
const Color _accentBlue  = Color(0xFF0EA5E9); // azul cian
const Color _rowEven     = Color(0xFF2D2D32);
const Color _rowOdd      = Color(0xFF26262B);
const Color _greenDark   = Color(0xFF146C43);

class NewTarjetaCardDark extends StatefulWidget {
  final Tarjeta tarjeta;
  final Future<void> Function() onSave;
  final Future<void> Function() onBack;
  final VoidCallback? onEnterScores;

  const NewTarjetaCardDark({
    super.key,
    required this.tarjeta,
    required this.onSave,
    required this.onBack,
    this.onEnterScores,
  });

  @override
  State<NewTarjetaCardDark> createState() => _NewTarjetaCardDarkState();
}

class _NewTarjetaCardDarkState extends State<NewTarjetaCardDark> {
  late int mitad;

  @override
  void initState() {
    super.initState();
    mitad = (widget.tarjeta.hoyos.length / 2).floor();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle whiteBold =
        Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoints sencillos: limita ancho máximo para desktop/tablet
        final double maxContentWidth = constraints.maxWidth >= 1100
            ? 1000
            : (constraints.maxWidth >= 800 ? 760 : constraints.maxWidth);

        final bool isWide = maxContentWidth >= 760;

        // Escala tipográfica: 0.90x - 1.20x
        final double tScale = (maxContentWidth / 760).clamp(0.90, 1.20);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Card(
              color: _cardBg,
              margin: EdgeInsets.symmetric(
                horizontal: isWide ? 16 : 12,
                vertical: 6,
              ),
              elevation: 3,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  collapsedBackgroundColor: _headerBg,
                  backgroundColor: _headerBg,
                  collapsedIconColor: _accentBlue,
                  iconColor: _accentBlue,
                  title: _crearHeader(
                    whiteBold.copyWith(fontSize: (whiteBold.fontSize ?? 16) * tScale),
                    tScale,
                  ),
                  children: <Widget>[
                    Divider(color: Colors.grey.shade700, height: 0),
                    // Fallback: si el ancho es muy estrecho, usa scroll horizontal
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: maxContentWidth,
                        ),
                        child: _crearCuerpoEstadisticas(
                          whiteBold.copyWith(fontSize: 14 * tScale),
                          maxContentWidth,
                          tScale,
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey.shade700, height: 0),
                    _crearFooter(whiteBold.copyWith(fontSize: 14 * tScale)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- HEADER ----------------
  Widget _crearHeader(TextStyle whiteBold, double tScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Izquierda: posición + botón score
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.tarjeta.posicion.toString(),
                style: whiteBold.copyWith(fontSize: 22 * tScale),
              ),
              if (widget.onEnterScores != null)
                IconButton(
                  icon: const Icon(Icons.score),
                  color: _accentBlue,
                  onPressed: widget.onEnterScores,
                  iconSize: 22 * tScale,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          // Centro: nombre + HCP
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.tarjeta.jugador!.nombre,
                overflow: TextOverflow.ellipsis,
                style: whiteBold.copyWith(fontSize: 19 * tScale),
              ),
              const SizedBox(height: 2),
              Text(
                'HCP ${widget.tarjeta.handicapPlayer}',
                style: whiteBold.copyWith(
                  fontSize: 14 * tScale,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Derecha: Score vs Par
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Par',
                style: TextStyle(color: Colors.grey, fontSize: 14 * tScale),
              ),
              const SizedBox(height: 2),
              Text(
                widget.tarjeta.scoreParString,
                style: whiteBold.copyWith(fontSize: 22 * tScale),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TABLA ----------------
  Widget _crearCuerpoEstadisticas(TextStyle whiteBold, double maxWidth, double tScale) {
    int total = widget.tarjeta.hoyos.length;
    int mid = (total / 2).floor();
    List<EstadisticaHoyo> ida = widget.tarjeta.hoyos.sublist(0, mid);
    List<EstadisticaHoyo> vuelta = widget.tarjeta.hoyos.sublist(mid, total);

    return Column(
      children: [
        _tabla('Ida', ida, 0, whiteBold, maxWidth, tScale),
        _tabla('Vuelta', vuelta, ida.length, whiteBold, maxWidth, tScale),
      ],
    );
  }

  Widget _tabla(
    String titulo,
    List<EstadisticaHoyo> hoyos,
    int offset,
    TextStyle whiteBold,
    double maxWidth,
    double tScale,
  ) {
    final TextStyle header = whiteBold.copyWith(fontSize: 13 * tScale, fontWeight: FontWeight.w700);
    final TextStyle normal = whiteBold.copyWith(fontSize: 13 * tScale, fontWeight: FontWeight.w400);

    // Dimensiones responsivas
    const double leftColMin = 56;  // "Hoyo/Hcp/Par/Score/Neto"
    const double rightColMin = 58; // Totales
    final double usable = (maxWidth - leftColMin - rightColMin).clamp(240, 2000);
    final double cellW  = (usable / hoyos.length).clamp(24, 46); // límites razonables

    // Column widths
    final Map<int, TableColumnWidth> widths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(leftColMin),
      for (int i = 1; i <= hoyos.length; i++) i: FixedColumnWidth(cellW),
      hoyos.length + 1: const FixedColumnWidth(rightColMin),
    };

    Widget filaColor(bool even, Widget child) => Container(
          color: even ? _rowEven : _rowOdd,
          child: child,
        );

    // Helper para centrar texto
    Widget c(String s, TextStyle st, {int maxLines = 1}) => Center(
          child: Text(s, style: st, maxLines: maxLines, overflow: TextOverflow.ellipsis),
        );

    return Table(
      columnWidths: widths,
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade800, width: 0.6),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header fila 1
        TableRow(
          decoration: const BoxDecoration(color: _greenDark),
          children: [
            c('Hoyo', header),
            ...List.generate(hoyos.length, (i) => c('${i + 1 + offset}', header)),
            c(titulo, header),
          ],
        ),
        // HCP row
        TableRow(
          children: [
            c('Hcp', normal),
            ...hoyos.map((h) => c('${h.hoyo.handicap}', normal)),
            const SizedBox(),
          ],
        ),
        // Par row
        TableRow(
          children: [
            c('Par', normal),
            ...hoyos.map((h) => c('${h.hoyo.par}', normal)),
            c(
              titulo == 'Ida' ? '${widget.tarjeta.parIda}' : '${widget.tarjeta.parVuelta}',
              whiteBold,
            ),
          ],
        ),
        // Score row
        TableRow(
          children: [
            c('Score', whiteBold),
            ...hoyos.map((h) => celdaTarjeta(h.pontajeVsPar, h.golpes)),
            c(
              titulo == 'Ida'
                  ? (widget.tarjeta.scoreIda == 0 ? '' : '${widget.tarjeta.scoreIda}')
                  : (widget.tarjeta.scoreVuelta == 0 ? '' : '${widget.tarjeta.scoreVuelta}'),
              whiteBold,
            ),
          ],
        ),
        // Neto row
        TableRow(
          children: [
            c('Neto', whiteBold),
            ...hoyos.map((h) => h.golpes == 0 ? const SizedBox() : c('${h.neto}', whiteBold)),
            c(
              titulo == 'Ida'
                  ? (widget.tarjeta.netoIda == 0 ? '' : '${widget.tarjeta.netoIda}')
                  : (widget.tarjeta.netoVuelta == 0 ? '' : '${widget.tarjeta.netoVuelta}'),
              whiteBold,
            ),
          ],
        ),
      ].asMap().entries.map((e) {
        if (e.key == 0) return e.value; // header sin alternar
        return TableRow(
          children: e.value.children.map((c) => filaColor(e.key.isEven, c)).toList(),
        );
      }).toList(),
    );
  }

  // ---------- Celdas Score ----------
  Widget celdaTarjeta(int scorePar, int golpes){
    TextStyle styleScore = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
    TextStyle styleScoreDiferente = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

    if (golpes == 0) {
      return const SizedBox();
    }

    switch (scorePar) {
      case -1:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: kBerdieColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );

      case -2:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: kEagleColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );

      case -3:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: kAlvatrosColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );

      case 0:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Center(child: Text(golpes.toString(), style: styleScore)),
          ),
        );

      case 1:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            color: kBogeyColor,
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );

      case 2:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            color: kDoubleBogueColor,
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.all(2),
            color: kDoubleBogueColor,
            child: Center(child: Text(golpes.toString(), style: styleScoreDiferente)),
          ),
        );
    }
  }

  // ---------------- FOOTER ----------------
  Widget _crearFooter(TextStyle whiteBold) {
    return Container(
      color: _headerBg,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Par', style: whiteBold),
          Text('Tee ${widget.tarjeta.teeSalida}', style: whiteBold),
          Text('${widget.tarjeta.puntuacionTotal}/${widget.tarjeta.netoSimpleTotal}',
              style: whiteBold),
        ],
      ),
    );
  }

  // ---------- Navegar a pantalla de stats ----------
  void goEstadisticas() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GolfScoreScreen(tarjeta: widget.tarjeta),
        ),
      );
}
