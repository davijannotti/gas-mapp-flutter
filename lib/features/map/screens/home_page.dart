import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../../../core/models/gas_station.dart';
import '../../../core/models/price.dart';
import '../../../core/services/gas_station_service.dart';
import '../../../core/services/price_service.dart';
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
  LocationData? _currentLocation;
  late final MapController _mapController;
  bool _isLoading = true;
  bool _permissionDenied = false;
  String? _errorMessage;
  List<GasStation> _gasStations = [];

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

  Future<void> _fetchNearbyStations(LatLng location) async {
    try {
      final stations = await _gasStationService.getNearbyStations(
        location.latitude,
        location.longitude,
      );
      if (mounted) {
        setState(() {
          _gasStations = stations;
        });
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
      } else {
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

  void _showAddPriceForm(GasStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make modal background transparent
      builder: (context) => PriceFormModal(
        stationId: station.id!, // Use the non-nullable ID here.
        onSubmit: (int stationId, String fuelName, double priceValue) async {
          try {
            // TODO: Replace 'clientId: 1' with the actual ID of the logged-in user.
            await _priceService.createPrice(
              gasStationId: stationId,
              fuelName: fuelName,
              clientId: 1, // Using 1 as a placeholder for the logged-in user's ID
              priceValue: priceValue,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Price added successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Refresh station data to show the new price
            if (_currentLocation != null) {
              await _fetchNearbyStations(LatLng(
                  _currentLocation!.latitude!, _currentLocation!.longitude!));
            }
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

    // If permission is not granted, request it.
    if (!status.isGranted) {
      status = await permission_handler.Permission.camera.request();
    }

    if (status.isGranted) {
      // Permission is granted, proceed to pick image.
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading photo...')),
        );
        try {
          // TODO: The 'uploadPricePhoto' method is not available in the provided services.
          // This needs to be implemented in one of the service files by your friend.
          // await _gasStationService.uploadPricePhoto(stationId, image.path);
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
      // The user permanently denied the permission, show a dialog to open settings.
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Permission'),
            content: const Text('Camera permission is permanently denied. Please go to app settings to enable it.'),
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
      // The user denied the permission, show a snackbar.
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
    showModalBottomSheet(
      context: context,
      builder: (context) => GasStationDetails(
        gasStation: station,
        onAddPrice: () {
          Navigator.of(context).pop();
          _showAddPriceForm(station);
        },
        onTakePhoto: () {
          Navigator.of(context).pop();
          _handlePhotoUpload(station.id!);
        },
      ),
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
        child: Text("Could not get your location."),
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
