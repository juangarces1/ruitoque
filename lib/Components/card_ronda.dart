import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Models/fede_amigos.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/skin.dart';
import 'package:ruitoque/Models/stable_ford_hoyo.dart';
import 'package:ruitoque/Screens/Ronda/ronda_rapida.dart';
import 'package:ruitoque/constans.dart';

class CardRonda extends StatefulWidget {
  final Ronda ronda;
  const CardRonda({super.key, required this.ronda});

  @override
  State<CardRonda> createState() => _CardRondaState();
}

class _CardRondaState extends State<CardRonda> {
  bool skinsCalculados = false;
  bool stablefordCalculado = false;
  bool fedeAmigosCalculado = false;

  bool mostrarSkins = false;
  bool mostrarStableford = false;
  bool mostrarfedeAmigos = false;

  @override
  Widget build(BuildContext context) {
    widget.ronda.tarjetas.sort((a, b) => a.scorePar.compareTo(b.scorePar));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: const Color.fromARGB(255, 32, 32, 32),
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Stack(
        children: [
          // CONTENIDO
          Padding(
            padding: const EdgeInsets.only(bottom: 76), // espacio para el SpeedDial
            child: Column(
              children: <Widget>[
                _crearHeader(),
                const SizedBox(height: 8),

                // Tarjetas
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.ronda.tarjetas.length,
                  itemBuilder: (_, index) {
                    return NewTarjetaCard(
                      tarjeta: widget.ronda.tarjetas[index],
                      onSave: _confirmBack,
                      onBack: _confirmBack,
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Secciones dinámicas
                if (mostrarSkins) _crearSkinsSection(),
                if (mostrarStableford) _crearStablefordSection(),
                if (mostrarfedeAmigos) _crearFedeAmigosSection(),

                
              ],
            ),
          ),

          // SPEED DIAL (posicionado sobre el Card)
          Positioned(
            right: 18,
            bottom: 12,
            child: _buildSpeedDial(context),
          ),
        ],
      ),
    );
  }

  // ---------- SpeedDial dentro del Card ----------
  Widget _buildSpeedDial(BuildContext context) {
    return SpeedDial(
      heroTag: 'sd_ronda_${widget.ronda.id}', // único por si hay varios Cards
      icon: Icons.menu,
      activeIcon: Icons.close,
      backgroundColor: kPprimaryColor,
      foregroundColor: Colors.white,
      animationDuration: const Duration(milliseconds: 220),
      overlayOpacity: 0.0, // sin overlay para no ensuciar el card
      spacing: 6,
      childPadding: const EdgeInsets.all(6),
      shape: const StadiumBorder(),
      direction: SpeedDialDirection.up,
      children: [
        // Skins
        SpeedDialChild(
          label: mostrarSkins ? 'Ocultar Skins' : 'Ver Skins',
          child: Icon(mostrarSkins ? Icons.visibility_off : Icons.visibility),
          backgroundColor: Colors.blueAccent,
          onTap: _toggleSkins,
        ),
        // Stableford
        SpeedDialChild(
          label: mostrarStableford ? 'Ocultar Stableford' : 'Ver Stableford',
          child: Icon(mostrarStableford ? Icons.visibility_off : Icons.visibility),
          backgroundColor: Colors.teal,
          onTap: _toggleStableford,
        ),
        // FedeAmigos
        SpeedDialChild(
          label: mostrarfedeAmigos ? 'Ocultar FedeAmigos' : 'Ver FedeAmigos',
          child: Icon(mostrarfedeAmigos ? Icons.visibility_off : Icons.visibility),
          backgroundColor: Colors.purple,
          onTap: _toggleFedeAmigos,
        ),
        // Detalle (navegación)
        SpeedDialChild(
          label: 'Detalle de Ronda',
          child: const Icon(Icons.info_outline ),
          backgroundColor: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RondaRapida(
                ronda: widget.ronda
                , ruta: 'MisRondas',
                )),
            );
          },
        ),
      ],
    );
  }

  // ---------- Toggles ----------
  void _toggleFedeAmigos() {
    if (!mostrarfedeAmigos && !fedeAmigosCalculado) {
      widget.ronda.calcularFedeAmigos();
      fedeAmigosCalculado = true;
    }
    setState(() => mostrarfedeAmigos = !mostrarfedeAmigos);
  }

  void _toggleSkins() {
    if (!mostrarSkins && !skinsCalculados) {
      widget.ronda.calcularSkins();
      skinsCalculados = true;
    }
    setState(() => mostrarSkins = !mostrarSkins);
  }

  void _toggleStableford() {
    if (!mostrarStableford && !stablefordCalculado) {
      widget.ronda.calcularStableford();
      stablefordCalculado = true;
    }
    setState(() => mostrarStableford = !mostrarStableford);
  }

  // ---------- Header ----------
  Widget _crearHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: const BoxDecoration(
        gradient: kGradientHomeReverse,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                widget.ronda.campo.nombre,
                style: kTextStyleBlancoRobotoSize20Normal,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.ronda.fecha.toString().substring(0, 10),
                style: kTextStyleBlancoRobotoSize20Normal),
          ]),
        ],
      ),
    );
  }

  Future<void> _confirmBack() async {}

  // ---------- Secciones ----------
  Widget _crearStablefordSection() {
    if (widget.ronda.stablefordResult == null ||
        widget.ronda.stablefordResult!.puntosPorHoyo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se han asignado puntos Stableford para esta ronda.'),
      );
    }

    final Map<int, List<StablefordHoyo>> puntosPorHoyoMap = {};
    for (final punto in widget.ronda.stablefordResult!.puntosPorHoyo) {
      puntosPorHoyoMap.putIfAbsent(punto.holeNumber, () => []).add(punto);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Stableford', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Puntos Totales por Jugador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: ListView(
            children: widget.ronda.stablefordResult!.puntosTotalesPorJugador.entries.map((e) {
              final Jugador j = e.key;
              final int puntos = e.value;
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue, foregroundColor: Colors.white, child: Text(j.nombre[0])),
                title: Text(j.nombre),
                trailing: Text('Puntos: $puntos', style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Puntos por Hoyo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 300,
          child: ListView(
            children: puntosPorHoyoMap.entries.map((entry) {
              final int holeNumber = entry.key;
              final puntos = entry.value;
              return ExpansionTile(
                title: Text('Hoyo $holeNumber'),
                children: puntos.map((p) {
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.orange, foregroundColor: Colors.white, child: Text(p.jugador.nombre[0])),
                    title: Text(p.jugador.nombre),
                    trailing: Text('Puntos: ${p.puntos}'),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _crearFedeAmigosSection() {
    if (widget.ronda.fedeAmigosResult == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se han calculado los resultados de FedeAmigos.'),
      );
    }

    final FedeAmigosResult result = widget.ronda.fedeAmigosResult!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _chip('FedeAmigos', Colors.blueAccent),
        const SizedBox(height: 8),
        _chip('Puntos por Jugador', Colors.purple),
        ...result.puntosPorJugador.entries.map((entry) {
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.purple, foregroundColor: Colors.white, child: Icon(Icons.person)),
            title: Text(entry.key.nombre, style: kTextStyleBlancoNuevaFuente20),
            trailing: Text('Puntos: ${entry.value.toStringAsFixed(2)}', style: kTextStyleBlancoNuevaFuente20),
          );
        }).toList(),
        const SizedBox(height: 8),
        _chip('Hoyos Ganados', Colors.green),
        ...result.hoyosGanados.map((hg) {
          return ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green, foregroundColor: Colors.white, child: Text(hg.holeNumber.toString(), style: kTextStyleNegroRobotoSize20)),
            title: Text('Hoyo ${hg.holeNumber}', style: kTextStyleBlancoNuevaFuente20),
            subtitle: Text(hg.ganador.nombre, style: kTextStyleBlancoNuevaFuente20),
          );
        }).toList(),
        const SizedBox(height: 8),
        _chip('Medal - Ida', Colors.orange),
        _crearListaPosiciones(result.posicionesIda),
        _chip('Medal - Vuelta', Colors.orange),
        _crearListaPosiciones(result.posicionesVuelta),
        _chip('Medal - Total', Colors.orange),
        _crearListaPosiciones(result.posicionesTotal),
      ]),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
      ]),
      child: Center(child: Text(text, style: kTextStyleNegroRobotoSize20)),
    );
  }

  Widget _crearListaPosiciones(List<PosicionCategoria> posiciones) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posiciones.length,
      itemBuilder: (context, index) {
        final p = posiciones[index];
        final jugadoresTexto = p.jugadores.map((j) => j.nombre).join(', ');
        return ListTile(
          leading: CircleAvatar(backgroundColor: Colors.orange, foregroundColor: Colors.white, child: Text('${p.posicion}°', style: kTextStyleNegroRobotoSize20)),
          title: Text('Posición ${p.posicion}', style: kTextStyleBlancoNuevaFuente20),
          subtitle: Text('Jugadores: $jugadoresTexto', style: kTextStyleBlancoNuevaFuente20),
        );
      },
    );
  }

  Widget _crearSkinsSection() {
    if (widget.ronda.skins!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se han asignado skins para esta ronda.'),
      );
    }
    const textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Skins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ronda.skins!.length,
            itemBuilder: (context, index) {
              final Skin skin = widget.ronda.skins![index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green, foregroundColor: Colors.white, child: Text(skin.holeNumber.toString(), style: kTextStyleBlancoRobotoSize20Normal)),
                title: const Text('Hoyo', style: textStyle),
                subtitle: Text('Ganador: ${skin.ganador.nombre}', style: textStyle),
                trailing: Text('Neto: ${skin.scoreNeto}', style: textStyle),
              );
            },
          ),
        ]),
      ),
    );
  }
}
