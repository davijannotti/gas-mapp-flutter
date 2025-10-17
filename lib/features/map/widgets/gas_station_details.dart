import 'package:flutter/material.dart';
import '../../../core/models/gas_station.dart';

class GasStationDetails extends StatelessWidget {
  final GasStation gasStation;
  final VoidCallback onAddPrice;
  final VoidCallback onTakePhoto;

  const GasStationDetails({
    super.key,
    required this.gasStation,
    required this.onAddPrice,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gasStation.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (gasStation.fuel.isEmpty)
            const Text('No price information available.')
          else
            ...gasStation.fuel.map((fuel) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fuel.name, style: const TextStyle(fontSize: 16)),
                    Text('\$${fuel.price.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddPrice,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Price'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
