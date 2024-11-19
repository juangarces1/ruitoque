
import 'package:flutter/material.dart';
import 'package:ruitoque/Components/new_card_tardejta.dart';
import 'package:ruitoque/Models/fede_amigos.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/skin.dart';
import 'package:ruitoque/Models/stable_ford_hoyo.dart';
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
      shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
      color: Colors.white,
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      child: Column(
        children: <Widget>[
          _crearHeader(),
          const Divider(),
          // Remove Expanded and LayoutBuilder
          // Directly include ListView.builder with proper constraints
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ronda.tarjetas.length,
            itemBuilder: (BuildContext context, int index) {
              return NewTarjetaCard(
                tarjeta: widget.ronda.tarjetas[index],
                onSave: _confirmBack,
                onBack: _confirmBack,
              );
            },
          ),
  
         
            const SizedBox(height: 8),
          
            _crearBotonesCalculo(),
            const SizedBox(height: 8),
            if (mostrarSkins) _crearSkinsSection(),
            if (mostrarStableford) _crearStablefordSection(),
            if (mostrarfedeAmigos) _crearFedeAmigosSection(),
        ],
      ),
    );
  }


   Widget _crearBotonesCalculo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón para Skins
            ElevatedButton(
              onPressed: _toggleSkins,
              style: ElevatedButton.styleFrom(
                backgroundColor: mostrarSkins ? Colors.red : Colors.blue,
              ),
              child: Text(mostrarSkins ? 'Hide Skins' : 'Show Skins', style: kTextStyleBlancoNuevaFuente20,),
            ),
            // Botón para Stableford
            ElevatedButton(
              onPressed: _toggleStableford,
              style: ElevatedButton.styleFrom(
                backgroundColor: mostrarStableford ? Colors.red : Colors.green,
              ),
              child: Text(mostrarStableford ? 'Hide Stableford' : 'Show Stableford',  style: kTextStyleBlancoNuevaFuente20,),
            ),
        
          
          ],
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botón para Skins
          
             ElevatedButton(
               style: ElevatedButton.styleFrom(
                backgroundColor: mostrarfedeAmigos ? Colors.red : const Color.fromARGB(255, 62, 14, 129),
              ),
              onPressed: _toggleFedeAmigos,
              child: Text(mostrarfedeAmigos ? 'Hide FedeAmigos' : 'Show FedeAmigos', style: kTextStyleBlancoNuevaFuente20,),
            ),
          ],
        ),
      ],
    );
  }

   void _toggleFedeAmigos() {
    if (!mostrarfedeAmigos) {
      // Si las skins no se han calculado aún, calcular primero
      if (!fedeAmigosCalculado) {
        widget.ronda.calcularFedeAmigos();
        fedeAmigosCalculado = true;
      }
      setState(() {
        mostrarfedeAmigos = true;
      });
    } else {
      // Ocultar la sección de skins
      setState(() {
        mostrarfedeAmigos = false;
      });
    }
  }

   void _toggleSkins() {
    if (!mostrarSkins) {
      // Si las skins no se han calculado aún, calcular primero
      if (!skinsCalculados) {
        widget.ronda.calcularSkins();
        skinsCalculados = true;
      }
      setState(() {
        mostrarSkins = true;
      });
    } else {
      // Ocultar la sección de skins
      setState(() {
        mostrarSkins = false;
      });
    }
  }

  void _toggleStableford() {
    if (!mostrarStableford) {
      // Si Stableford no se ha calculado aún, calcular primero
      if (!stablefordCalculado) {
        widget.ronda.calcularStableford();
        stablefordCalculado = true;
      }
      setState(() {
        mostrarStableford = true;
      });
    } else {
      // Ocultar la sección de Stableford
      setState(() {
        mostrarStableford = false;
      });
    }
  }

    Widget _crearStablefordSection() {
    if (widget.ronda.stablefordResult == null || widget.ronda.stablefordResult!.puntosPorHoyo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se han asignado puntos Stableford para esta ronda.'),
      );
    }

    // Agrupar los puntos por hoyo
    Map<int, List<StablefordHoyo>> puntosPorHoyoMap = {};
    for (StablefordHoyo punto in widget.ronda.stablefordResult!.puntosPorHoyo) {
      puntosPorHoyoMap.putIfAbsent(punto.holeNumber, () => []).add(punto);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stableford',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Tabla de Puntos Totales por Jugador
          const Text(
            'Puntos Totales por Jugador',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 200, // Ajusta la altura según tus necesidades
            child: ListView(
              children: widget.ronda.stablefordResult!.puntosTotalesPorJugador.entries.map((entry) {
                Jugador jugador = entry.key;
                int puntos = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    child: Text(jugador.nombre[0]),
                  ),
                  title: Text(jugador.nombre),
                  trailing: Text('Puntos: $puntos', style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Tabla de Puntos por Hoyo
          const Text(
            'Puntos por Hoyo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 300, // Ajusta la altura según tus necesidades
            child: ListView(
              children: puntosPorHoyoMap.entries.map((entry) {
                int holeNumber = entry.key;
                List<StablefordHoyo> puntos = entry.value;
                return ExpansionTile(
                  title: Text('Hoyo $holeNumber'),
                  children: puntos.map((punto) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        child: Text(punto.jugador.nombre[0]),
                      ),
                      title: Text(punto.jugador.nombre),
                      trailing: Text('Puntos: ${punto.puntos}'),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

    Widget _crearHeader() {

    return  Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
     decoration: const BoxDecoration(
      gradient: kGradientHomeReverse,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
     ),
      child: Column(
       
        children: [
           
           Center(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                       
                 Text('Campo: ${widget.ronda.campo.nombre}', style : kTextStyleBlancoNuevaFuente20),
              ],),
           ),
            
              Center(
                child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                Text('Fecha: ${widget.ronda.fecha.toString().substring(0,10)}', style : kTextStyleBlancoNuevaFuente20),
                
                            ],),
              ),
        
        ],
      ),
    );
  }

  Future<void> _confirmBack() async {
  }

   Widget _crearFedeAmigosSection() {
    if (widget.ronda.fedeAmigosResult == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se han calculado los resultados de FedeAmigos.'),
      );
    }

    FedeAmigosResult result = widget.ronda.fedeAmigosResult!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FedeAmigos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Mostrar puntos por jugador
          const Text(
            'Puntos por Jugador',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...result.puntosPorJugador.entries.map((entry) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                child: Text(entry.key.nombre[0],style: kTextStyleBlancoNuevaFuente20, ),
              ),
              title: Text(entry.key.nombre,style: kTextStyleNegroRobotoSize20, ),
              trailing: Text('Puntos: ${entry.value.toStringAsFixed(2)}',style: kTextStyleNegroRobotoSize20, ),
            );
          }).toList(),
          const SizedBox(height: 8),
          // Mostrar hoyos ganados
          const Center(
            child: Text(
              'Hoyos Ganados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...result.hoyosGanados.map((hoyoGanado) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: Text(hoyoGanado.holeNumber.toString(),style: kTextStyleBlancoNuevaFuente20, ),
              ),
              title: Text('Hoyo ${hoyoGanado.holeNumber}',style: kTextStyleNegroRobotoSize20, ),
              subtitle: Text(hoyoGanado.ganador.nombre,style: kTextStyleNegroRobotoSize20, ),
            );
          }).toList(),
             const SizedBox(height: 8),
              const Text(
              'Posiciones - Ida',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _crearListaPosiciones(result.posicionesIda),

            // Mostrar posiciones de la Vuelta
            const Text(
              'Posiciones - Vuelta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _crearListaPosiciones(result.posicionesVuelta),

            // Mostrar posiciones del Total Neto
            const Text(
              'Posiciones - Total Neto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _crearListaPosiciones(result.posicionesTotal),
            ],
      ),
    );
  }

  Widget _crearListaPosiciones(List<PosicionCategoria> posiciones) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: posiciones.length,
    itemBuilder: (context, index) {
      PosicionCategoria posicion = posiciones[index];
      String jugadoresTexto = posicion.jugadores.map((j) => j.nombre).join(', ');
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: Text('${posicion.posicion}°',style: kTextStyleBlancoNuevaFuente20, ),
        ),
        title: Text('Posición ${posicion.posicion}',style: kTextStyleNegroRobotoSize20, ),
        subtitle: Text('Jugadores: $jugadoresTexto',style: kTextStyleNegroRobotoSize20, ),
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
    TextStyle textStyle =  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skins',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ronda.skins!.length,
            itemBuilder: (context, index) {
              Skin skin = widget.ronda.skins![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  child: Text(skin.holeNumber.toString(), style: kTextStyleBlancoNuevaFuente20,),
                ),
                title: Text('Hoyo ${skin.holeNumber}', style:  textStyle,),
                subtitle: Text('Ganador: ${skin.ganador.nombre}', style:  textStyle,),
                trailing: Text('Score Neto: ${skin.scoreNeto}', style:  textStyle,),
              );
            },
          ),
        ],
      ),
    );
  }
}
