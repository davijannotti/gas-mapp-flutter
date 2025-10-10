import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../models/gas_station.dart';
import '../widgets/gas_station_details.dart';
import '../widgets/gas_station_marker.dart';
import '../widgets/map_widget.dart';
import '../widgets/search_bar.dart';
import '../widgets/side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocationData? _currentLocation;
  late final MapController _mapController;
  bool _isLoading = true;
  bool _permissionDenied = false;
  String? _errorMessage;
  final List<GasStation> _gasStations = [];
  int _stationCounter = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _permissionDenied = false;
        _errorMessage = null;
      });
    }

    if (kIsWeb) {
      await _getLocationByIp();
    } else {
      await _getDeviceLocation();
    }
  }

  Future<void> _getLocationByIp() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _currentLocation = LocationData.fromMap({
              'latitude': data['latitude'],
              'longitude': data['longitude'],
            });
            _isLoading = false;
          });
        }
      } else {
        _showError("Não foi possível obter a localização a partir do IP.");
      }
    } catch (e) {
      _showError("Erro ao obter a localização: $e");
    }
  }

  Future<void> _getDeviceLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showError("O serviço de localização está desativado.");
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _isLoading = false;
          });
        }
        return;
      }
    }

    try {
      final currentLocation = await location.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError("Erro ao obter a localização do dispositivo: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  void _addGasStation(LatLng point) {
    setState(() {
      _stationCounter++;
      _gasStations.add(
        GasStation(
          name: 'Posto de Gasolina $_stationCounter',
          location: point,
          prices: {'Gasolina': 5.59, 'Etanol': 3.69},
        ),
      );
    });
  }

  void _showGasStationDetails(GasStation station) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GasStationDetails(gasStation: station),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GasMapp'),
        backgroundColor: Colors.teal,
      ),
      drawer: const SideBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Buscando sua localização..."),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A permissão de localização foi negada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Por favor, habilite a permissão de localização para que o app possa mostrar sua posição no mapa.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text('Conceder Permissão'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentLocation == null) {
      return const Center(
        child: Text("Não foi possível obter sua localização."),
      );
    }

    return Stack(
      children: [
        MapWidget(
          initialCenter: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          mapController: _mapController,
          gasStations: _gasStations,
          onStationTapped: _showGasStationDetails,
          onLongPress: _addGasStation,
        ),
        const SearchBar(),
        Positioned(
          bottom: 30,
          right: 15,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'closest_station',
                backgroundColor: Colors.teal,
                onPressed: () {
                  // TODO: Implement find closest gas station
                },
                child: const Icon(Icons.local_gas_station, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'cheapest_station',
                backgroundColor: Colors.teal,
                onPressed: () {
                  // TODO: Implement find closest-cheapest gas station
                },
                child: const Icon(Icons.attach_money, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
