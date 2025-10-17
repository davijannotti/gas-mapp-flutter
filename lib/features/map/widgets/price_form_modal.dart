import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// A callback function to pass the submitted data back to the home page
typedef PriceSubmitCallback = void Function(String stationId, String fuelType, double price);

class PriceFormModal extends StatefulWidget {
  final String stationId;
  final PriceSubmitCallback onSubmit;

  const PriceFormModal({
    super.key,
    required this.stationId,
    required this.onSubmit,
  });

  @override
  State<PriceFormModal> createState() => _PriceFormModalState();
}

class _PriceFormModalState extends State<PriceFormModal> {
  final _formKey = GlobalKey<FormState>();
  String _selectedFuelType = 'Gasoline'; // Default value
  final _priceController = TextEditingController();

  final List<String> _fuelTypes = ['Gasoline', 'Ethanol', 'Diesel'];

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text);
      if (price != null) {
        // Call the callback with the form data
        widget.onSubmit(widget.stationId, _selectedFuelType, price);
        Navigator.of(context).pop(); // Close the modal on success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Making sure the modal doesn't get covered by the keyboard
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Price', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            // Fuel Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFuelType,
              items: _fuelTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFuelType = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Price Input
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Price'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
