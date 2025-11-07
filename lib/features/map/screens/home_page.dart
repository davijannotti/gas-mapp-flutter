import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide SearchBar;
import '../../../core/models/client.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../../../core/models/fuel.dart';
import '../../../core/models/gas_station.dart';
import '../../../core/models/price.dart';
import '../../../core/services/gas_station_service.dart';
import '../../../core/services/price_service.dart';
import '../../../core/services/fuel_service.dart';
import '../widgets/gas_station_details.dart';
import '../widgets/map_widget.dart';
import '../widgets/price_form_modal.dart';
import '../widgets/search_bar.dart';
import '../widgets/side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GasStationService _gasStationService = GasStationService();
  final PriceService _priceService = PriceService();
  final FuelService _fuelService = FuelService();

  final ValueNotifier<List<GasStation>> _gasStationsNotifier = ValueNotifier([]);

  LocationData? _currentLocation;
  late final MapController _mapController;
  bool _isLoading = true;
  bool _permissionDenied = false;
  String? _errorMessage;
  GasStation? _currentlyDisplayedStation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _gasStationsNotifier.dispose();
    super.dispose();
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
    }
    else {
      await _getDeviceLocation();
    }
  }

  Future<void> _fetchNearbyStations(LatLng location) async {
    try {
      final stations = await _gasStationService.getNearbyStations(
        location.latitude,
        location.longitude,
      );
      if (mounted) {
        _gasStationsNotifier.value = [...stations]; // 👈 cria uma nova lista e força o rebuild
      }
    } catch (e) {
      _showError("Could not fetch nearby stations: $e");
    }
  }

  Future<void> _getLocationByIp() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          final location = LatLng(data['latitude'], data['longitude']);
          setState(() {
            _currentLocation = LocationData.fromMap({
              'latitude': location.latitude,
              'longitude': location.longitude,
            });
            _isLoading = false;
          });
          await _fetchNearbyStations(location);
        }
      }
      else {
        _showError("Could not get location from IP address.");
      }
    } catch (e) {
      _showError("Error getting location: $e");
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
        _showError("Location service is disabled.");
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
        final location = LatLng(currentLocation.latitude!, currentLocation.longitude!); 
        setState(() {
          _currentLocation = currentLocation;
          _isLoading = false;
        });
        await _fetchNearbyStations(location);
      }
    } catch (e) {
      _showError("Error getting device location: $e");
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

  Future<void> _showAddPriceForm(GasStation station) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PriceFormModal(
        stationId: station.id!,
        onSubmit: (int stationId, String fuelName, double priceValue) async {
          try {
            var client = Client(id: 1);

            Fuel? fuel = await _fuelService.getFuelByName(station, fuelName);
            if (fuel == null) {
              final newFuel = Fuel(
                gasStation: station,
                name: fuelName.toUpperCase(),
              );
              fuel = await _fuelService.createFuel(newFuel);
            }

            final completeFuel = Fuel(
              id: fuel.id,
              name: fuel.name,
              gasStation: station,
              date: fuel.date,
              price: fuel.price,
            );

            await _priceService.createPrice(
              fuel: completeFuel,
              client: client,
              priceValue: priceValue,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Price added successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            if (_currentLocation != null) {
              await _fetchNearbyStations(
                LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              );
            }
            Navigator.of(context).pop(); // 👈 fecha o formulário só depois do refresh
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding price: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }


  Future<void> _handlePhotoUpload(int stationId) async {
    var status = await permission_handler.Permission.camera.status;

    if (!status.isGranted) {
      status = await permission_handler.Permission.camera.request();
    }

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading photo...')),
        );
        try {
          // TODO: implementar uploadPhoto no serviço
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully! (DEMO)'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Permission'),
            content: const Text(
                'Camera permission is permanently denied. Please go to app settings to enable it.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  permission_handler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take a photo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGasStationDetails(GasStation station) {
    setState(() {
      _currentlyDisplayedStation = station; // Set the currently displayed station
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ValueListenableBuilder<List<GasStation>>(
          valueListenable: _gasStationsNotifier,
          builder: (context, gasStations, _) {
            // Busca o posto atualizado
            final updatedStation = gasStations.firstWhere(
                  (s) => s.id == station.id,
              orElse: () => station,
            );

            return GasStationDetails(
              gasStation: updatedStation,
              onAddPrice: () async {
                await _showAddPriceForm(updatedStation);
              },
              onTakePhoto: () => _handlePhotoUpload(updatedStation.id!),
            );
          },
        );
      },
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
            Text("Getting your location..."),
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
                child: const Text('Try Again'),
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
                'Location permission has been denied.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enable location permission to allow the app to show your position on the map.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeLocation,
                child: const Text('Grant Permission'),
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
        ValueListenableBuilder<List<GasStation>>(
          valueListenable: _gasStationsNotifier,
          builder: (context, gasStations, _) {
            return MapWidget(
              initialCenter: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              mapController: _mapController,
              gasStations: gasStations,
              onStationTapped: (station) => _showGasStationDetails(station),
            );
          },
        ),
        ValueListenableBuilder<List<GasStation>>(
          valueListenable: _gasStationsNotifier,
          builder: (context, gasStations, _ ){
            return SearchBar(
              stations: gasStations,
              onStationSelected: (station) {
                if (station.latitude != null && station.longitude != null) {
                  _mapController.move(
                    LatLng(station.latitude!, station.longitude!),
                    15.0,
                  );
                }
                _showGasStationDetails(station);
              },
            );
          }
        ),
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
