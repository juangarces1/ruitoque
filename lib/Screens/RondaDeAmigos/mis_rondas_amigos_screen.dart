import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Components/my_loader.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/Providers/jugadorprovider.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';
import 'package:ruitoque/Models/ronda_de_amigos.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/crear_ronda_amigos_screen.dart';
import 'package:ruitoque/Screens/RondaDeAmigos/detalle_ronda_amigos_screen.dart';
import 'package:ruitoque/constans.dart';

class MisRondasDeAmigosScreen extends StatefulWidget {
  const MisRondasDeAmigosScreen({Key? key}) : super(key: key);

  @override
  State<MisRondasDeAmigosScreen> createState() => _MisRondasDeAmigosScreenState();
}

class _MisRondasDeAmigosScreenState extends State<MisRondasDeAmigosScreen> {
  List<RondaDeAmigos> _rondasDeAmigos = [];
  bool _showLoader = false;
  late Jugador _jugador;

  @override
  void initState() {
    super.initState();
    _jugador = Provider.of<JugadorProvider>(context, listen: false).jugador;
    _cargarRondasDeAmigos();
  }

  Future<void> _cargarRondasDeAmigos() async {
    setState(() => _showLoader = true);

    Response response = await ApiHelper.getRondasDeAmigosByPlayer(_jugador.id);

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _rondasDeAmigos = response.result;
        } else {
          _rondasDeAmigos = [];
        }
        _showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          title: 'Mis Rondas de Amigos',
          elevation: 4,
          shadowColor: Colors.red,
          automaticallyImplyLeading: true,
          foreColor: Colors.white,
          backgroundColor: kPprimaryColor,
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
          child: _showLoader
              ? const Center(child: MyLoader(opacity: 0.8, text: 'Cargando...'))
              : _rondasDeAmigos.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CrearRondaDeAmigosScreen()),
            );
            if (result == true) {
              _cargarRondasDeAmigos();
            }
          },
          backgroundColor: kPprimaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nueva', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes Rondas de Amigos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una desde el menú principal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _cargarRondasDeAmigos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rondasDeAmigos.length,
        itemBuilder: (context, index) {
          final rondaDeAmigos = _rondasDeAmigos[index];
          return _buildRondaDeAmigosCard(rondaDeAmigos);
        },
      ),
    );
  }

  Widget _buildRondaDeAmigosCard(RondaDeAmigos rondaDeAmigos) {
    final fecha = rondaDeAmigos.fecha;
    final fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';
    final esCreador = rondaDeAmigos.creatorId == _jugador.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleRondaDeAmigosScreen(rondaDeAmigos: rondaDeAmigos),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: esCreador
                    ? Colors.amber.withOpacity(0.2)
                    : kPprimaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPprimaryColor,
                    child: const Icon(Icons.groups, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rondaDeAmigos.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          fechaStr,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (esCreador)
                    const Chip(
                      label: Text('Organizador', style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.amber,
                    ),
                  if (rondaDeAmigos.todosGruposCompletos)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(Icons.golf_course, rondaDeAmigos.campo?.nombre ?? 'Campo'),
                  _buildInfoChip(Icons.groups, '${rondaDeAmigos.cantidadGrupos} grupos'),
                  _buildInfoChip(Icons.person, '${rondaDeAmigos.cantidadJugadores} jugadores'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
