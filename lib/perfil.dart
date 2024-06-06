import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user.dart';
import 'models/api_service.dart';
import 'chat.dart';
import 'likes.dart';
import 'user_principal.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = await loadUserFromPrefs();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      print('Usuario cargado: ${user.name}');
    } else {
      print('No se pudo cargar el usuario');
    }
  }

  Widget _buildUserInfo(String label, String value, IconData icon) {
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
              MaterialPageRoute(builder: (context) => UserPrincipal()),
            );
          },
        ),
        title: Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _currentUser != null
              ? [
                  _buildUserInfo('Nombre', _currentUser!.name, Icons.person),
                  _buildUserInfo(
                      'Teléfono',
                      _currentUser!.phone?.toString() ?? "No especificado",
                      Icons.phone),
                  _buildUserInfo(
                      'Descripción',
                      _currentUser!.description ?? "No especificado",
                      Icons.description),
                  _buildUserInfo(
                      'Código Postal',
                      _currentUser!.zipCode?.toString() ?? "No especificado",
                      Icons.location_pin),
                  _buildUserInfo(
                      'Tiene mascotas',
                      _currentUser!.pets == true ? "Sí" : "No",
                      Icons.pets),
                  _buildUserInfo(
                      'Tiene niños',
                      _currentUser!.kids == true ? "Sí" : "No",
                      Icons.child_friendly),
                  _buildUserInfo(
                    'Tipo de casa', 
                   ('${_currentUser!.home ?? "No especificado"}'), 
                    Icons.home)
                    //child: Text('${_currentUser!.home ?? "No especificado"}'),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No se pudo cargar el usuario',
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
                      MaterialPageRoute(builder: (context) => ChatPage()),
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
                      MaterialPageRoute(builder: (context) => LikePage()),
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
                      MaterialPageRoute(builder: (context) => PerfilPage()),
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
