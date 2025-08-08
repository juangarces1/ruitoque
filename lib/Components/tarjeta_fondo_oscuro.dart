import 'package:flutter/material.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Estadisticas/golf_score_screen.dart';
import 'package:ruitoque/constans.dart';

// Paleta oscura centralizada
const Color _cardBg      = Color(0xFF1A1A1D); // gris‑casi‑negro
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

    return Card(
      color: _cardBg,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 3,
      child: ExpansionTile(
        collapsedBackgroundColor: _headerBg,
        backgroundColor: _headerBg,
        collapsedIconColor: _accentBlue,
        iconColor: _accentBlue,
        title: _crearHeader(whiteBold),
        children: <Widget>[
          Divider(color: Colors.grey.shade700, height: 0),
          _crearCuerpoEstadisticas(whiteBold),
          Divider(color: Colors.grey.shade700, height: 0),
          _crearFooter(whiteBold),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _crearHeader(TextStyle whiteBold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Izquierda: posición + botón score
          Column(
            children: [
              Text(widget.tarjeta.posicion.toString(),
                  style: whiteBold.copyWith(fontSize: 22)),
              if (widget.onEnterScores != null)
                IconButton(
                  icon: const Icon(Icons.score),
                  color: _accentBlue,
                  onPressed: widget.onEnterScores,
                ),
            ],
          ),
          // Centro: nombre + HCP
          Column(
            children: [
              Text(widget.tarjeta.jugador!.nombre,
                  style: whiteBold.copyWith(fontSize: 19)),
              const SizedBox(height: 2),
              Text('HCP ${widget.tarjeta.handicapPlayer}',
                  style: whiteBold.copyWith(
                      fontSize: 14, color: Colors.grey.shade300)),
            ],
          ),
          // Derecha: Score vs Par
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Par',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 2),
              Text(widget.tarjeta.scoreParString,
                  style: whiteBold.copyWith(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TABLA ----------------
  Widget _crearCuerpoEstadisticas(TextStyle whiteBold) {
    int total = widget.tarjeta.hoyos.length;
    int mid = (total / 2).floor();
    List<EstadisticaHoyo> ida = widget.tarjeta.hoyos.sublist(0, mid);
    List<EstadisticaHoyo> vuelta = widget.tarjeta.hoyos.sublist(mid, total);

    return Column(
      children: [
        _tabla('Ida', ida, 0, whiteBold),
        _tabla('Vuelta', vuelta, ida.length, whiteBold),
      ],
    );
  }

  Widget _tabla(String titulo, List<EstadisticaHoyo> hoyos, int offset,
      TextStyle whiteBold) {
    TextStyle header = whiteBold.copyWith(fontSize: 13);
    TextStyle normal =
        whiteBold.copyWith(fontSize: 13, fontWeight: FontWeight.w400);

    // Anchos de columnas
    Map<int, TableColumnWidth> widths = {0: const FlexColumnWidth(1)};
    for (int i = 1; i <= hoyos.length; i++) {
      widths[i] = const FixedColumnWidth(26);
    }
    widths[hoyos.length + 1] = const FixedColumnWidth(42);

    Widget filaColor(bool even, Widget child) => Container(
          color: even ? _rowEven : _rowOdd,
          child: child,
        );

    return Table(
      columnWidths: widths,
      border: TableBorder(
        horizontalInside:
            BorderSide(color: Colors.grey.shade800, width: 0.6),
      ),
      children: [
        // Header fila 1
        TableRow(
          decoration: const BoxDecoration(color: _greenDark),
          children: [
            Center(child: Text('Hoyo', style: header)),
            ...List.generate(
                hoyos.length,
                (i) => Center(
                    child: Text('${i + 1 + offset}', style: header))),
            Center(child: Text(titulo, style: header)),
          ],
        ),
        // HCP row
        TableRow(
          children: [
            Center(child: Text('Hcp', style: normal)),
            ...hoyos.map((h) =>
                Center(child: Text('${h.hoyo.handicap}', style: normal))),
            const SizedBox(),
          ],
        ),
        // Par row
        TableRow(
          children: [
            Center(child: Text('Par', style: normal)),
            ...hoyos.map((h) =>
                Center(child: Text('${h.hoyo.par}', style: normal))),
            Center(
                child: Text(
                    titulo == 'Ida'
                        ? '${widget.tarjeta.parIda}'
                        : '${widget.tarjeta.parVuelta}',
                    style: whiteBold)),
          ],
        ),
        // Score row
        TableRow(
          children: [
            Center(child: Text('Score', style: whiteBold)),
            ...hoyos.map((h) => celdaTarjeta(h.pontajeVsPar, h.golpes)),
            Center(
                child: Text(
                    titulo == 'Ida'
                        ? (widget.tarjeta.scoreIda == 0
                            ? ''
                            : '${widget.tarjeta.scoreIda}')
                        : (widget.tarjeta.scoreVuelta == 0
                            ? ''
                            : '${widget.tarjeta.scoreVuelta}'),
                    style: whiteBold)),
          ],
        ),
        // Neto row
        TableRow(
          children: [
            Center(child: Text('Neto', style: whiteBold)),
            ...hoyos.map((h) => h.golpes == 0
                ? const SizedBox()
                : Center(child: Text('${h.neto}', style: whiteBold))),
            Center(
                child: Text(
                    titulo == 'Ida'
                        ? (widget.tarjeta.netoIda == 0
                            ? ''
                            : '${widget.tarjeta.netoIda}')
                        : (widget.tarjeta.netoVuelta == 0
                            ? ''
                            : '${widget.tarjeta.netoVuelta}'),
                    style: whiteBold)),
          ],
        ),
      ].asMap().entries.map((e) {
        // Alterna fondo en filas de datos (except header)
        if (e.key == 0) return e.value;
        return TableRow(
            children: e.value.children
                .map((c) => filaColor(e.key.isEven, c))
                .toList());
      }).toList(),
    );
  }

  // ---------- Celdas Score ----------
  Widget celdaTarjeta(int scorePar, int golpes){
     TextStyle styleScore = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
     TextStyle styleScoreDiferente = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
     if(golpes == 0){
      return Text('', style: styleScore,);
     }
     switch (scorePar) {
      case -1:
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kBerdieColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
                ),
        );
    
    case -2:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kEagleColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );

     case -3:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), // Ajusta este valor para cambiar el tamaño del círculo
          decoration: const BoxDecoration(
            color: kAlvatrosColor, // Color de fondo del círculo
            shape: BoxShape.circle, // Hace que el Container sea circular
          ),
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );

    case 0:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScore,
            ),
          ),
         ),
      );
    case 1:
     return Padding(
       padding: const EdgeInsets.all(2),
       child: Container(
          padding: const EdgeInsets.all(2), 
          color: kBogeyColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
     );
     case 2:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          color: kDoubleBogueColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
         ),
      );
    default:
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(2), 
          color: kDoubleBogueColor,
          child: Center(
            child: Text(
              golpes.toString(),
              style: styleScoreDiferente,
            ),
          ),
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
