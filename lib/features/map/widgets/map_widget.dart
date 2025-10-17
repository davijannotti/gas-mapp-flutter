import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/gas_station.dart';
import 'gas_station_marker.dart';

class MapWidget extends StatelessWidget {
  final LatLng initialCenter;
  final MapController mapController;
  final List<GasStation> gasStations;
  final Function(GasStation) onStationTapped;

  const MapWidget({
    super.key,
    required this.initialCenter,
    required this.mapController,
    this.gasStations = const [],
    required this.onStationTapped,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gas_mapp.app',
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors', onTap: null),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: initialCenter,
              child: const Column(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 40),
                  Text(
                    'You are here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            ...gasStations.map((station) {
              return Marker(
                width: 40,
                height: 40,
                point: LatLng(station.latitude, station.longitude),
                child: GasStationMarker(
                  onTap: () => onStationTapped(station),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
