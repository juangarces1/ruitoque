import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ruitoque/Models/estadisticahoyo.dart';
import 'package:ruitoque/Models/shot.dart';
import 'package:ruitoque/Screens/Mapas/Components/distance_between_points.dart';
import 'package:ruitoque/Screens/Mapas/Components/distance_info.dart';
import 'package:ruitoque/Screens/Mapas/Components/grabar_golpe.dart';
import 'package:ruitoque/Screens/Mapas/Components/info_hole_widget.dart';
import 'package:ruitoque/Screens/Mapas/Components/loader.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_mapa_proviider.dart';
import 'package:ruitoque/Screens/Mapas/Components/refresh_button.dart';

class MiMapa extends StatelessWidget {
  final String teeSalida;
  final EstadisticaHoyo hoyo;
  final Function(int, Shot) onAgregarShot;
  final Function(int, Shot) onDeleteShot;

  const MiMapa({
    required this.hoyo,
    required this.onAgregarShot,
    required this.teeSalida,
    required this.onDeleteShot,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MiMapaProvider(
        hoyo: hoyo,
        onAgregarShot: onAgregarShot,
        teeSalida: teeSalida,
        onDeleteShot: onDeleteShot,
      ),
      builder: (context, child) {
      return Scaffold(
        body: Stack(
          children: [
            Consumer<MiMapaProvider>(
              builder: (context, provider, child) {
                return GoogleMap(
                  mapType: MapType.satellite,
                  onMapCreated: (controller) {
                    provider.setMapController(controller);
                    provider.updateScreenCoordinates();
                  },
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    bearing: provider.bearing,
                    target: provider.puntoMedio,
                    zoom: 18.5,
                  ),
                  polylines: provider.polylines,
                  markers: provider.markers,
                  onCameraIdle: provider.updateScreenCoordinates,
                );
              },
            ),
            // Additional Positioned widgets for UI elements
            const InfoHoleWidget(),
            const DistanceInfoWidget(),
            const RefreshButtonWidget(),
             const DistanceBetweenPointsWidget(),
            const LoaderWidget(),
          ],
        ),
        floatingActionButton: const GrabarGolpeButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
     );
      },
    );
  }
}