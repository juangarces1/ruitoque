import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/default_button.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/hoyo.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/detalle_ronda_amigos_screen.dart';
import 'package:ruitoque/constans.dart';

class CrearGruposScreen extends StatefulWidget {
  final RondaDeAmigos rondaDeAmigos;

  const CrearGruposScreen({
    Key? key,
    required this.rondaDeAmigos,
  }) : super(key: key);

  @override
  State<CrearGruposScreen> createState() => _CrearGruposScreenState();
}

class _CrearGruposScreenState extends State<CrearGruposScreen> {
  bool showLoader = false;
  List<Jugador> jugadoresDisponibles = [];
  late RondaDeAmigos rondaDeAmigos;

  @override
  void initState() {
    super.initState();
    rondaDeAmigos = widget.rondaDeAmigos;
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    setState(() => showLoader = true);

    Response response = await ApiHelper.getPlayers();

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      if (mounted) {
        _showError(response.message);
      }
      return;
    }

    setState(() {
      jugadoresDisponibles = response.result;
      jugadoresDisponibles.sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _agregarGrupo() {
    // Crear nueva ronda (grupo)
    final nuevoGrupo = Ronda(
      id: 0,
      fecha: rondaDeAmigos.fecha,
      tarjetas: [],
      campo: rondaDeAmigos.campo!,
      campoId: rondaDeAmigos.campoId,
      handicapPorcentaje: rondaDeAmigos.handicapPorcentaje,
      isComplete: false,
      creatorId: rondaDeAmigos.creatorId,
      responsableId: null,
      rondaDeAmigosId: rondaDeAmigos.id,
      numeroGrupo: rondaDeAmigos.rondas.length + 1,
    );

    setState(() {
      rondaDeAmigos.rondas.add(nuevoGrupo);
    });
  }

  void _eliminarGrupo(int index) {
    setState(() {
      rondaDeAmigos.rondas.removeAt(index);
      // Re-numerar grupos
      for (int i = 0; i < rondaDeAmigos.rondas.length; i++) {
        rondaDeAmigos.rondas[i].numeroGrupo = i + 1;
      }
    });
  }

  Future<void> _seleccionarResponsable(int grupoIndex) async {
    final jugador = await _mostrarSelectorJugador(
      titulo: 'Seleccionar Responsable del Grupo ${grupoIndex + 1}',
    );

    if (jugador != null) {
      setState(() {
        rondaDeAmigos.rondas[grupoIndex].responsableId = jugador.id;
        // Si el responsable no está en las tarjetas, agregarlo
        if (!_jugadorEnGrupo(grupoIndex, jugador.id)) {
          _agregarJugadorAGrupo(grupoIndex, jugador);
        }
      });
    }
  }

  bool _jugadorEnGrupo(int grupoIndex, int jugadorId) {
    return rondaDeAmigos.rondas[grupoIndex].tarjetas
        .any((t) => t.jugadorId == jugadorId);
  }

  Future<void> _agregarJugadorAlGrupo(int grupoIndex) async {
    final jugador = await _mostrarSelectorJugador(
      titulo: 'Agregar Jugador al Grupo ${grupoIndex + 1}',
      excluirJugadores: rondaDeAmigos.rondas[grupoIndex].tarjetas
          .map((t) => t.jugadorId)
          .toList(),
    );

    if (jugador != null) {
      _agregarJugadorAGrupo(grupoIndex, jugador);
    }
  }

  void _agregarJugadorAGrupo(int grupoIndex, Jugador jugador) {
    final grupo = rondaDeAmigos.rondas[grupoIndex];

    // Crear tarjeta para el jugador
    Tarjeta tarjeta = Tarjeta(
      id: 0,
      jugadorId: jugador.id,
      rondaId: 0,
      jugador: jugador,
      handicapPlayer: jugador.handicap ?? 0,
      hoyos: [],
      campo: rondaDeAmigos.campo,
      teeSalida: rondaDeAmigos.teeSeleccionado,
    );

    // Crear estadísticas para cada hoyo
    for (Hoyo hoyo in rondaDeAmigos.campo!.hoyos) {
      EstadisticaHoyo estadistica = EstadisticaHoyo(
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
        shots: [],
        handicapPlayer: jugador.handicap,
        nombreJugador: jugador.nombre,
        handicapPorcentaje: rondaDeAmigos.handicapPorcentaje,
      );
      tarjeta.hoyos.add(estadistica);
    }

    setState(() {
      grupo.tarjetas.add(tarjeta);
    });
  }

  void _eliminarJugadorDeGrupo(int grupoIndex, int jugadorId) {
    setState(() {
      rondaDeAmigos.rondas[grupoIndex].tarjetas
          .removeWhere((t) => t.jugadorId == jugadorId);
      // Si el jugador era el responsable, limpiar responsableId
      if (rondaDeAmigos.rondas[grupoIndex].responsableId == jugadorId) {
        rondaDeAmigos.rondas[grupoIndex].responsableId = null;
      }
    });
  }

  Future<Jugador?> _mostrarSelectorJugador({
    required String titulo,
    List<int>? excluirJugadores,
  }) async {
    final jugadoresFiltrados = jugadoresDisponibles
        .where((j) => !(excluirJugadores?.contains(j.id) ?? false))
        .toList();

    return showModalBottomSheet<Jugador>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: jugadoresFiltrados.length,
                    itemBuilder: (context, index) {
                      final jugador = jugadoresFiltrados[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kPprimaryColor,
                          child: Text(
                            jugador.nombre.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(jugador.nombre),
                        subtitle: Text('Handicap: ${jugador.handicap ?? 0}'),
                        onTap: () => Navigator.pop(context, jugador),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _obtenerNombreJugador(int? jugadorId) {
    if (jugadorId == null) return 'Sin asignar';
    try {
      return jugadoresDisponibles
          .firstWhere((j) => j.id == jugadorId)
          .nombre;
    } catch (e) {
      return 'Jugador #$jugadorId';
    }
  }

  Future<void> _guardarRondaDeAmigos() async {
    // Validaciones
    if (rondaDeAmigos.rondas.isEmpty) {
      _toastError('Debe crear al menos un grupo');
      return;
    }

    for (int i = 0; i < rondaDeAmigos.rondas.length; i++) {
      final grupo = rondaDeAmigos.rondas[i];
      if (grupo.responsableId == null) {
        _toastError('El Grupo ${i + 1} no tiene responsable asignado');
        return;
      }
      if (grupo.tarjetas.isEmpty) {
        _toastError('El Grupo ${i + 1} no tiene jugadores');
        return;
      }
    }

    setState(() => showLoader = true);

    Response response = await ApiHelper.createRondaDeAmigos(rondaDeAmigos);

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      _toastError('Error al crear: ${response.message}');
      return;
    }

    // Obtener la ronda guardada con IDs del servidor
    RondaDeAmigos rondaGuardada = response.result;

    Fluttertoast.showToast(
      msg: 'Ronda de Amigos creada exitosamente',
      backgroundColor: Colors.green[700],
      textColor: Colors.white,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleRondaDeAmigosScreen(
            rondaDeAmigos: rondaGuardada,
          ),
        ),
      );
    }
  }

  void _toastError(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.red[700],
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: 'Crear Grupos',
        automaticallyImplyLeading: true,
        backgroundColor: kPprimaryColor,
        elevation: 4.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipOval(
              child: Image.asset(
                'assets/LogoGolf.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
        child: showLoader
            ? const Center(child: MyLoader(opacity: 0.8, text: 'Cargando...'))
            : _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarGrupo,
        backgroundColor: kPprimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar Grupo', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Info del evento
        _buildInfoHeader(),

        // Lista de grupos
        Expanded(
          child: rondaDeAmigos.rondas.isEmpty
              ? _buildEmptyState()
              : _buildGruposList(),
        ),

        // Botón guardar
        if (rondaDeAmigos.rondas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultButton(
              text: const Text(
                'Crear Ronda de Amigos',
                style: kTextStyleBlancoNuevaFuente20,
                textAlign: TextAlign.center,
              ),
              press: _guardarRondaDeAmigos,
              gradient: kPrimaryGradientColor,
              color: kPsecondaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rondaDeAmigos.nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.golf_course, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  rondaDeAmigos.campo?.nombre ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.flag, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Tee: ${rondaDeAmigos.teeSeleccionado} | Handicap: ${rondaDeAmigos.handicapPorcentaje}%',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.groups, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${rondaDeAmigos.rondas.length} grupos | ${rondaDeAmigos.cantidadJugadores} jugadores',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay grupos creados',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón para agregar un grupo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGruposList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rondaDeAmigos.rondas.length,
      itemBuilder: (context, index) {
        return _buildGrupoCard(index);
      },
    );
  }

  Widget _buildGrupoCard(int index) {
    final grupo = rondaDeAmigos.rondas[index];
    final responsableNombre = _obtenerNombreJugador(grupo.responsableId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del grupo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPprimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPprimaryColor,
                  child: Text(
                    '${grupo.numeroGrupo}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grupo ${grupo.numeroGrupo}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${grupo.tarjetas.length} jugadores',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarEliminarGrupo(index),
                ),
              ],
            ),
          ),

          // Responsable
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Responsable'),
            subtitle: Text(
              responsableNombre,
              style: TextStyle(
                color: grupo.responsableId == null ? Colors.red : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: TextButton(
              onPressed: () => _seleccionarResponsable(index),
              child: Text(
                grupo.responsableId == null ? 'Asignar' : 'Cambiar',
                style: const TextStyle(color: kPprimaryColor),
              ),
            ),
          ),

          const Divider(height: 1),

          // Lista de jugadores
          if (grupo.tarjetas.isNotEmpty)
            ...grupo.tarjetas.map((tarjeta) {
              final esResponsable = tarjeta.jugadorId == grupo.responsableId;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: esResponsable ? Colors.amber : Colors.grey[300],
                  child: Text(
                    tarjeta.jugador?.nombre.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      color: esResponsable ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                title: Text(tarjeta.jugador?.nombre ?? 'Jugador'),
                subtitle: Text('Handicap: ${tarjeta.handicapPlayer}'),
                trailing: esResponsable
                    ? const Chip(
                        label: Text('Responsable', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.amber,
                      )
                    : IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _eliminarJugadorDeGrupo(index, tarjeta.jugadorId),
                      ),
              );
            }),

          // Botón agregar jugador
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: grupo.tarjetas.length >= 5
                  ? null
                  : () => _agregarJugadorAlGrupo(index),
              icon: const Icon(Icons.person_add),
              label: Text(
                grupo.tarjetas.length >= 5
                    ? 'Grupo lleno (máx. 5)'
                    : 'Agregar jugador',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarGrupo(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Grupo'),
        content: Text('¿Está seguro de eliminar el Grupo ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarGrupo(index);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
