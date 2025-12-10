import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide SearchBar;
import '../../../core/models/client.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_app/core/services/auth_service.dart';
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
import '../../../core/services/photo_service.dart';
import '../../../core/services/evaluation_service.dart';
import '../../../core/models/evaluation.dart';
import '../widgets/gas_station_details.dart';
import '../widgets/map_widget.dart';
import '../widgets/price_form_modal.dart';
import '../widgets/ocr_price_form_modal.dart';
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
  final PhotoService _photoService = PhotoService();
  final AuthService _authService = AuthService();
  final EvaluationService _evaluationService = EvaluationService();

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
      _showError("Não foi possível buscar postos próximos: $e");
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
        _showError("Não foi possível obter a localização a partir do endereço IP.");
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
        final location = LatLng(currentLocation.latitude!, currentLocation.longitude!); 
        setState(() {
          _currentLocation = currentLocation;
          _isLoading = false;
        });
        await _fetchNearbyStations(location);
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

  Future<void> _findCheapestGasStation() async {
    if (_currentLocation == null) {
      _showError("Não foi possível obter sua localização para encontrar o posto de gasolina mais barato.");
      return;
    }

    final String? selectedFuel = await _showFuelSelectionDialog();

    if (selectedFuel != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buscando o posto mais barato...'),
            duration: Duration(seconds: 2),
          ),
        );

        final stations = await _gasStationService.getGasStationCheapest(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          selectedFuel,
        );

        if (mounted) {
          if (stations.isNotEmpty) {
            final cheapestStation = stations.first;

            final stationExists = _gasStationsNotifier.value.any((s) => s.id == cheapestStation.id);

            if (!stationExists) {
              _gasStationsNotifier.value = [..._gasStationsNotifier.value, cheapestStation];
            }

            _mapController.move(
              LatLng(cheapestStation.latitude!, cheapestStation.longitude!),
              15.0,
            );

            _showGasStationDetails(cheapestStation);

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nenhum posto de gasolina encontrado para o tipo de combustível selecionado.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        _showError("Não foi possível buscar os postos de gasolina mais baratos: $e");
      }
    }
  }

  Future<String?> _showFuelSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione o Tipo de Combustível'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Using the same list from PriceFormModal
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Gasolina'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('Gasolina');
                  },
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Etanol'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('Etanol');
                  },
                ),
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Diesel'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('Diesel');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  Future<void> _showAddPriceForm(GasStation station) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PriceFormModal(
        stationId: station.id!,
        onSubmit: (int stationId, String fuelName, double priceValue) async {
          // Optimistic update FIRST
          _updateStationOptimistically(stationId, fuelName, priceValue);
          Navigator.of(context).pop();

          try {
            final client = await _authService.getMe();

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

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preço adicionado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (_currentLocation != null) {
              await _fetchNearbyStations(
                LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              );
            }
          } catch (e) {
            debugPrint('Erro ao adicionar preço: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao adicionar preço: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              // Optionally revert optimistic update here by re-fetching
              if (_currentLocation != null) {
                 _fetchNearbyStations(
                  LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                );
              }
            }
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
          const SnackBar(content: Text('Enviando foto...')),
        );
        try {
          final ocrResults = await _photoService.uploadPhoto(File(image.path), stationId);
          debugPrint('OCR Results: $ocrResults');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto enviada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );

            if (ocrResults.isNotEmpty) {
              final GasStation station = _gasStationsNotifier.value.firstWhere((s) => s.id == stationId);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => OcrPriceFormModal(
                  gasStation: station,
                  ocrResults: ocrResults,
                  onSubmitted: (Map<String, double> prices) async {
                    // Optimistic update for each price
                    prices.forEach((fuelName, priceValue) {
                       _updateStationOptimistically(stationId, fuelName, priceValue);
                    });
                    
                    // Process API calls in background
                    try {
                      final client = await _authService.getMe();
                      for (var entry in prices.entries) {
                        final fuelName = entry.key;
                        final priceValue = entry.value;

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
                      }
                      
                      if (_currentLocation != null) {
                        await _fetchNearbyStations(LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!));
                      }
                    } catch (e) {
                      debugPrint('Erro ao salvar preços do OCR: $e');
                      if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar preços: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha no envio da foto: $e'),
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
            title: const Text('Permissão da Câmera'),
            content: const Text(
                'A permissão da câmera foi negada permanentemente. Por favor, vá para as configurações do aplicativo para habilitá-la.'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Abrir Configurações'),
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
            content: Text('A permissão da câmera é necessária para tirar uma foto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGasStationDetails(GasStation station) async {
    // Fetch trust summary
    try {
      final summary = await _evaluationService.getTrustSummaryByGasStation(station.id!);
      
      // Update station with trust summary
      final currentStations = _gasStationsNotifier.value;
      final stationIndex = currentStations.indexWhere((s) => s.id == station.id);
      
      if (stationIndex != -1) {
        final currentStation = currentStations[stationIndex];
        final List<Fuel> updatedFuels = List.from(currentStation.fuel ?? []);
        
        for (int i = 0; i < updatedFuels.length; i++) {
          final fuel = updatedFuels[i];
          if (summary.containsKey(fuel.name)) {
            updatedFuels[i] = fuel.copyWith(
              likes: summary[fuel.name]!['likes'],
              dislikes: summary[fuel.name]!['dislikes'],
            );
          }
        }
        
        final updatedStation = currentStation.copyWith(fuel: updatedFuels);
        final updatedList = List<GasStation>.from(currentStations);
        updatedList[stationIndex] = updatedStation;
        _gasStationsNotifier.value = updatedList;
      }
    } catch (e) {
      debugPrint('Error fetching trust summary: $e');
    }

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
              onEvaluate: (fuelName, isLike) => _handleEvaluation(updatedStation.id!, fuelName, isLike),
            );
          },
        );
      },
    );
  }

  void _updateStationOptimistically(int stationId, String fuelName, double priceValue) {
    final currentStations = _gasStationsNotifier.value;
    final stationIndex = currentStations.indexWhere((s) => s.id == stationId);

    if (stationIndex != -1) {
      final station = currentStations[stationIndex];
      final List<Fuel> updatedFuels = List.from(station.fuel ?? []);

      final fuelIndex = updatedFuels.indexWhere((f) => f.name.toUpperCase() == fuelName.toUpperCase());

      if (fuelIndex != -1) {
        // Update existing fuel price
        final existingFuel = updatedFuels[fuelIndex];
        updatedFuels[fuelIndex] = existingFuel.copyWith(
          price: Price(
            fuel: existingFuel,
            client: Client(id: 0, name: '', email: '', password: ''), // Dummy client
            price: priceValue,
          ),
        );
      } else {
        // Add new fuel
        final newFuel = Fuel(
          gasStation: station,
          name: fuelName.toUpperCase(),
          price: Price(
            fuel: Fuel(gasStation: station, name: fuelName.toUpperCase()), // Circular ref workaround
            client: Client(id: 0, name: '', email: '', password: ''),
            price: priceValue,
          ),
        );
        updatedFuels.add(newFuel);
      }

      final updatedStation = station.copyWith(fuel: updatedFuels);
      final updatedList = List<GasStation>.from(currentStations);
      updatedList[stationIndex] = updatedStation;

      _gasStationsNotifier.value = updatedList;

      // Update currently displayed station if it's the same
      if (_currentlyDisplayedStation?.id == stationId) {
         setState(() {
           _currentlyDisplayedStation = updatedStation;
         });
      }
    }
  }

  Future<void> _handleEvaluation(int stationId, String fuelName, bool trust) async {
    try {
      final client = await _authService.getMe();
      final currentStations = _gasStationsNotifier.value;
      final stationIndex = currentStations.indexWhere((s) => s.id == stationId);

      if (stationIndex != -1) {
        final station = currentStations[stationIndex];
        final List<Fuel> updatedFuels = List.from(station.fuel ?? []);
        final fuelIndex = updatedFuels.indexWhere((f) => f.name.toUpperCase() == fuelName.toUpperCase());

        if (fuelIndex != -1) {
          final existingFuel = updatedFuels[fuelIndex];
          
          // Optimistic update
          updatedFuels[fuelIndex] = existingFuel.copyWith(
            likes: trust ? existingFuel.likes + 1 : existingFuel.likes,
            dislikes: !trust ? existingFuel.dislikes + 1 : existingFuel.dislikes,
          );

          final updatedStation = station.copyWith(fuel: updatedFuels);
          final updatedList = List<GasStation>.from(currentStations);
          updatedList[stationIndex] = updatedStation;

          _gasStationsNotifier.value = updatedList;

          if (_currentlyDisplayedStation?.id == stationId) {
            setState(() {
              _currentlyDisplayedStation = updatedStation;
            });
          }

          // Send to backend
          if (existingFuel.price != null) {
            final evaluation = Evaluation(
              price: existingFuel.price!,
              trust: trust,
              client: client,
            );
            await _evaluationService.createEvaluation(evaluation);
          }
        }
      }
    } catch (e) {
      debugPrint('Error creating evaluation: $e');
      // Revert optimistic update if needed (omitted for simplicity)
    }
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
            Text("Obtendo sua localização..."),
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
                'Por favor, ative a permissão de localização para permitir que o aplicativo mostre sua posição no mapa.',
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
          child: FloatingActionButton(
            heroTag: 'cheapest_station',
            backgroundColor: Colors.teal,
            onPressed: _findCheapestGasStation,
            child: const Icon(Icons.attach_money, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
