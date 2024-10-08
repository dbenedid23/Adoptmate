import 'package:flutter/material.dart';
import 'models/api_service.dart';
import 'models/pet.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class OrgRegisterMatePage extends StatefulWidget {
  final String shelterName;

  OrgRegisterMatePage({required this.shelterName});

  @override
  _OrgRegisterMatePageState createState() => _OrgRegisterMatePageState();
}

class _OrgRegisterMatePageState extends State<OrgRegisterMatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  late final TextEditingController _shelterController;

  int _currentStep = 0;
  List<String> _breedSuggestions = [];
  Uint8List? _imageBytes;
  Pet? _registeredPet;

  @override
  void initState() {
    super.initState();
    _shelterController = TextEditingController(text: widget.shelterName);
  }

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
        title: Text('Añadir una mascota'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCurrentStep(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                if (_validateCurrentStep()) {
                  if (_currentStep == 6) {
                    _submitPet();
                    Navigator.pop(context);
                  } else {
                    _moveToNextStep();
                  }
                }
              },
              child: Text(_currentStep == 6 ? 'Finalizar' : 'Continuar'),
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
          hintText: 'Introduce el nombre de la mascota',
          controller: _nameController,
          sampleText: 'Fido',
        );
      case 1:
        return _buildTextFieldWithButton(
          labelText: 'Sexo',
          hintText: 'Introduce el sexo de la mascota (Macho/Hembra)',
          controller: _sexController,
          sampleText: 'Macho',
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce el sexo de la mascota.');
              return false;
            }
            if (value.toUpperCase() != 'MACHO' && value.toUpperCase() != 'HEMBRA') {
              _showValidationError('El sexo solo puede ser "Macho" o "Hembra".');
              return false;
            }
            return true;
          },
        );
      case 2:
        return _buildTextFieldWithButton(
          labelText: 'Edad',
          hintText: 'Introduce la edad de la mascota',
          controller: _ageController,
          sampleText: '3',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              _showValidationError('Por favor, introduce la edad de la mascota.');
              return false;
            }
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              _showValidationError('La edad debe ser un valor numérico.');
              return false;
            }
            return true;
          },
        );
      case 3:
        return _buildTextFieldWithMultiline(
          labelText: 'Descripción',
          hintText: 'Introduce una breve descripción de la mascota',
          controller: _descriptionController,
          sampleText: 'Es un perro muy amigable.',
          maxLength: 200,
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
        
      case 4:
        return _buildTextFieldWithButton(
          labelText: 'Refugio',
          hintText: 'Introduce el nombre del refugio',
          controller: _shelterController,
          sampleText: 'Refugio de animales',
          enabled: false,
        );
      case 5:
        return _buildBreedField();
      case 6:
        return _buildFinalStep();
      default:
        return Container();
    }
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

  Widget _buildTextFieldWithButton({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required String sampleText,
    TextInputType keyboardType = TextInputType.text,
    bool Function(String?)? validator,
    bool enabled = true,
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
            ),
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
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
    required TextEditingController controller,
    required String sampleText,
    int maxLength = 200,
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
            maxLength: maxLength,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
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

  Widget _buildBreedField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Raza',
              hintText: 'Introduce la raza de la mascota',
            ),
            controller: _breedController,
            onChanged: (value) {
              _fetchBreedSuggestions(value);
            },
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Ejemplo: Labrador',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Expanded(child: _buildBreedSuggestions()),
        ],
      ),
    );
  }

  Widget _buildBreedSuggestions() {
    return ListView.builder(
      itemCount: _breedSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_breedSuggestions[index]),
          onTap: () {
            _breedController.text = _breedSuggestions[index];
            setState(() {
              _breedSuggestions.clear();
            });
          },
        );
      },
    );
  }

  void _fetchBreedSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _breedSuggestions.clear();
      });
      return;
    }

    try {
      List<String> breeds = await fetchBreeds(query);
      setState(() {
        _breedSuggestions = breeds;
      });
    } catch (e) {
      print('Error fetching breed suggestions: $e');
    }
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
          'Por favor, introduce el nombre de la mascota.',
        );
      case 1:
        return _validateStep(
          _sexController.text.trim(),
          'Por favor, introduce el sexo de la mascota.',
          (value) {
            if (value != null && (value.toLowerCase() == 'macho' || value.toLowerCase() == 'hembra')) {
              return true;
            } else {
              _showValidationError('El sexo solo puede ser "Macho" o "Hembra".');
              return false;
            }
          },
        );
      case 2:
        return _validateStep(
          _ageController.text.trim(),
          'Por favor, introduce la edad de la mascota.',
          (value) {
            if (value != null && RegExp(r'^\d+$').hasMatch(value)) {
              return true;
            } else {
              _showValidationError('La edad debe ser un valor numérico.');
              return false;
            }
          },
        );
      case 3:
        return _validateStep(
          _descriptionController.text.trim(),
          'Por favor, introduce una breve descripción.',
          (value) {
            if (value != null && value.length <= 200) {
              return true;
            } else {
              _showValidationError('La descripción no puede exceder los 200 caracteres.');
              return false;
            }
          },
        );
      case 4:
        return true; // El campo del refugio ya está validado al inicio
      case 5:
        return _validateStep(
          _breedController.text.trim(),
          'Por favor, introduce la raza de la mascota.',
        );
      case 6:
        return true;
      default:
        return true;
    }
  }

  bool _validateStep(String value, String emptyError, [bool Function(String?)? additionalValidation]) {
    if (value.isEmpty) {
      _showValidationError(emptyError);
      return false;
    }
    if (additionalValidation != null && !additionalValidation(value)) {
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

  void _submitPet() async {
    final pet = Pet(
      name: _nameController.text.trim(),
      sex: _sexController.text.trim()[0], 
      age: int.parse(_ageController.text.trim()),
      description: _descriptionController.text.trim(),
      shelterName: _shelterController.text.trim(),
      breedName: _breedController.text.trim(),
      profileImage: _imageBytes,
    );
    print("pet data: ${jsonEncode(pet.toJson())}");
    
    savePet(pet).then((_) {
      print('pet registrado');
    }).catchError((error) {
      print('Fallo al guardar pet: $error');
      _showValidationError('Fallo al guardar user');
    });
  }
}
