import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user.dart';
import 'models/shelter.dart';
import 'chat.dart';
import 'perfil.dart';
import 'user_principal.dart';
import 'models/api_service.dart';

class LikePage extends StatefulWidget {
  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
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

  Widget _buildMatchedSheltersList(List<dynamic> matchedShelters) {
    Set<String> shelterNames = {}; // Para rastrear nombres únicos
    List<Widget> shelterWidgets = [];

    for (var shelterData in matchedShelters) {
      final Map<String, dynamic> shelter = shelterData as Map<String, dynamic>;
      final String name = shelter['name'] ?? 'No especificado';
      if (!shelterNames.contains(name)) {
        shelterNames.add(name);
        shelterWidgets.add(
          Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teléfono: ${shelter['phone'] ?? 'No especificado'}'),
                  Text('Ubicación: ${shelter['location'] ?? 'No especificado'}'),
                  Text('Descripción: ${shelter['description'] ?? 'No especificado'}'),
                ],
              ),
            ),
          ),
        );
      }
    }
    
    return Column(children: shelterWidgets);
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
        title: Text('Likes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _currentUser != null
              ? [
                  _buildMatchedSheltersList(_currentUser!.matchedShelters),
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
                      MaterialPageRoute(builder: (context) => UserPrincipal()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                  ),
                  child: Icon(
                    Icons.home,
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
