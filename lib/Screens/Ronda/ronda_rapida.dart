import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/custom_header.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/tarjeta_fondo_oscuro.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/fede_amigos.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/Home/my_home_pag.dart';
import 'package:ruitoque/constans.dart';

class RondaRapida extends StatefulWidget {
  final Ronda ronda;
  final String ruta;
 
  const RondaRapida({super.key, required this.ronda, required this.ruta });

  @override
  State<RondaRapida> createState() => _RondaRapidaState();
}

class _RondaRapidaState extends State<RondaRapida> {
  bool showLoader = false;
  late Ronda _ronda;
  late Jugador jugador;
  late Tarjeta myTarjeta;
  bool isCreator = false;  
  get jugadoresSeleccionados => null;

  bool mostrarFedeAmigos = false;
  bool fedeAmigosCalculado = false;
  final NumberFormat _miles = NumberFormat('#,##0', 'es_CO'); // 12.345

  Future<int?> _handicapDialog(BuildContext context, Tarjeta tarjeta) {
  int hcp = tarjeta.handicapPlayer;

  return showDialog<int>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Hándicap de ${tarjeta.jugador!.nombre}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () => setStateDialog(() { if (hcp > 0) hcp--; }),
              ),
              Text('$hcp', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => setStateDialog(() => hcp++),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),      // <- retorna null
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () => Navigator.pop(context, hcp), // <- retorna hcp
            ),
          ],
        ),
      );
    },
  );
}

 Future<void> _selectPlayerAndEditHandicap() async {
  // ← devuelve la tarjeta elegida, o null si cancelan
  final Tarjeta? elegido = await showModalBottomSheet<Tarjeta>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,        // deja ver la sombra
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,  // alto inicial (45 % de la pantalla)
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Grip “arrastrable”
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Selecciona jugador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,   // ← para el drag sheet
                    itemCount: _ronda.tarjetas.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final t = _ronda.tarjetas[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPcontrastMoradoColor,
                          foregroundColor: Colors.white,
                          child: Text(t.jugador!.nombre[0]),
                        ),
                        title: Text(
                          t.jugador!.nombre,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Hcp actual: ${t.handicapPlayer}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pop(context, t),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  // Si seleccionó alguien, lanzamos el diálogo de +/–
  if (elegido != null) _showHandicapDialogForPlayer(elegido);
}


  void _toggleFedeAmigos() {
    if (!mostrarFedeAmigos) {
      if (!fedeAmigosCalculado) {
        widget.ronda.calcularFedeAmigos();
        fedeAmigosCalculado = true;
      }
    }
    setState(() => mostrarFedeAmigos = !mostrarFedeAmigos);
  }

  @override
  void initState() {
    super.initState();
      _ronda=widget.ronda;
   
     jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;   
     isCreator = jugador.id == _ronda.creatorId ? true: false;
     myTarjeta =  _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
     _ronda.calcularYAsignarPosiciones();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(           // <<–– ahora tenemos un Scaffold
       floatingActionButton: SpeedDial(
          icon: Icons.menu,           // icono cerrado
          activeIcon: Icons.close,    // icono abierto
          animationDuration: const Duration(milliseconds: 250),
          overlayOpacity: 0.3,        // oscurece fondo al abrir
          direction: SpeedDialDirection.up,  // se despliega hacia arriba
          children: [
            SpeedDialChild(
              label: mostrarFedeAmigos ? 'Ocultar FedeAmigos' : 'Ver FedeAmigos',
              child: Icon(
                mostrarFedeAmigos ? Icons.visibility_off : Icons.visibility,
              ),
              onTap: _toggleFedeAmigos,
            ),
            SpeedDialChild(
              label: 'Editar Hándicap',
              backgroundColor: Colors.orange,
              child: const Icon(Icons.flag),
              onTap: _selectPlayerAndEditHandicap,
            ),
          ],
        ),
      backgroundColor: Colors.transparent,   // para que se vea tu gradiente
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
          child: Column(
            children: [
              // ───── HEADER ─────
              CustomHeader(
                title: _ronda.campo.nombre,
                onBack: _confirmBack,
                onSave: _confirmSave,
                onRefresh: _goRefresh,
                isCreator: isCreator,
              ),
              const SizedBox(height: 12),
              // ───── CUERPO SCROLLEABLE ─────
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // ---------- TARJETAS ----------
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => NewTarjetaCardDark(
                              tarjeta: _ronda.tarjetas[index],
                              onSave: _confirmSave,
                              onBack: _confirmBack,
                              onEnterScores: () => _showScoreEntryDialogForPlayer(
                                _ronda.tarjetas[index],
                              ),
                            ),
                            childCount: _ronda.tarjetas.length,
                          ),
                        ),

                        // ---------- FEDEAMIGOS ----------
                        SliverToBoxAdapter(
                          child: Visibility(
                            visible: mostrarFedeAmigos,
                            maintainState: true,
                            child: _crearFedeAmigosSection(),
                          ),
                        ),

                        // Espacio final para que el FAB no tape nada
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),

                    // ---------- LOADER ----------
                    if (showLoader)
                      const Positioned.fill(child: MyLoader(opacity: 1, text: '')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _showHandicapDialogForPlayer(Tarjeta tarjeta) async {
  final int? nuevoHcp = await _handicapDialog(context, tarjeta);

  if (nuevoHcp != null && mounted) {
    setState(() {
      tarjeta.actualizarHandicapJugador(nuevoHcp); 
        _ronda.calcularYAsignarPosiciones();    // ordena posiciones, etc.
        if (fedeAmigosCalculado) _ronda.calcularFedeAmigos();
    });

    Fluttertoast.showToast(
      msg: "Hándicap actualizado a $nuevoHcp.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16,
    );
  }
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
            Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // Fondo del texto
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'FedeAmigos',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 8),
          // Mostrar puntos por jugador
             Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color:Colors.purple,
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Puntos por Jugador',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
              ),
          ...result.puntosPorJugador.entries.map((entry) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                child: Text(
                  entry.key.nombre[0],
                  style: kTextStyleBlancoNuevaFuente20,
                ),
              ),
              title: Text(
                entry.key.nombre,
                style: kTextStyleBlancoNuevaFuente20,
                overflow: TextOverflow.ellipsis, // corta con '…' si aún se pasa
              ),
              subtitle: Text(
                'Pts: ${entry.value.toStringAsFixed(2)}    --    \$${_miles.format((entry.value * (1000 * widget.ronda.tarjetas.length)).round())}',  
                style: kTextStyleBlancoNuevaFuente20,
              ),
              dense: true, // opcional: baja la altura
            );

          }).toList(),
          const SizedBox(height: 8),
          // Mostrar hoyos ganados
            Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color:Colors.green,
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Hoyos Ganados',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
              ),
          ...result.hoyosGanados.map((hoyoGanado) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: Text(hoyoGanado.holeNumber.toString(),style: kTextStyleBlancoNuevaFuente20, ),
              ),
              title: Text('Hoyo ${hoyoGanado.holeNumber}',style: kTextStyleBlancoNuevaFuente20, ),
              subtitle: Text(hoyoGanado.ganador.nombre,style: kTextStyleBlancoNuevaFuente20, ),
            );
          }).toList(),
             const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color:Colors.orange,
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Medal - Ida',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
              ),
            _crearListaPosiciones(result.posicionesIda),

            // Mostrar posiciones de la Vuelta
             Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Medal - Vuelta',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
              ),
            _crearListaPosiciones(result.posicionesVuelta),

            // Mostrar posiciones del Total Neto
               Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color:Colors.orange,
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Sombra suave
                      blurRadius: 8,
                      offset: const Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Medal - Total',
                    style: TextStyle(
                      fontSize: 18, // Tamaño de fuente un poco mayor
                      fontWeight: FontWeight.bold, // Fuente en negrita
                      color: Colors.white, // Texto en color blanco para contraste
                    ),
                  ),
                ),
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
        title: Text('Posición ${posicion.posicion}',style: kTextStyleBlancoNuevaFuente20, ),
        subtitle: Text('Jugadores: $jugadoresTexto',style: kTextStyleBlancoNuevaFuente20, ),
      );
    },
  );
}


  Future<bool> mostrarDialogoSalida(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }
   
  Future<void> _confirmSave() async {
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmación'),
      content: Text(
        _ronda.id == 0
            ? '¿Deseas GUARDAR esta nueva ronda?'
            : '¿Deseas ACTUALIZAR la ronda?'),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('Aceptar'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (ok == true) _saveRonda();
}

Future<void> _saveRonda() async {
  final bool isNew = _ronda.id == 0;

  // Marcar completa si aplica
  if (_isComplete()) _ronda.isComplete = true;

  if (!mounted) return;
  setState(() => showLoader = true);

  final String url = isNew ? 'api/Rondas' : 'api/Rondas/${_ronda.id}';
  final Response res = isNew
      ? await ApiHelper.post(url, _ronda.toJson())
      : await ApiHelper.put(url, _ronda.toJson());

  if (!mounted) return;
  setState(() => showLoader = false);

  if (!res.isSuccess) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(res.message),
        actions: [
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    return;
  }

  // Mensaje según operación
  Fluttertoast.showToast(
    msg: isNew ? 'Ronda creada.' : 'Ronda actualizada.',
    gravity: ToastGravity.CENTER,
    backgroundColor: kPcontrastMoradoColor,
    textColor: Colors.white,
  );

  // Sincronizar estado local con backend (solo si hay JSON útil)
  // OJO: PUT podría venir vacío (204). POST podría venir con el objeto nuevo.
  final body = res.result?.toString().trim() ?? '';
  if (body.isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (!mounted) return;
      setState(() {
        _ronda = Ronda.fromJson(decoded);
        _ronda.calcularYAsignarPosiciones();
      });
    } catch (_) {
      // Si no es JSON, mejor no romper. Puedes hacer un refresh si necesitas.
      // await _goRefresh();  // <- opcional
    }
  } else {
    // PUT típico 204: si quieres, refresca desde el backend
    // await _goRefresh();  // <- opcional
  }
}


/* ════════════ UTILIDAD ════════════ */
bool _isComplete() {
  // Todas las tarjetas, todos los hoyos con golpes > 0
  return _ronda.tarjetas
      .expand((t) => t.hoyos)
      .every((h) => h.golpes > 0);
}

  


 
  Future<void> _goRefresh() async {
    
   setState(() {
     showLoader = true;
   });  
   
    Response   response = await ApiHelper.getRondaById(_ronda.id);
    
    setState(() {
      showLoader=false;
    });

   
     if (!response.isSuccess) {
      if(mounted) {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content:  Text(response.message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
       }
     }

      if (mounted) {
        setState(() {
          _ronda = response.result;
           myTarjeta =  _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
            _ronda.tarjetas.sort((a, b) => a.scorePar.compareTo(b.scorePar));
        });
      }
    

  }

 

   

  void goHome() {
  if (!mounted) return;

  if (widget.ruta == 'Inicio') {
    // Vuelve al primer route (Home) sin duplicarlo
    Navigator.popUntil(context, (route) => route.isFirst);
  } else {
    // Cierra solo esta pantalla (vuelves a la anterior)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Fallback por si esta pantalla es la raíz por algún motivo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
  }
}

 Future<void> _confirmBack() async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmación'),
      content: const Text('¿Estás seguro de que deseas Salir de la ronda?'),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('Aceptar'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (confirm == true) {
    goHome();
  }
}

 

  
 bool isComplete() {  
  for (var hoyo in _ronda.tarjetas[0].hoyos) {
    if (hoyo.golpes == 0) {
      return false;
    }
  }
  return true;
}

  void _showScoreEntryDialogForPlayer(Tarjeta tarjeta) {
    
   List<int> scores = tarjeta.hoyos.map((h) => h.golpes == 0 ? h.hoyo.par : h.golpes).toList();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Para poder hacer setState dentro del diálogo usamos StatefulBuilder
      return StatefulBuilder(
        builder: (BuildContext context, setStateDialog) {
          int calcIda()   => scores.sublist(0, 9).fold(0, (a, b) => a + b);
          int calcVuelta() => scores.sublist(9).fold(0, (a, b) => a + b);
          int calcGross() => scores.fold(0, (a, b) => a + b);

          return AlertDialog(
            title: Text('Scores de ${tarjeta.jugador!.nombre}'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                   Text(
                    'Ida  ${calcIda()}  Vta: ${calcVuelta()}  Gross: ${calcGross()}',
                    style: kTextStyleNegroRobotoSize20,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: ListView.builder(
                      itemCount: tarjeta.hoyos.length,
                      itemBuilder: (context, index) {
                        final estadistica = tarjeta.hoyos[index];
                        return Card(
                          color: const Color.fromARGB(117, 255, 255, 255),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Info del hoyo
                                Expanded(
                                  child: Text(
                                    'Hoyo ${estadistica.hoyo.numero} Par:${estadistica.hoyo.par}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Botón para bajar el score
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.redAccent,
                                      onPressed: () {
                                        setStateDialog(() {
                                          if (scores[index] > 1) {
                                            scores[index]--;
                                             
                                          }
                                        });
                                      },
                                    ),
                                    // Muestra el valor actual
                                    Text(
                                      scores[index].toString(),
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                    // Botón para subir el score
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.green,
                                      onPressed: () {
                                        setStateDialog(() {
                                          scores[index]++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Actualiza los golpes en la tarjeta
                   for (int i = 0; i < tarjeta.hoyos.length; i++) {
                    final estadisticaHoyo = tarjeta.hoyos[i];
                    estadisticaHoyo.golpes = scores[i];

                   
                   
                  }

                  // 3. Actualizamos el estado de la tarjeta
                  // Updating the state of the tarjeta here ensures that the UI reflects the changes made to the scores.
                  setState(() {
                    
                    _ronda.calcularYAsignarPosiciones();
                    _ronda.calcularFedeAmigos();
                  });

                  Navigator.of(context).pop();

                  // Si quieres, llama a tu _goUpdateRonda() para reflejar los cambios
                 // _goUpdateRonda();

                  // Sarcasmo de confirmación:
                  Fluttertoast.showToast(
                    msg: "El jugador ${tarjeta.jugador!.nombre} registró sus golpes. ",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}

}