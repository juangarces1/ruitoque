import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Components/tarjeta_fondo_oscuro.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';
import 'package:ruitoque/Models/tarjeta.dart';
import 'package:ruitoque/constans.dart';

/// Pantalla para visualizar TODOS los jugadores de TODOS los grupos
/// de una RondaDeAmigos. Solo lectura.
class VerRondaAmigosScreen extends StatefulWidget {
  final RondaDeAmigos rondaDeAmigos;

  const VerRondaAmigosScreen({
    super.key,
    required this.rondaDeAmigos,
  });

  @override
  State<VerRondaAmigosScreen> createState() => _VerRondaAmigosScreenState();
}

class _VerRondaAmigosScreenState extends State<VerRondaAmigosScreen> {
  bool showLoader = false;
  late RondaDeAmigos _rondaDeAmigos;
  late Jugador jugador;

  // Lista combinada de todas las tarjetas de todos los grupos
  List<_TarjetaConGrupo> _todasLasTarjetas = [];

  @override
  void initState() {
    super.initState();
    _rondaDeAmigos = widget.rondaDeAmigos;
    jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    _combinarTarjetas();
  }

  /// Combina todas las tarjetas de todos los grupos en una sola lista
  void _combinarTarjetas() {
    _todasLasTarjetas = [];

    for (var grupo in _rondaDeAmigos.rondas) {
      // Calcular posiciones dentro de cada grupo
      grupo.calcularYAsignarPosiciones();

      for (var tarjeta in grupo.tarjetas) {
        _todasLasTarjetas.add(_TarjetaConGrupo(
          tarjeta: tarjeta,
          numeroGrupo: grupo.numeroGrupo ?? 0,
          ronda: grupo,
        ));
      }
    }

    // Ordenar por score (mejor a peor)
    _todasLasTarjetas.sort((a, b) => a.tarjeta.scorePar.compareTo(b.tarjeta.scorePar));
  }

  Future<void> _goRefresh() async {
    setState(() => showLoader = true);

    Response response = await ApiHelper.getRondaDeAmigosById(_rondaDeAmigos.id);

    setState(() => showLoader = false);

    if (!response.isSuccess) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(response.message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _rondaDeAmigos = response.result;
        _combinarTarjetas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
          child: Column(
            children: [
              // ───── HEADER ─────
              _buildHeader(),
              const SizedBox(height: 12),
              // ───── CUERPO SCROLLEABLE ─────
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // ---------- INFO GENERAL ----------
                        SliverToBoxAdapter(
                          child: _buildInfoCard(),
                        ),

                        // ---------- CLASIFICACIÓN GENERAL ----------
                        SliverToBoxAdapter(
                          child: _buildClasificacionHeader(),
                        ),

                        // ---------- TARJETAS DE TODOS LOS JUGADORES ----------
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _todasLasTarjetas[index];
                              return _buildTarjetaItem(item);
                            },
                            childCount: _todasLasTarjetas.length,
                          ),
                        ),

                        // Espacio final
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),

                    // ---------- LOADER ----------
                    if (showLoader)
                      const Positioned.fill(
                        child: MyLoader(opacity: 1, text: 'Actualizando...'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: kPprimaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Atrás
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rondaDeAmigos.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _rondaDeAmigos.campo?.nombre ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Botón Refrescar
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _goRefresh,
          ),

          // Logo
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
    );
  }

  Widget _buildInfoCard() {
    final fecha = _rondaDeAmigos.fecha;
    final fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';
    final totalJugadores = _todasLasTarjetas.length;
    final totalGrupos = _rondaDeAmigos.rondas.length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today, fechaStr),
          _buildInfoItem(Icons.groups, '$totalGrupos grupos'),
          _buildInfoItem(Icons.person, '$totalJugadores jugadores'),
          _buildInfoItem(Icons.percent, '${_rondaDeAmigos.handicapPorcentaje}% Hcp'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildClasificacionHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.leaderboard, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            'Clasificación General',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaItem(_TarjetaConGrupo item) {
    final tarjeta = item.tarjeta;
    final posicion = _todasLasTarjetas.indexOf(item) + 1;

    // Colores para las medallas (top 3)
    Color? medalColor;
    if (posicion == 1) medalColor = Colors.amber;
    if (posicion == 2) medalColor = Colors.grey[400];
    if (posicion == 3) medalColor = Colors.brown[300];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: medalColor ?? Colors.white.withOpacity(0.1),
          width: medalColor != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con posición y grupo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: medalColor?.withOpacity(0.2) ?? Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                // Posición
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: medalColor ?? kPprimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$posicion',
                      style: TextStyle(
                        color: medalColor != null ? Colors.white : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nombre del jugador
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarjeta.jugador?.nombre ?? 'Jugador',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Grupo ${item.numeroGrupo} • Hcp: ${tarjeta.handicapPlayer}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score
                _buildScoreDisplay(tarjeta),
              ],
            ),
          ),

          // Detalle de scores
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem('Ida', tarjeta.parIda),
                _buildScoreItem('Vuelta', tarjeta.parVuelta),
                _buildScoreItem('Gross', tarjeta.puntuacionTotal),
                _buildScoreItem('Neto', tarjeta.totalNeto),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(Tarjeta tarjeta) {
    final scorePar = tarjeta.scorePar;
    Color scoreColor;
    String scoreStr;

    if (scorePar < 0) {
      scoreColor = Colors.red;
      scoreStr = '$scorePar';
    } else if (scorePar > 0) {
      scoreColor = Colors.blue;
      scoreStr = '+$scorePar';
    } else {
      scoreColor = Colors.white;
      scoreStr = 'E';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scoreColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            scoreStr,
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            tarjeta.puntuacionTotal > 0 ? '${tarjeta.puntuacionTotal}' : '-',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value > 0 ? '$value' : '-',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// Clase auxiliar para mantener la relación tarjeta-grupo
class _TarjetaConGrupo {
  final Tarjeta tarjeta;
  final int numeroGrupo;
  final Ronda ronda;

  _TarjetaConGrupo({
    required this.tarjeta,
    required this.numeroGrupo,
    required this.ronda,
  });
}
