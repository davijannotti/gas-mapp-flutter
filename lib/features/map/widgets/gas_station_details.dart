import 'package:flutter/material.dart';
import '../../../core/models/gas_station.dart';
import '../../../core/models/fuel.dart'; // Import the correct Fuel model

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
    // A wrapper to give the bottom sheet rounded corners and a background color.
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gasStation.name ?? "Posto Sem Nome",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Use the 'fuel' property from your GasStation model
            if (gasStation.fuel?.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No price information available.'),
              )
            else
            // Iterate through the list of 'fuel' objects
              ...(gasStation.fuel ?? []).map((fuel) {
                // Safely access the price value from the Price object
                final double? priceValue = fuel.price?.price;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Access the name from the 'fuel' object
                      Text(fuel.name, style: const TextStyle(fontSize: 16)),
                      // Access the price from the 'fuel' object
                      Text(
                        // Display the price or 'N/A' if null
                        'R\$ ${priceValue?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
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
            // Added safe area padding for the bottom.
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
