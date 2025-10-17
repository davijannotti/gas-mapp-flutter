import 'package:flutter/material.dart';

class GasStationMarker extends StatelessWidget {
  final VoidCallback onTap;

  const GasStationMarker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.local_gas_station,
        color: Colors.blue,
        size: 40,
      ),
    );
  }
}
