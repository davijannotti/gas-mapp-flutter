import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// The callback function expects an integer for the stationId.
typedef PriceSubmitCallback = void Function(int stationId, String fuelName, double priceValue);

class PriceFormModal extends StatefulWidget {
  // Changed stationId to be an int to match the callback and the data model.
  final int stationId;
  final PriceSubmitCallback onSubmit;
  final String? suggestedFuelName;
  final double? suggestedPriceValue;

  const PriceFormModal({
    super.key,
    required this.stationId,
    required this.onSubmit,
    this.suggestedFuelName,
    this.suggestedPriceValue,
  });

  @override
  State<PriceFormModal> createState() => _PriceFormModalState();
}

class _PriceFormModalState extends State<PriceFormModal> {
  final _formKey = GlobalKey<FormState>();
  // Renamed for clarity and consistency.
  String _selectedFuelName = 'Gasolina'; // Default value
  final _priceController = TextEditingController();

  // Renamed for clarity.
  final List<String> _fuelNames = ['Gasolina', 'Etanol', 'Diesel'];

  @override
  void initState() {
    super.initState();
    if (widget.suggestedFuelName != null) {
      final suggested = widget.suggestedFuelName!.toLowerCase();
      final foundFuel = _fuelNames.firstWhere(
        (name) => name.toLowerCase() == suggested,
        orElse: () => _selectedFuelName, // Keep default if not found
      );
      _selectedFuelName = foundFuel;
    }
    if (widget.suggestedPriceValue != null) {
      _priceController.text = widget.suggestedPriceValue!.toStringAsFixed(2);
    }
  }

  void _submitForm() {
    // Validate the form before processing.
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text);

      if (price != null) {
        // Call the callback with the correct data types.
        widget.onSubmit(widget.stationId, _selectedFuelName, price);

        // Close the modal on successful submission.
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the form in a decorated container to give it a better look and feel.
    return Container(
      // This padding ensures the content is not hidden by the keyboard.
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
            Text('Adicionar Novo Preço', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            // Fuel Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFuelName,
              items: _fuelNames.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFuelName = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de Combustível',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Price Input
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                // Using a more generic currency symbol.
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              // Using a regex that supports comma as a decimal separator.
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,3}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um preço';
                }
                // Handle both dot and comma for validation.
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Por favor, insira um número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enviar Preço'),
              ),
            ),
            const SizedBox(height: 10), // Added some padding at the bottom
          ],
        ),
      ),
    );
  }
}
