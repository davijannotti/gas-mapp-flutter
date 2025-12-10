import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/gas_station.dart';
import '../../../core/models/fuel.dart'; // Importa o modelo correto de Combustível

class GasStationDetails extends StatelessWidget {
  final GasStation gasStation;
  final VoidCallback onAddPrice;
  final VoidCallback onTakePhoto;
  final Function(String fuelName, bool isLike) onEvaluate;

  const GasStationDetails({
    super.key,
    required this.gasStation,
    required this.onAddPrice,
    required this.onTakePhoto,
    required this.onEvaluate,
  });

  void _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Um wrapper para dar ao bottom sheet cantos arredondados e uma cor de fundo.
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
            // Use a propriedade 'fuel' do seu modelo GasStation
            if (gasStation.fuel?.isEmpty ?? true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Nenhuma informação de preço disponível.'),
              )
            else
            // Itera através da lista de objetos 'fuel'
              ...(gasStation.fuel ?? []).map((fuel) {
                // Acessa com segurança o valor do preço do objeto Price
                final double? priceValue = fuel.price?.price;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Acessa o nome do objeto 'fuel'
                      Text(fuel.name, style: const TextStyle(fontSize: 16)),
                      // Acessa o preço do objeto 'fuel'
                      Row(
                        children: [
                          Text(
                            // Exibe o preço ou 'N/D' se for nulo
                            'R\$ ${priceValue?.toStringAsFixed(2) ?? 'N/D'}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_outlined, size: 20),
                                onPressed: () => onEvaluate(fuel.name, true),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('${fuel.likes}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_down_outlined, size: 20),
                                onPressed: () => onEvaluate(fuel.name, false),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('${fuel.dislikes}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
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
                    label: const Text('Adicionar Preço'),
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
                    label: const Text('Tirar Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (gasStation.latitude != null && gasStation.longitude != null) {
                  _launchMaps(gasStation.latitude!, gasStation.longitude!);
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Rota'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            // Adicionado preenchimento de área segura para a parte inferior.
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
