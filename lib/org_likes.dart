import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user.dart';
import 'models/shelter.dart';
import 'org_chat.dart';
import 'org_perfil.dart';
import 'org_principal.dart';
import 'models/api_service.dart';

class OrgLikePage extends StatefulWidget {
  @override
  _OrgLikePageState createState() => _OrgLikePageState();
}

class _OrgLikePageState extends State<OrgLikePage> {
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
      print('Matched Users: ${shelter.matchedUsers}');
    } else {
      print('No se pudo cargar el shelter');
    }
  }

  Widget _buildMatchedUsersList(List<dynamic> matchedUsers) {
    if (matchedUsers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No hay usuarios que hayan hecho match',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    Set<String> userNames = {}; // Para rastrear nombres únicos
    List<Widget> userWidgets = [];

    for (var userData in matchedUsers) {
      if (userData is Map<String, dynamic>) {
        final String name = userData['name'] ?? 'No especificado';
        if (!userNames.contains(name)) {
          userNames.add(name);
          userWidgets.add(
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
                    Text('Teléfono: ${userData['phone'] ?? 'No especificado'}'),
                    Text('Descripción: ${userData['description'] ?? 'No especificado'}'),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return Column(children: userWidgets);
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
        title: Text('Likes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _currentShelter != null
              ? [
                  _buildMatchedUsersList(_currentShelter!.matchedUsers),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No se pudo cargar el shelter',
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
                      MaterialPageRoute(builder: (context) => OrgPrincipal()),
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
