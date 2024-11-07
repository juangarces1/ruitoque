import 'package:flutter/material.dart';
import 'package:ruitoque/Components/app_bar_custom.dart';
import 'package:ruitoque/Helpers/api_helper.dart';
import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/response.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final Function(List<Jugador>) onPlayersSelected;

  const PlayerSelectionScreen({Key? key, required this.onPlayersSelected})
      : super(key: key);

  @override
  PlayerSelectionScreenState createState() => PlayerSelectionScreenState();
}

class PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<Jugador> _players = [];
  final List<Jugador> _selectedPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    Response response = await ApiHelper.getPlayers();
    if (response.isSuccess) {
      setState(() {
        _players = response.result;
        _isLoading = false;
      });
    } else {
      // Handle error
    }
  }

  void _onPlayerSelected(bool selected, Jugador player) {
    setState(() {
      if (selected) {
        _selectedPlayers.add(player);
      } else {
        _selectedPlayers.remove(player);
      }
    });
  }

  void _onConfirm() {
    if (_selectedPlayers.isNotEmpty) {
      widget.onPlayersSelected(_selectedPlayers);
      Navigator.pop(context);
    } else {
      // Show message to select at least one player
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title:'Seleccione un Jugador',
          automaticallyImplyLeading: true,   
          backgroundColor: const Color.fromARGB(255, 41, 18, 45),
          elevation: 8.0,
          shadowColor: Colors.blueGrey,
          foreColor: Colors.white,
          actions: [ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(
                    'assets/LogoGolf.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ), // Ícono de perfil de usuario
              ),
          ],
        
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _players.map((player) {
                return CheckboxListTile(
                  title: Text(player.nombre),
                  value: _selectedPlayers.contains(player),
                  onChanged: (bool? selected) {
                    _onPlayerSelected(selected ?? false, player);
                  },
                );
              }).toList(),
            ),
    );
  }
}
