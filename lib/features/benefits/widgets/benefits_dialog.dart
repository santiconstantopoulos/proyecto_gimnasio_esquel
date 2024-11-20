import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/benefit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddBenefitDialog extends StatefulWidget {
  const AddBenefitDialog({Key? key}) : super(key: key);

  @override
  _AddBenefitDialogState createState() => _AddBenefitDialogState();
}

class _AddBenefitDialogState extends State<AddBenefitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _paymentInformationController = TextEditingController();
  File? _selectedImage;

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _paymentInformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Beneficio'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!)
                        : const Text('Selecciona una imagen'),
                  ),
                  IconButton(
                    onPressed: _selectImageFromGallery,
                    icon: const Icon(Icons.image),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Descuento (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un descuento';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentInformationController,
                decoration:
                    const InputDecoration(labelText: 'Información de pago'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newBenefit = Benefit(
                id: '',
                title: _titleController.text,
                description: _descriptionController.text,
                imageUrl: _selectedImage != null
                    ? 'https://www.google.com'
                    : '',
                discount: int.parse(_discountController.text),
                paymentInformation:
                    _paymentInformationController.text.isNotEmpty
                        ? _paymentInformationController.text
                        : null,
              );
              Navigator.of(context).pop(newBenefit);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}