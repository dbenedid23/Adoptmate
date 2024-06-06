
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/user.dart';
import 'models/api_service.dart';
import 'dart:convert';
import 'package:image/image.dart' as img; // Importar el paquete 'image'
import 'dart:typed_data';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  bool _hasPets = false;
  bool _hasChildren = false;
  HomeType? _homeType;
  //File? _image;
  Uint8List? _imageBytes;

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
          if (_currentStep < 8)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_validateCurrentStep()) {
                    if (_currentStep == 7) {
                      _submitUser();
                      Navigator.pop(context);
                    } else {
                      _moveToNextStep();
                    }
                  }
                },
                child: Text(_currentStep == 7 ? 'Finalizar' : 'Continuar'),
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
          labelText: 'Nombre',
          hintText: 'Introduce tu nombre',
          prefixIcon: Icons.person,
          controller: _nameController,
          nextAction: _moveToNextStep,
          sampleText: 'Pepon231',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu nombre.');
              return false;
            }
            if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
              _showValidationError(
                  'El nombre solo puede contener letras y espacios.');
              return false;
            }
            return true;
          },
        );
      case 1:
        return _buildTextFieldWithButton(
          labelText: 'Contraseña',
          hintText: 'Introduce tu contraseña',
          prefixIcon: Icons.lock,
          controller: _passwordController,
          nextAction: _moveToNextStep,
          sampleText: 'pepon123',
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu contraseña.');
              return false;
            }
            return true;
          },
        );
      case 2:
        return _buildTextFieldWithButton(
          labelText: 'Teléfono',
          hintText: 'Introduce tu teléfono',
          prefixIcon: Icons.phone,
          controller: _phoneController,
          nextAction: _moveToNextStep,
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
      case 3:
        return _buildTextFieldWithMultiline(
          labelText: 'Descripción',
          hintText: 'Introduce una breve descripción',
          prefixIcon: Icons.description,
          controller: _descriptionController,
          nextAction: _moveToNextStep,
          sampleText: 'Soy pepon y me gustan los perris',
          validator: (value) {
            if (_descriptionController.text.trim().isEmpty) {
              _showValidationError('Por favor, introduce tu descripción.');
              return false;
            }
            return true;
          },
        );
      case 4:
        return _buildTextFieldWithButton(
          labelText: 'Código Postal',
          hintText: 'Introduce tu código postal',
          prefixIcon: Icons.location_on,
          controller: _zipCodeController,
          nextAction: _moveToNextStep,
          sampleText: '12345',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce tu código postal.');
              return false;
            }
            if (!RegExp(r'^\d{5}$').hasMatch(value)) {
              _showValidationError('El código postal debe contener 5 números.');
              return false;
            }
            return true;
          },
        );
      case 5:
        return _buildPetsAndChildrenStep();
      case 6:
        return _buildHomeTypeStep();
      case 7:
        return _buildFinalStep();
      default:
        return Container();
    }
  }

  Widget _buildTextFieldWithButton({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    VoidCallback? nextAction,
    required String sampleText,
    bool isPassword = false,
    bool Function(String?)? validator,
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
            validator: (value) {
              // return validator!(value);
            },
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
    VoidCallback? nextAction,
    required String sampleText,
    bool Function(String?)? validator,
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
            validator: (value) {
              // return validator!(value);
            },
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

  Widget _buildPetsAndChildrenStep() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¿Tiene mascotas?'),
          Checkbox(
            value: _hasPets,
            onChanged: (bool? value) {
              setState(() {
                _hasPets = value ?? false;
              });
            },
          ),
          SizedBox(
            height: 8,
          ),
          Text('¿Tiene niños?'),
          Checkbox(
            value: _hasChildren,
            onChanged: (bool? value) {
              setState(() {
                _hasChildren = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo de Vivienda'),
          ListTile(
            title: const Text('Chalet'),
            leading: Radio<HomeType>(
              value: HomeType.CHALET,
              groupValue: _homeType,
              onChanged: (HomeType? value) {
                setState(() {
                  _homeType = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Apartamento'),
            leading: Radio<HomeType>(
              value: HomeType.APARTMENT,
              groupValue: _homeType,
              onChanged: (HomeType? value) {
                setState(() {
                  _homeType = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sube una imagen para tu perfil'),
          SizedBox(height: 8),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: _imageBytes == null
                  ? Icon(Icons.add_a_photo, size: 50)
                  : Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 20),
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
          _nameController.text.trim(),
          RegExp(r'^[a-zA-Z ]+$'),
          'Por favor, introduce tu nombre.',
          'El nombre solo puede contener letras y espacios.',
        );
      case 1:
        return _validateStep(
          _passwordController.text.trim(),
          null,
          'Por favor, introduce tu contraseña.',
          null,
        );
      case 2:
        return _validateStep(
          _phoneController.text.trim(),
          RegExp(r'^\d{9}$'),
          'Por favor, introduce tu teléfono.',
          'El teléfono debe contener 9 números.',
        );
      case 3:
        return _validateStep(
          _descriptionController.text.trim(),
          null,
          'Por favor, introduce una breve descripción sobre ti.',
          null,
        );
      case 4:
        return _validateStep(
          _zipCodeController.text.trim(),
          RegExp(r'^\d{5}$'),
          'Por favor, introduce tu código postal.',
          'El código postal debe contener 5 números.',
        );
      case 5:
        return true;
      case 6:
        return _homeType != null;
      case 7:
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

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final Uint8List bytes = await pickedImage.readAsBytes();
      
      
      setState(() {
        Image.memory(bytes);
        _imageBytes = bytes;
      });
    }
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

  void _submitUser() async {
    final user = User(
      name: _nameController.text.trim(),
      password: _passwordController.text.trim(),
      phone: int.parse(_phoneController.text.trim()),
      zipCode: int.parse(_zipCodeController.text.trim()),
      description: _descriptionController.text.trim(),
      pets: _hasPets,
      kids: _hasChildren,
      home: _homeType,
      profileImage: _imageBytes,
    );

    print("user data: ${jsonEncode(user.toJson())}"); // Agrega esta línea para depuración

    saveUser(user).then((_) {
      print('Usuario registrado');
    }).catchError((error) {
      print('Fallo al guardar user: $error');
      _showValidationError('Fallo al guardar user');
    });
  }
}