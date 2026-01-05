import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_par5_provider.dart';
import 'package:ruitoque/Screens/Mapas/Components/golf_map_style_type.dart';

class MapaPar5 extends StatelessWidget {
  final String teeSalida;
  final EstadisticaHoyo hoyo;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  const MapaPar5({
    super.key,
    required this.hoyo,
    required this.teeSalida,
    required this.onAgregarShot,
    required this.onDeleteShot,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: ValueKey('par5_hoyo_${hoyo.id}'),
      create: (_) => MiMapaPar5Provider(
        hoyo: hoyo,
        teeSalida: teeSalida,
        onAgregarShot: onAgregarShot,
        onDeleteShot: onDeleteShot,
      ),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              Consumer<MiMapaPar5Provider>(
                builder: (context, provider, _) {
                  return GoogleMap(
                    // ✅ NUEVO: key para forzar rebuild cuando cambia estilo
                    key: ValueKey(provider.currentStyle),
                    
                    mapType: MapType.satellite,
                    buildingsEnabled: false,
                    trafficEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    
                    // ✅ ACTUALIZADO: Usar 'style' en lugar de setMapStyle
                    style: provider.getCurrentStyleString(),
                    
                    initialCameraPosition: CameraPosition(
                      target: provider.puntoC,
                      zoom: 17.5,
                      bearing: provider.bearing,
                    ),
                    polylines: provider.polylines,
                    markers: provider.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) {
                      provider.setMapController(controller);
                    },
                    onCameraMove: (_) => provider.onCameraMove(),
                    onCameraIdle: provider.onCameraIdle,
                  );
                },
              ),
              const _GreenDistances(),
              const _Par5Badges(),
              _HeaderPar5(hoyo: hoyo),
              const _RefreshDistancesButton(),
              const _StylePickerButton(),
            ],
          ),
          floatingActionButton: const _GrabarGolpePar5Button(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

class _StylePickerButton extends StatelessWidget {
  const _StylePickerButton();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaPar5Provider>(context, listen: false);
    return Positioned(
      top: 70,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FloatingActionButton.small(
          heroTag: 'Par5Style',
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 6,
          onPressed: () => _showStylePicker(context, provider),
          child: const Icon(Icons.layers, color: Colors.white),
        ),
      ),
    );
  }

  void _showStylePicker(BuildContext context, MiMapaPar5Provider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estilo del Mapa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _StyleOption(
                icon: '🎯',
                title: 'Minimalista',
                subtitle: 'Vista limpia, solo lo esencial',
                isSelected: provider.currentStyle == GolfMapStyleType.minimalist,
                onTap: () {
                  provider.changeMapStyle(GolfMapStyleType.minimalist);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _StyleOption(
                icon: '✨',
                title: 'Ultra Limpio',
                subtitle: 'Solo césped y agua',
                isSelected: provider.currentStyle == GolfMapStyleType.ultraClean,
                onTap: () {
                  provider.changeMapStyle(GolfMapStyleType.ultraClean);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _StyleOption(
                icon: '🏌️',
                title: 'Profesional',
                subtitle: 'Con caminos de golf cart',
                isSelected: provider.currentStyle == GolfMapStyleType.professional,
                onTap: () {
                  provider.changeMapStyle(GolfMapStyleType.professional);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _StyleOption(
                icon: '🌙',
                title: 'Modo Nocturno',
                subtitle: 'Para rondas al atardecer',
                isSelected: provider.currentStyle == GolfMapStyleType.night,
                onTap: () {
                  provider.changeMapStyle(GolfMapStyleType.night);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _StyleOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[700] : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _RefreshDistancesButton extends StatelessWidget {
  const _RefreshDistancesButton();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaPar5Provider>(context, listen: false);
    return Positioned(
      top: 12,
      right: 12,
      child: SafeArea(
        bottom: false,
        child: FloatingActionButton.small(
          heroTag: 'Par5Refresh',
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 6,
          onPressed: provider.calculateDistancesToGreen,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}

class _GreenDistances extends StatelessWidget {
  const _GreenDistances();

  @override
  Widget build(BuildContext context) {
    return Consumer<MiMapaPar5Provider>(
      builder: (context, provider, _) {
        return Positioned(
          top: MediaQuery.of(context).size.height / 2 - 80,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.025),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Fondo',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${provider.dAtras ?? 0}y',
                  style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Centro',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${provider.dCentro ?? 0}y',
                  style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Frente',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${provider.dfrente ?? 0}y',
                  style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Par5Badges extends StatelessWidget {
  const _Par5Badges();

  @override
  Widget build(BuildContext context) {
    return Consumer<MiMapaPar5Provider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            _DistanceBadge(
              offset: provider.offsetTramo1,
              label: '${provider.dTramo1}y',
            ),
            _DistanceBadge(
              offset: provider.offsetTramo2,
              label: '${provider.dTramo2}y',
            ),
            _DistanceBadge(
              offset: provider.offsetTramo3,
              label: '${provider.dTramo3}y',
            ),
          ],
        );
      },
    );
  }
}

class _HeaderPar5 extends StatelessWidget {
  final EstadisticaHoyo hoyo;

  const _HeaderPar5({required this.hoyo});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Consumer<MiMapaPar5Provider>(
                      builder: (_, provider, __) {
                        final total = provider.dTramo1 +
                            provider.dTramo2 +
                            provider.dTramo3;
                        return Text(
                          '${hoyo.hoyo.nombre} | Par ${hoyo.hoyo.par} | ${total}y',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'RobotoCondensed',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrabarGolpePar5Button extends StatelessWidget {
  const _GrabarGolpePar5Button();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MiMapaPar5Provider>(context, listen: false);
    return GestureDetector(
      onLongPress: () => provider.mostrarModalDeDistancias(context),
      child: FloatingActionButton(
        heroTag: 'Par5GG',
        onPressed: provider.grabarGolpe,
        backgroundColor: Colors.black.withOpacity(0.75),
        elevation: 8,
        child: const Center(
          child: Text(
            'GG',
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  final Offset offset;
  final String label;

  const _DistanceBadge({
    required this.offset,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx - 22,
      top: offset.dy - 22,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}