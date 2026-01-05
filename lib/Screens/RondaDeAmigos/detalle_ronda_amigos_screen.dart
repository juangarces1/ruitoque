import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';
import 'package:ruitoque/Screens/Ronda/mi_ronda_screen.dart';
import 'package:ruitoque/Screens/Ronda/ronda_rapida.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/ver_ronda_amigos_screen.dart';
import 'package:ruitoque/constans.dart';

class DetalleRondaDeAmigosScreen extends StatefulWidget {
  final RondaDeAmigos rondaDeAmigos;

  const DetalleRondaDeAmigosScreen({
    Key? key,
    required this.rondaDeAmigos,
  }) : super(key: key);

  @override
  State<DetalleRondaDeAmigosScreen> createState() => _DetalleRondaDeAmigosScreenState();
}

class _DetalleRondaDeAmigosScreenState extends State<DetalleRondaDeAmigosScreen> {
  bool showLoader = false;
  late RondaDeAmigos rondaDeAmigos;
  late Jugador jugadorActual;
  List<Jugador> todosLosJugadores = [];

  @override
  void initState() {
    super.initState();
    rondaDeAmigos = widget.rondaDeAmigos;
    jugadorActual = Provider.of<JugadorProvider>(context, listen: false).jugador;
    _cargarJugadores();
  }

  Future<void> _cargarJugadores() async {
    Response response = await ApiHelper.getPlayers();
    if (response.isSuccess) {
      setState(() {
        todosLosJugadores = response.result;
      });
    }
  }

  String _obtenerNombreJugador(int? jugadorId) {
    if (jugadorId == null) return 'Sin asignar';
    try {
      return todosLosJugadores
          .firstWhere((j) => j.id == jugadorId)
          .nombre;
    } catch (e) {
      // Buscar en las tarjetas de los grupos
      for (var grupo in rondaDeAmigos.rondas) {
        for (var tarjeta in grupo.tarjetas) {
          if (tarjeta.jugadorId == jugadorId) {
            return tarjeta.jugador?.nombre ?? 'Jugador #$jugadorId';
          }
        }
      }
      return 'Jugador #$jugadorId';
    }
  }

  bool _esResponsableDeGrupo(Ronda grupo) {
    return grupo.responsableId == jugadorActual.id;
  }

  bool _esCreadorDelEvento() {
    return rondaDeAmigos.creatorId == jugadorActual.id;
  }

  void _navegarAGrupo(Ronda grupo) {
    // Navegar a RondaRapida para jugar el grupo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiRonda(ronda: grupo, ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: rondaDeAmigos.nombre,
        automaticallyImplyLeading: true,
        backgroundColor: kPprimaryColor,
        elevation: 4.0,
        shadowColor: const Color.fromARGB(255, 2, 44, 68),
        foreColor: Colors.white,
        actions: [
          if (_esCreadorDelEvento())
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // TODO: Opciones de administrador
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Recargar datos del servidor
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Info del evento
            _buildInfoHeader(),

            // Botón Ver Ronda (solo para el creador)
            if (_esCreadorDelEvento())
              _buildVerRondaButton(),

            // Resumen de posiciones (si hay datos)
            if (rondaDeAmigos.rondas.any((g) => g.tarjetas.any((t) => t.puntuacionTotal > 0)))
              _buildResumenGeneral(),

            // Lista de grupos
            _buildGruposList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    final fecha = rondaDeAmigos.fecha;
    final fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rondaDeAmigos.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaStr,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildEstadoChip(),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.golf_course, 'Campo', rondaDeAmigos.campo?.nombre ?? ''),
          _buildInfoRow(Icons.flag, 'Tee', rondaDeAmigos.teeSeleccionado),
          _buildInfoRow(Icons.percent, 'Handicap', '${rondaDeAmigos.handicapPorcentaje}%'),
          _buildInfoRow(Icons.groups, 'Grupos', '${rondaDeAmigos.rondas.length}'),
          _buildInfoRow(Icons.person, 'Jugadores', '${rondaDeAmigos.cantidadJugadores}'),
        ],
      ),
    );
  }

  Widget _buildEstadoChip() {
    final completado = rondaDeAmigos.todosGruposCompletos;
    return Chip(
      label: Text(
        completado ? 'Finalizado' : 'En progreso',
        style: TextStyle(
          color: completado ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
      backgroundColor: completado ? Colors.green : Colors.amber,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVerRondaButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerRondaAmigosScreen(
                rondaDeAmigos: rondaDeAmigos,
              ),
            ),
          );
        },
        icon: const Icon(Icons.visibility, color: Colors.white),
        label: const Text(
          'Ver Ronda Completa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPprimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildResumenGeneral() {
    // Obtener todos los jugadores de todos los grupos con sus scores
    List<Map<String, dynamic>> todosLosScores = [];

    for (var grupo in rondaDeAmigos.rondas) {
      for (var tarjeta in grupo.tarjetas) {
        if (tarjeta.puntuacionTotal > 0) {
          todosLosScores.add({
            'nombre': tarjeta.jugador?.nombre ?? 'Jugador',
            'grupo': grupo.numeroGrupo,
            'gross': tarjeta.puntuacionTotal,
            'neto': tarjeta.totalNeto,
            'scorePar': tarjeta.scorePar,
          });
        }
      }
    }

    // Ordenar por score neto
    todosLosScores.sort((a, b) => (a['neto'] as int).compareTo(b['neto'] as int));

    if (todosLosScores.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Clasificación General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...todosLosScores.take(5).map((score) {
            final index = todosLosScores.indexOf(score);
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: index == 0
                    ? Colors.amber
                    : index == 1
                        ? Colors.grey[400]
                        : index == 2
                            ? Colors.brown[300]
                            : Colors.grey[200],
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: index < 3 ? Colors.white : Colors.black,
                  ),
                ),
              ),
              title: Text(score['nombre']),
              subtitle: Text('Grupo ${score['grupo']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Neto: ${score['neto']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Gross: ${score['gross']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGruposList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Grupos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...rondaDeAmigos.rondas.map((grupo) => _buildGrupoCard(grupo)),
      ],
    );
  }

  Widget _buildGrupoCard(Ronda grupo) {
    final esResponsable = _esResponsableDeGrupo(grupo);
    final responsableNombre = _obtenerNombreJugador(grupo.responsableId);

    // Calcular líder del grupo
    String lider = '';
    if (grupo.tarjetas.any((t) => t.puntuacionTotal > 0)) {
      grupo.calcularYAsignarPosiciones();
      final tarjetasOrdenadas = List<dynamic>.from(grupo.tarjetas)
        ..sort((a, b) => a.scorePar.compareTo(b.scorePar));
      if (tarjetasOrdenadas.isNotEmpty) {
        lider = tarjetasOrdenadas.first.jugador?.nombre ?? '';
      }
    }

    return GestureDetector(
      onTap: () => _navegarAGrupo(grupo), // Ahora cualquiera puede ver cualquier grupo
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: esResponsable
              ? Border.all(color: Colors.amber, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: esResponsable
                    ? Colors.amber.withOpacity(0.2)
                    : kPprimaryColor.withOpacity(0.1),
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
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Responsable: $responsableNombre',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (esResponsable)
                    const Chip(
                      label: Text('Tu grupo', style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.amber,
                    ),
                  if (grupo.isComplete)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),

            // Jugadores
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...grupo.tarjetas.map((tarjeta) {
                    final esLider = tarjeta.jugador?.nombre == lider && lider.isNotEmpty;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: esLider ? Colors.amber : Colors.grey[300],
                        child: Text(
                          tarjeta.jugador?.nombre.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: esLider ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        tarjeta.jugador?.nombre ?? 'Jugador',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: tarjeta.puntuacionTotal > 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  tarjeta.scoreParString,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tarjeta.scorePar < 0
                                        ? Colors.red
                                        : tarjeta.scorePar > 0
                                            ? Colors.blue
                                            : Colors.black,
                                  ),
                                ),
                                Text(
                                  '${tarjeta.puntuacionTotal} (${tarjeta.totalNeto})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Hcp: ${tarjeta.handicapPlayer}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                    );
                  }),
                ],
              ),
            ),

            // Botón para entrar al grupo
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _navegarAGrupo(grupo),
                icon: Icon(esResponsable ? Icons.edit : Icons.visibility),
                label: Text(esResponsable
                    ? (grupo.isComplete ? 'Ver mi grupo' : 'Editar mi grupo')
                    : 'Ver grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: esResponsable ? kPprimaryColor : Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
