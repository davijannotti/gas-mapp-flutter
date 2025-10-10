
import 'package:latlong2/latlong.dart';

class GasStation {
  final String name;
  final LatLng location;
  final Map<String, double> prices;

  GasStation({
    required this.name,
    required this.location,
    required this.prices,
  });
}
