import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/gas_station.dart';
import 'gas_station_marker.dart';

class MapWidget extends StatelessWidget {
  final LatLng initialCenter;
  final MapController mapController;
  final List<GasStation> gasStations;

  const MapWidget({
    super.key,
    required this.initialCenter,
    required this.mapController,
    required this.gasStations,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 15.0,
        onLongPress: (tapPosition, point) => onLongPress(point),
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
            ...gasStations.map(
                (station) => Marker(
                    width: 80,
                    height: 80,
                    point: LatLng(station.latitude, station.longitude),
                    child: Column(
                      children: [
                        const Icon(Icons.local_gas_station, color: Colors.greenAccent, size: 30),
                        Text(
                          station.name,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                ),
            ),
          ],
        ),
      ],
    );
  }
}
