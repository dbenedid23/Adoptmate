import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/shelter.dart';
import 'models/api_service.dart';
import 'org_chat.dart';
import 'org_likes.dart';
import 'org_principal.dart';
import 'org_register_mate.dart'; // Importa la nueva página
import 'models/pet.dart';

class OrgPerfilPage extends StatefulWidget {
  @override
  _OrgPerfilPageState createState() => _OrgPerfilPageState();
}

class _OrgPerfilPageState extends State<OrgPerfilPage> {
  Shelter? _currentShelter;

  @override
  void initState() {
    super.initState();
    _loadShelterData();
  }

  Future<void> _loadShelterData() async {
    Shelter? shelter = await loadShelterFromPrefs();
    if (shelter != null) {
      setState(() {
        _currentShelter = shelter;
      });
      print('Shelter cargado: ${shelter.name}');
    } else {
      print('No se pudo cargar el shelter');
    }
  }

  Widget _buildShelterInfo(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildPetInfo(Pet pet) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: pet.profileImage != null
                      ? Image.memory(
                          pet.profileImage!, // Muestra la imagen
                          fit: BoxFit.contain,
                        )
                      : Icon(Icons.pets, size: 50), // Icono por defecto si no hay imagen
                );
              },
            );
          },
          child: CircleAvatar(
            backgroundImage: pet.profileImage != null
                ? MemoryImage(pet.profileImage!) // Muestra la imagen
                : null,
            child: pet.profileImage == null
                ? Icon(Icons.pets, color: Colors.orange)
                : null, // Icono por defecto si no hay imagen
          ),
        ),
        title: Text(
          pet.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            'Raza: ${pet.breedName}, Edad: ${pet.age}, Descripción: ${pet.description}'),
      ),
    );
  }

  Future<void> _navigateAndRefresh(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrgRegisterMatePage()),
    );
    _loadShelterData(); // Recarga los datos después de regresar de la página de registro de mascota
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7ED957), Color(0xFFFAB134)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrgPrincipal()),
            );
          },
        ),
        title: Text('Perfil de Organización'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _currentShelter != null
              ? [
                  ElevatedButton(
                    onPressed: () {
                      _navigateAndRefresh(context);
                    },
                    child: Text('Añadir una mascota'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  _buildShelterInfo('CIF', _currentShelter!.cif, Icons.business),
                  _buildShelterInfo('Nombre', _currentShelter!.name, Icons.person),
                  _buildShelterInfo(
                      'Teléfono',
                      _currentShelter!.phone.toString(),
                      Icons.phone),
                  _buildShelterInfo(
                      'Descripción',
                      _currentShelter!.description ?? "No especificado",
                      Icons.description),
                  _buildShelterInfo(
                      'Ubicación',
                      _currentShelter!.location,
                      Icons.location_pin),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Mascotas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._currentShelter!.pets.map((pet) => _buildPetInfo(pet)).toList(),
                ]
              : [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No se pudo cargar la información del shelter',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.black,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrgChatPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                  ),
                  child: Icon(
                    Icons.chat_bubble,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrgLikePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrgPerfilPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
