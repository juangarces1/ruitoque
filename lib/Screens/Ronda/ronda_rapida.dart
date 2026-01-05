import 'dart:async';
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
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/fede_amigos.dart';
import 'package:ruitoque/Models/hoyo.dart';
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
    _ronda = widget.ronda;
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    // Usa tienePermisosEdicion() para soportar RondaDeAmigos (responsableId)
    isCreator = _ronda.tienePermisosEdicion(jugador.id);
    myTarjeta = _ronda.tarjetas.firstWhere((t) => t.jugadorId == jugador.id);
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
            SpeedDialChild(
              label: 'Agregar jugador',
              backgroundColor: Colors.green,
              child: const Icon(Icons.person_add_alt_1),
              onTap: _handleAddPlayer,
            ),

            SpeedDialChild(
              label: 'Eliminar jugador',
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.person_remove_alt_1),
              onTap: _selectPlayerToDelete,
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

  Future<void> _selectPlayerToDelete() async {
  final Tarjeta? elegido = await showModalBottomSheet<Tarjeta>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, ctrl) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const Text('Selecciona jugador a eliminar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const Divider(color: Colors.white12, height: 24),
                Expanded(
                  child: ListView.separated(
                    controller: ctrl,
                    itemCount: _ronda.tarjetas.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (_, i) {
                      final t = _ronda.tarjetas[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPcontrastMoradoColor, foregroundColor: Colors.white,
                          child: Text(t.jugador!.nombre.isNotEmpty ? t.jugador!.nombre[0] : '?'),
                        ),
                        title: Text(t.jugador!.nombre, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Hcp: ${t.handicapPlayer}',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        onTap: () => Navigator.pop(context, t),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );

  if (elegido != null) {
    await _confirmDeletePlayer(elegido);
  }
}

Future<void> _confirmDeletePlayer(Tarjeta t) async {
  // Permisos básicos: el creador puede eliminar a cualquiera; los demás, solo su propia tarjeta
  final bool puedeEliminar = isCreator || t.jugadorId == jugador.id;
  if (!puedeEliminar) {
    Fluttertoast.showToast(
      msg: 'Solo el creador puede eliminar a otros jugadores.',
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    return;
  }

  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar jugador'),
      content: Text('¿Deseas eliminar a "${t.jugador?.nombre ?? 'jugador'}" de la ronda?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Eliminar')),
      ],
    ),
  );

  if (ok != true) return;

  await _removeTarjeta(t);
}

Future<void> _removeTarjeta(Tarjeta t) async {
  // (Opcional) Llamada a tu API. Deja una de estas rutas según tu backend:
  // final res = await ApiHelper.post('api/Rondas/${_ronda.id}/EliminarJugador', {'jugadorId': t.jugadorId});
  // final res = await ApiHelper.delete('api/Rondas/${_ronda.id}/Jugadores/${t.jugadorId}');
  // if (!res.isSuccess) {
  //   if (!mounted) return;
  //   showDialog(context: context, builder: (_) => AlertDialog(
  //     title: const Text('Error'),
  //     content: Text(res.message),
  //     actions: [ TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')) ],
  //   ));
  //   return;
  // }

  if (!mounted) return;
  setState(() {
    _ronda.tarjetas.removeWhere((x) => x.jugadorId == t.jugadorId);

    // re-seleccionar myTarjeta si quitaste la tuya
    final bool meElimine = t.jugadorId == jugador.id;
    if (meElimine) {
      final Tarjeta propia = _ronda.tarjetas.firstWhere(
        (x) => x.jugadorId == jugador.id, orElse: () => _ronda.tarjetas.isNotEmpty ? _ronda.tarjetas.first : t);
      if (_ronda.tarjetas.isNotEmpty) {
        myTarjeta = propia;
      }
    }

    // Recalcular orden, posiciones, FedeAmigos
    if (_ronda.tarjetas.isNotEmpty) {
      _ronda.calcularYAsignarPosiciones();
      if (fedeAmigosCalculado) _ronda.calcularFedeAmigos();
    }
  });

  // Si no queda nadie… volvemos a Home (o lo que prefieras)
  if (_ronda.tarjetas.isEmpty) {
    Fluttertoast.showToast(
      msg: 'No quedan jugadores en la ronda. Saliendo…',
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    if (mounted) goHome();
    return;
  }

  Fluttertoast.showToast(
    msg: 'Jugador eliminado.',
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
  );
}



 Future<void> _showHandicapDialogForPlayer(Tarjeta tarjeta) async {
  final int? nuevoHcp = await _handicapDialog(context, tarjeta);

  if (nuevoHcp != null && mounted) {
    setState(() {
      tarjeta.actualizarHandicapJugador(nuevoHcp); 
        _ronda.calcularYAsignarPosiciones();    // ordena posiciones, etc.
       _ronda.calcularFedeAmigos();
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
                'Pts: ${entry.value.toStringAsFixed(2)}    --    \$${_miles.format((entry.value * (1500 * widget.ronda.tarjetas.length)).round())}',  
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

  void _showScoreEntryDialogForPlayer(Tarjeta tarjeta) {
  // 1) Inicial: si un hoyo está en 0, propón el par
    List<int> scores = tarjeta.hoyos
        .map((h) => h.golpes == 0 ? h.hoyo.par : h.golpes)
        .toList();

    // Rango permitido (ajústalo si quieres)
    const int minGolpes = 1;
    const int maxGolpes = 12;

    int mitad() => (tarjeta.hoyos.length / 2).floor();
    int calcIda()   => scores.take(mitad()).fold(0, (a, b) => a + b);
    int calcVuelta() => (tarjeta.hoyos.length > mitad())
        ? scores.skip(mitad()).fold(0, (a, b) => a + b)
        : 0;
    int calcGross() => scores.fold(0, (a, b) => a + b);

    bool hayInvalido() => scores.any((s) => s < minGolpes || s > maxGolpes);

    // ====== PALETA DARK ======
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const surface2 = Color(0xFF232323);
    const outline = Color(0xFF2E2E2E);
    const onBg = Color(0xFFEAEAEA);
    const onBgDim = Color(0xFFBDBDBD);
    const accentGreen = Color(0xFF25D366);
    const accentRed = Color(0xFFFF5A5F);
    const accentNeutral = Color(0xFF9E9E9E);

    Future<void> editarNumeroDirecto(int index) async {
      final controller = TextEditingController(text: scores[index].toString());
      final int? nuevo = await showDialog<int>(
        context: context,
        builder: (_) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: onBg,
                  surface: surface,
                  onSurface: onBg,
                ), dialogTheme: const DialogThemeData(backgroundColor: surface),
          ),
          child: AlertDialog(
            title: Text(
              'Golpes Hoyo ${tarjeta.hoyos[index].hoyo.numero}',
              style: const TextStyle(color: onBg, fontWeight: FontWeight.w700),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: onBg),
              decoration: const InputDecoration(
                hintText: 'Ingresa golpes',
                hintStyle: TextStyle(color: onBgDim),
                filled: true,
                fillColor: surface2,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: onBg),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: onBgDim),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: onBg,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  final v = int.tryParse(controller.text.trim());
                  if (v != null) Navigator.pop(context, v);
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ),
      );

      if (nuevo != null) {
        setState(() {}); // para que no marque warning con mounted
        scores[index] = nuevo.clamp(minGolpes, maxGolpes);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setStateSheet) {
                Widget totalesHeader() {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                      border: const Border(bottom: BorderSide(color: outline)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          'Golpes de ${tarjeta.jugador?.nombre ?? ''}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: onBg),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _MiniTotal(label: 'Ida', value: calcIda()),
                            _MiniTotal(label: 'Vta', value: calcVuelta()),
                            _MiniTotal(label: 'Gross', value: calcGross()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: outline),
                      ],
                    ),
                  );
                }

                Widget itemHoyo(int index) {
                  final est = tarjeta.hoyos[index];
                  final par = est.hoyo.par;
                  final val = scores[index];
                  int vsPar = val - par;

                  Color chipTone() {
                    if (vsPar < 0) return accentGreen;
                    if (vsPar == 0) return accentNeutral;
                    return accentRed;
                  }

                  void setVal(int v) {
                    setStateSheet(() {
                      scores[index] = v.clamp(minGolpes, maxGolpes);
                    });
                  }

                  final presets = <int>{
                    (par - 1).clamp(minGolpes, maxGolpes),
                    par.clamp(minGolpes, maxGolpes),
                    (par + 1).clamp(minGolpes, maxGolpes),
                    (par + 2).clamp(minGolpes, maxGolpes),
                    (par + 3).clamp(minGolpes, maxGolpes),
                  }.toList();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: surface2,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Hoyo ${est.hoyo.numero}  •  Par $par',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: onBg,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: chipTone().withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: chipTone().withOpacity(0.5)),
                                ),
                                child: Text(
                                  vsPar == 0 ? 'E' : (vsPar > 0 ? '+$vsPar' : '$vsPar'),
                                  style: TextStyle(
                                    color: chipTone(),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onLongPress: () => setVal(val - 2),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: accentRed,
                                  onPressed: () => setVal(val - 1),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => editarNumeroDirecto(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  child: Text(
                                    '$val',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: onBg,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onLongPress: () => setVal(val + 2),
                                child: IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  color: accentGreen,
                                  onPressed: () => setVal(val + 1),
                                ),
                              ),
                            ],
                          ),

                          Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 8,
                              children: presets.map((p) {
                                final selected = p == val;
                                return ChoiceChip(
                                  label: Text(
                                    p.toString(),
                                    style: TextStyle(
                                      color: selected ? Colors.black : onBg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  selected: selected,
                                  backgroundColor: surface,
                                  selectedColor: onBg,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: selected ? onBg : outline,
                                    ),
                                  ),
                                  onSelected: (_) => setVal(p),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        totalesHeader(),
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: tarjeta.hoyos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 2),
                            itemBuilder: (_, i) => itemHoyo(i),
                          ),
                        ),
                        const Divider(height: 1, color: outline),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: onBg,
                                    side: const BorderSide(color: outline),
                                    backgroundColor: surface,
                                  ),
                                  child: const Text('Cerrar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: onBg,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: hayInvalido()
                                      ? null
                                      : () {
                                          for (int i = 0; i < tarjeta.hoyos.length; i++) {
                                            tarjeta.hoyos[i].golpes = scores[i];
                                          }
                                          if (mounted) {
                                            setState(() {
                                              _ronda.calcularYAsignarPosiciones();
                                              _ronda.calcularFedeAmigos();
                                            });
                                          }
                                          Navigator.pop(context);

                                          Fluttertoast.showToast(
                                            msg: "El jugador ${tarjeta.jugador?.nombre ?? ''} registró sus golpes.",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.black87,
                                            textColor: Colors.white,
                                          );
                                        },
                                  child: const Text('Guardar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

Future<void> _handleAddPlayer() async {
  final PlayerChoiceResult? r = await _openAddOrPickPlayerSheet();
  if (r == null) return;

  // 1) Crear/normalizar Jugador a partir de la elección
  final Jugador jugadorItem = _ensureJugadorFromChoice(r);

  // Evitar duplicados por jugadorId en la ronda:
  final yaExiste = _ronda.tarjetas.any((t) => t.jugadorId == jugadorItem.id);
  if (yaExiste) {
    Fluttertoast.showToast(
      msg: 'El jugador "${jugadorItem.nombre}" ya está en la ronda.',
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    return;
  }

  // 2) Construir Tarjeta basándonos en la tarjeta[0] (o en el campo)
  final Tarjeta nueva = _buildTarjetaFromTemplate(jugadorItem);

  // 3) Agregar, recalcular y notificar
  setState(() {
    _ronda.tarjetas.add(nueva);
    _ronda.calcularYAsignarPosiciones();
    if (fedeAmigosCalculado) _ronda.calcularFedeAmigos();
  });

  Fluttertoast.showToast(
    msg: r.esInvitado
        ? 'Invitado ${jugadorItem.nombre} agregado (hcp ${jugadorItem.handicap ?? 0}).'
        : 'Jugador ${jugadorItem.nombre} agregado (id ${jugadorItem.id}, hcp ${jugadorItem.handicap ?? 0}).',
    gravity: ToastGravity.CENTER,
    backgroundColor: kPcontrastMoradoColor,
    textColor: Colors.white,
  );
}

/// Crea un Jugador a partir del PlayerChoiceResult.
/// - Invitado: le genero un id negativo temporal para evitar choques.
/// - API: uso id/nombre/hcp que vinieron del modal.
Jugador _ensureJugadorFromChoice(PlayerChoiceResult r) {
  final int id = r.id ?? -(DateTime.now().microsecondsSinceEpoch % 1000000);
  // Ajusta a tu constructor real de Jugador si requiere más campos.
  return Jugador(
    id: id,
    nombre: r.nombre,
    handicap: r.handicap,
    pin: 0
    // agrega campos opcionales si tu modelo los tiene (email, foto, etc.)
  );
}

/// Construye una Tarjeta clonando la estructura de hoyos de la tarjeta[0].
/// Si no hay tarjetas, usa los hoyos del campo de la ronda.
/// Inicializa todas las estadísticas en 0, copia tee/campo de la plantilla.
Tarjeta _buildTarjetaFromTemplate(Jugador jugadorItem) {
  // Plantilla: tarjeta[0] si existe
  final Tarjeta? plantilla = _ronda.tarjetas.isNotEmpty ? _ronda.tarjetas.first : null;

  // Campo y tee
  final campo = plantilla?.campo ?? _ronda.campo;
  final tee   = plantilla?.teeSalida; // si tu modelo lo exige, ajusta aquí

  // % handicap: copiamos de la plantilla si existe, si no usa 100
  final int handicapPctPlantilla = (plantilla?.hoyos.isNotEmpty == true)
      ? (plantilla!.hoyos.first.handicapPorcentaje ?? 100)
      : 100;

  final Tarjeta tarjeta = Tarjeta(
    id: 0,
    rondaId: _ronda.id,
    jugadorId: jugadorItem.id,
    jugador: jugadorItem,
    handicapPlayer: jugadorItem.handicap ?? 0,
    hoyos: [],
    campo: campo,
    teeSalida: tee, // si es requerido; si no, elimínalo
  );

  // Fuente de hoyos a clonar:
  final List<dynamic> fuenteHoyos = (plantilla != null && plantilla.hoyos.isNotEmpty)
      ? plantilla.hoyos.map((e) => e.hoyo).toList()
      : (campo.hoyos);

  for (final dynamic h in fuenteHoyos) {
    // h es Hoyo (de tu modelo)
    final Hoyo hoyo = h as Hoyo;

    final EstadisticaHoyo aux = EstadisticaHoyo(
      id: 0,
      hoyo: hoyo,
      hoyoId: hoyo.id,
      golpes: 0,
      putts: 0,
      bunkerShots: 0,
      acertoFairway: false,
      falloFairwayIzquierda: false,
      falloFairwayDerecha: false,
      penaltyShots: 0,
      shots: const [],
      handicapPlayer: jugadorItem.handicap ?? 0,
      nombreJugador: jugadorItem.nombre,
      isMain: jugadorItem.id == jugador.id, // "jugador" es el actual (logueado) en tu State
      handicapPorcentaje: handicapPctPlantilla,
    );

    tarjeta.hoyos.add(aux);
  }

  return tarjeta;
}

Future<PlayerChoiceResult?> _openAddOrPickPlayerSheet() async {
  // Paleta dark
  const bg = Color(0xFF121212);
  const surface = Color(0xFF1E1E1E);
  const surface2 = Color(0xFF232323);
  const outline = Color(0xFF2E2E2E);
  const onBg = Color(0xFFEAEAEA);
  const onBgDim = Color(0xFFBDBDBD);
  const accentGreen = Color(0xFF25D366);

  // Estado Invitado
  final nameCtrl = TextEditingController();
  int hcpInv = 0;

  // Estado Buscar
  final searchCtrl = TextEditingController();
  List<Jugador> items = [];
  bool loading = false;
  String lastError = '';
  Timer? debounce;

  // Control inicial de pestaña
  bool listenerAttached = false;
  bool firstFetchDone = false;

  Future<void> loadJugadores({
    required void Function(void Function()) setStateSheet,
    String q = '',
  }) async {
    setStateSheet(() {
      loading = true;
      lastError = '';
    });

    try {
      final Response res = await ApiHelper.getPlayers(); // SIEMPRE lista

      if (!res.isSuccess || res.result is! List) {
        setStateSheet(() {
          lastError = res.message.isNotEmpty ? res.message : 'Respuesta no es una lista';
          items = [];
        });
        return;
      }

      final List<Jugador> all = (res.result as List).cast<Jugador>();

      final term = q.trim().toLowerCase();
      final List<Jugador> filtered = term.isEmpty
          ? all
          : all.where((j) {
              final nombre = (j.nombre).toLowerCase();
              return nombre.contains(term) || '${j.id}'.contains(term);
            }).toList();

      setStateSheet(() => items = filtered);
    } catch (err) {
      setStateSheet(() {
        lastError = err.toString();
        items = [];
      });
    } finally {
      setStateSheet(() => loading = false);
    }
  }

  void onSearchChanged(String v, void Function(void Function()) setStateSheet) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () async {
      await loadJugadores(setStateSheet: setStateSheet, q: v);
    });
  }

  final result = await showModalBottomSheet<PlayerChoiceResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DefaultTabController(
        length: 2,
        child: DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setStateSheet) {
                // Adjuntar listener al TabController UNA sola vez
                if (!listenerAttached) {
                  listenerAttached = true;
                  final tabCtrl = DefaultTabController.of(context);
                  // Si abre ya en "Buscar", dispara una vez
                  if (tabCtrl.index == 1 && !firstFetchDone) {
                    scheduleMicrotask(() async {
                      await loadJugadores(setStateSheet: setStateSheet, q: '');
                      firstFetchDone = true;
                    });
                  }
                  tabCtrl.addListener(() async {
                    if (tabCtrl.index == 1 && !firstFetchDone) {
                      await loadJugadores(setStateSheet: setStateSheet, q: '');
                      firstFetchDone = true;
                    }
                  });
                                }

                Widget header() {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: const BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Column(
                      children: [
                        SizedBox(height: 6),
                        _GripBar(),
                        SizedBox(height: 8),
                        Text('Agregar jugador',
                            style: TextStyle(color: onBg, fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        TabBar(
                          indicatorColor: onBg,
                          labelColor: onBg,
                          unselectedLabelColor: onBgDim,
                          tabs: [
                            Tab(text: 'Invitado'),
                            Tab(text: 'Buscar en lista'),
                          ],
                        ),
                        Divider(height: 1, color: outline),
                      ],
                    ),
                  );
                }

                Widget invitadoTab() {
                  final nombreValido =
                      nameCtrl.text.trim().isNotEmpty && nameCtrl.text.trim().length >= 2;

                  void setHcp(int v) {
                    setStateSheet(() => hcpInv = v.clamp(-10, 54));
                  }

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      TextField(
                        controller: nameCtrl,
                        autofocus: true,
                        style: const TextStyle(color: onBg),
                        // AQUÍ: solo refrescamos validación local, no buscamos en API
                        onChanged: (_) => setStateSheet(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Nombre del jugador',
                          labelStyle: TextStyle(color: onBgDim),
                          hintText: 'Ej: Juan Pérez',
                          hintStyle: TextStyle(color: onBgDim),
                          filled: true,
                          fillColor: surface2,
                          border: OutlineInputBorder(borderSide: BorderSide(color: outline)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: outline)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: onBg)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hándicap', style: TextStyle(color: onBgDim, fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () => setHcp(hcpInv - 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$hcpInv',
                                    style: const TextStyle(
                                      color: onBg, fontSize: 28, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: accentGreen),
                                  onPressed: () => setHcp(hcpInv + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: onBg,
                                side: const BorderSide(color: outline),
                                backgroundColor: surface,
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: nombreValido
                                  ? () {
                                      Navigator.pop(
                                        context,
                                        PlayerChoiceResult(
                                          id: null,
                                          nombre: nameCtrl.text.trim(),
                                          handicap: hcpInv,
                                          esInvitado: true,
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onBg,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: outline,
                                disabledForegroundColor: onBgDim,
                              ),
                              child: const Text('Crear invitado'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                Widget buscarTab() {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: searchCtrl,
                          style: const TextStyle(color: onBg),
                          onChanged: (v) => onSearchChanged(v, setStateSheet),
                          decoration: const InputDecoration(
                            labelText: 'Buscar jugador',
                            labelStyle: TextStyle(color: onBgDim),
                            hintText: 'Nombre...',
                            hintStyle: TextStyle(color: onBgDim),
                            prefixIcon: Icon(Icons.search, color: onBgDim),
                            filled: true,
                            fillColor: surface2,
                            border: OutlineInputBorder(borderSide: BorderSide(color: outline)),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: outline)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: onBg)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : lastError.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text('Error: $lastError',
                                        style: const TextStyle(color: Colors.redAccent)),
                                  )
                                : items.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('Sin resultados.',
                                            style: TextStyle(color: onBgDim)),
                                      )
                                    : ListView.separated(
                                        controller: scrollController,
                                        itemCount: items.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1, color: outline),
                                        itemBuilder: (_, i) {
                                          final j = items[i];
                                          final inicial = j.nombre.isNotEmpty ? j.nombre[0] : '?';
                                          final hcp = j.handicap ?? 0;
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: kPcontrastMoradoColor,
                                              foregroundColor: Colors.white,
                                              child: Text(inicial),
                                            ),
                                            title: Text(j.nombre,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: onBg, fontWeight: FontWeight.w600)),
                                            subtitle: Text('Hcp: $hcp',
                                                style: const TextStyle(color: onBgDim)),
                                            trailing: const Icon(Icons.person_add_alt_1, color: onBg),
                                            onTap: () {
                                              Navigator.pop(
                                                context,
                                                PlayerChoiceResult(
                                                  id: j.id,
                                                  nombre: j.nombre,
                                                  handicap: hcp,
                                                  esInvitado: false,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              await loadJugadores(setStateSheet: setStateSheet, q: searchCtrl.text.trim());
                            },
                            icon: const Icon(Icons.refresh, color: onBgDim, size: 18),
                            label: const Text('Actualizar', style: TextStyle(color: onBgDim)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        header(),
                        // SIN hacks: hijos directos (se reconstruyen bien)
                        Expanded(
                          child: TabBarView(
                            children: [
                              invitadoTab(),
                              buscarTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );

  // Limpieza del debounce
  debounce?.cancel();
  return result;
}

}
class _MiniTotal extends StatelessWidget {
  final String label;
  final int value;
  const _MiniTotal({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const onBg = Color(0xFFEAEAEA);
    const onBgDim = Color(0xFFBDBDBD);

    return Column(
      children: [
        Text(label, style: const TextStyle(color: onBgDim, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(color: onBg, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    );
  }
}


class PlayerChoiceResult {
  final int? id;           // null si es invitado local
  final String nombre;
  final int handicap;
  final bool esInvitado;
  const PlayerChoiceResult({
    required this.id,
    required this.nombre,
    required this.handicap,
    required this.esInvitado,
  });
}

class _GripBar extends StatelessWidget {
  const _GripBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Hack elegante para pasar los 2 trees a TabBarView sin complicar el StatefulBuilder
class _TabHolder extends StatelessWidget {
  final Widget Function(BuildContext) childBuilder;
  const _TabHolder({required this.childBuilder});

  static Widget invitadoBuilder(BuildContext context) =>
      (context.findAncestorWidgetOfExactType<_InjectedTabs>()!).invited;

  static Widget buscarBuilder(BuildContext context) =>
      (context.findAncestorWidgetOfExactType<_InjectedTabs>()!).search;

  @override
  Widget build(BuildContext context) => childBuilder(context);
}

class _InjectedTabs extends InheritedWidget {
  final Widget invited;
  final Widget search;
  const _InjectedTabs({
    required this.invited,
    required this.search,
    required Widget child,
    super.key,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant _InjectedTabs oldWidget) =>
      invited != oldWidget.invited || search != oldWidget.search;
}

extension _InjectTabsExt on Widget {
  Widget _injectTabs(Widget invited, Widget search) =>
      _InjectedTabs(invited: invited, search: search, child: this);
}
