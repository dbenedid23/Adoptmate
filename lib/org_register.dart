import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/api_service.dart';
import 'models/shelter.dart';

class OrgRegisterPage extends StatefulWidget {
  @override
  _OrgRegisterPageState createState() => _OrgRegisterPageState();
}

class _OrgRegisterPageState extends State<OrgRegisterPage> {
  final TextEditingController _cifController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7ED957), Color(0xFFFAB134)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Adoptmate'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCurrentStep(),
          ),
          if (_currentStep < 6)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_validateCurrentStep()) {
                    if (_currentStep == 5) {
                      _registerShelter();
                    } else {
                      _moveToNextStep();
                    }
                  }
                },
                child: Text(_currentStep == 5 ? 'Finalizar' : 'Continuar'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildTextFieldWithButton(
          labelText: 'CIF',
          hintText: 'Introduce tu CIF',
          prefixIcon: Icons.credit_card,
          controller: _cifController,
          sampleText: 'A12345678',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu CIF.');
              return false;
            }
            if (!RegExp(r'^[a-zA-Z]\d{8}$').hasMatch(value)) {
              _showValidationError('El CIF debe comenzar con una letra seguida de 8 números.');
              return false;
            }
            return true;
          },
        );
      case 1:
        return _buildTextFieldWithButton(
          labelText: 'Nombre de la organización',
          hintText: 'Introduce el nombre de la organización',
          prefixIcon: Icons.person,
          controller: _nameController,
          sampleText: 'Nombre de la organización',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce el nombre de la organización.');
              return false;
            }
            return true;
          },
        );
      case 2:
        return _buildTextFieldWithButton(
          labelText: 'Contraseña',
          hintText: 'Introduce tu contraseña',
          prefixIcon: Icons.lock,
          controller: _passwordController,
          isPassword: true,
          sampleText: 'Contraseña',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu contraseña.');
              return false;
            }
            return true;
          },
        );
      case 3:
        return _buildTextFieldWithButton(
          labelText: 'Ubicación',
          hintText: 'Introduce la ubicación de la organización',
          prefixIcon: Icons.location_on,
          controller: _locationController,
          sampleText: 'Ubicación',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce la ubicación de la organización.');
              return false;
            }
            return true;
          },
        );
      case 4:
        return _buildTextFieldWithButton(
          labelText: 'Teléfono',
          hintText: 'Introduce tu teléfono',
          prefixIcon: Icons.phone,
          controller: _phoneController,
          sampleText: '123456789',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu teléfono.');
              return false;
            }
            if (!RegExp(r'^\d{9}$').hasMatch(value)) {
              _showValidationError('El teléfono debe contener 9 números.');
              return false;
            }
            return true;
          },
        );
      case 5:
        return _buildTextFieldWithMultiline(
          labelText: 'Descripción',
          hintText: 'Introduce una breve descripción',
          prefixIcon: Icons.description,
          controller: _descriptionController,
          sampleText: 'Breve descripción de la organización',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce una breve descripción.');
              return false;
            }
            if (value.length > 200) {
              _showValidationError('La descripción no puede exceder los 200 caracteres.');
              return false;
            }
            return true;
          },
        );
      case 6:
      //  return _buildFinalStep();
      default:
        return Container();
    }
  }

  Widget _buildTextFieldWithButton({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required String sampleText,
    bool isPassword = false,
    required bool Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: Icon(prefixIcon),
            ),
            controller: controller,
            obscureText: isPassword,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Ejemplo: $sampleText',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithMultiline({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required String sampleText,
    required bool Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: Icon(prefixIcon),
            ),
            controller: controller,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Ejemplo: $sampleText',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }


  void _moveToNextStep() {
    setState(() {
      _currentStep++;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateStep(
          _cifController.text.trim(),
          RegExp(r'^[a-zA-Z]\d{8}$'),
          'Por favor, introduce tu CIF.',
          'El CIF debe comenzar con una letra seguida de 8 números.',
        );
      case 1:
        return _validateStep(
          _nameController.text.trim(),
          null,
          'Por favor, introduce el nombre de la organización.',
          null,
        );
      case 2:
        return _validateStep(
          _passwordController.text.trim(),
          null,
          'Por favor, introduce tu contraseña.',
          null,
        );
      case 3:
        return _validateStep(
          _locationController.text.trim(),
          null,
          'Por favor, introduce la ubicación de la organización.',
          null,
        );
      case 4:
        return _validateStep(
          _phoneController.text.trim(),
          RegExp(r'^\d{9}$'),
          'Por favor, introduce tu teléfono.',
          'El teléfono debe contener 9 números.',
        );
      case 5:
        return _validateStep(
          _descriptionController.text.trim(),
          null,
          'Por favor, introduce una breve descripción.',
          'La descripción no puede exceder los 200 caracteres.',
        );
      case 6:
        return true;
      default:
        return true;
    }
  }

  bool _validateStep(
      String value, RegExp? regex, String emptyError, String? invalidError) {
    if (value.isEmpty) {
      _showValidationError(emptyError);
      return false;
    }
    if (regex != null && !regex.hasMatch(value)) {
      _showValidationError(invalidError!);
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de validación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _registerShelter() async {
    try {
      final shelter = Shelter(
        cif: _cifController.text.trim(),
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        location: _locationController.text.trim(),
        phone: int.parse(_phoneController.text.trim()),
        description: _descriptionController.text.trim(),
      );

      await saveShelter(shelter);
      Navigator.pop(context);
    } catch (e) {
      _showValidationError('Error al registrar la organización: $e');
    }
  }
}
