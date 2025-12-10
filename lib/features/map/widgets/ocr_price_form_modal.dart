import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/client.dart';
import '../../../core/models/fuel.dart';
import 'package:flutter_app/core/services/auth_service.dart';
import '../../../core/models/gas_station.dart';
import '../../../core/services/fuel_service.dart';
import '../../../core/services/price_service.dart';

class OcrPriceFormModal extends StatefulWidget {
  final GasStation gasStation;
  final List<dynamic> ocrResults;
  final Function onSubmitted;

  const OcrPriceFormModal({
    super.key,
    required this.gasStation,
    required this.ocrResults,
    required this.onSubmitted,
  });

  @override
  State<OcrPriceFormModal> createState() => _OcrPriceFormModalState();
}

class _OcrPriceFormModalState extends State<OcrPriceFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _priceService = PriceService();
  final _fuelService = FuelService();
  final _authService = AuthService();

  late final Map<String, TextEditingController> _priceControllers;

  @override
  void initState() {
    super.initState();
    _priceControllers = {
      for (var result in widget.ocrResults)
        result['combustivel'] as String:
            TextEditingController(text: (double.parse(result['preco'])).toStringAsFixed(2))
    };
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando preços...')),
      );

      try {
        final client = await _authService.getMe();
        for (var entry in _priceControllers.entries) {
          final fuelName = entry.key;
          final priceValue = double.tryParse(entry.value.text.replaceAll(',', '.'));

          if (priceValue != null) {
            Fuel? fuel = await _fuelService.getFuelByName(widget.gasStation, fuelName);
            if (fuel == null) {
              final newFuel = Fuel(
                gasStation: widget.gasStation,
                name: fuelName.toUpperCase(),
              );
              fuel = await _fuelService.createFuel(newFuel);
            }

            final completeFuel = Fuel(
              id: fuel.id,
              name: fuel.name,
              gasStation: widget.gasStation,
              date: fuel.date,
              price: fuel.price,
            );

            await _priceService.createPrice(
              fuel: completeFuel,
              client: client,
              priceValue: priceValue,
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preços adicionados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSubmitted();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar preços: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preços Sugeridos (OCR)',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ..._priceControllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    prefixText: 'R\$ ',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+[,.]?\d{0,3}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um preço';
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Por favor, insira um número válido';
                    }
                    return null;
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enviar Preços'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
