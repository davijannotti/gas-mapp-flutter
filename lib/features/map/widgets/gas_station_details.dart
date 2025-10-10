import 'package:flutter/material.dart';
import '../models/gas_station.dart';

class GasStationDetails extends StatelessWidget {
  final GasStation gasStation;

  const GasStationDetails({
    super.key,
    required this.gasStation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gasStation.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Exibe os preços dos combustíveis
          ...gasStation.prices.entries.map((entry) {
            return Text('${entry.key}: R\$ ${entry.value.toStringAsFixed(2)}');
          }).toList(),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar adicionar preço
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Adicionar Preço'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar tirar foto
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar Foto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
