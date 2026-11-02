
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';

class AddEditProductDialog extends StatefulWidget {
  final void Function(String name, double price) onSubmit;

  final String? initialName;
  final double? initialPrice;
  final bool isEditing;

  const AddEditProductDialog({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialPrice,
    this.isEditing = false,
  });

  @override
  State<AddEditProductDialog> createState() =>
      _AddEditProductDialogState();
}

class _AddEditProductDialogState
    extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName ?? '',
    );

    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());

    widget.onSubmit(name, price);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        widget.isEditing ? 'Edit Product' : 'Add New Product',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price Per Carton',
                prefixIcon: Icon(Icons.sell_outlined),
                suffixText: 'EGP',
              ),
              validator: (value) {
                final price = double.tryParse(value ?? '');

                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }

                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(
            widget.isEditing ? 'Save Changes' : 'Add Product',
          ),
        ),
      ],
    );
  }
}
