import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'chat.dart';
import 'likes.dart';
import 'perfil.dart';
import 'models/api_service.dart';
import 'models/pet.dart';
import 'dart:typed_data';

class UserPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdoptMate',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserPrincipalPage(),
    );
  }
}

class UserPrincipalPage extends StatefulWidget {
  @override
  _UserPrincipalPageState createState() => _UserPrincipalPageState();
}

class _UserPrincipalPageState extends State<UserPrincipalPage> {
  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    matchEngine = MatchEngine(swipeItems: swipeItems); 
    _loadInitialPets();
  }

  Future<void> _loadInitialPets() async {
    for (int i = 0; i < 5; i++) {
      await _fetchRandomPet();
    }
    setState(() {
      matchEngine = MatchEngine(swipeItems: swipeItems); 
    });
  }

  Future<void> _fetchRandomPet() async {
    Pet? pet = await fetchRandomPet();
    if (pet != null) {
      setState(() {
        swipeItems.add(
          SwipeItem(
            content: pet,
            likeAction: () {
              _fetchRandomPet();
              print("like");
              _showSnackBar(context, 'LIKE', pet.name, Colors.green);
            },
            nopeAction: () {
              _fetchRandomPet();
              print("dislike");
              _showSnackBar(context, 'DISLIKE', pet.name, Colors.red);
            },
          ),
        );
      });
    }
  }

  void _showSnackBar(BuildContext context, String action, String name, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action == 'LIKE' ? Icons.thumb_up : Icons.thumb_down,
              color: Colors.white,
            ),
            SizedBox(width: 2),
            Text(
              '$action to $name',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        duration: Duration(milliseconds: 180),
      ),
    );
  }

  void toggleExpansion() {
    setState(() {
      expanded = !expanded;
    });
  }

  void _showDescriptionDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pet.name),
          content: SingleChildScrollView(
            child: Text(
              pet.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AdoptMate'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7ED957), Color(0xFFFAB134)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: swipeItems.isNotEmpty
          ? SwipeCards(
              matchEngine: matchEngine,
              itemBuilder: (BuildContext context, int index) {
                Pet pet = swipeItems[index].content;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: pet.profileImage != null
                          ? Image.memory(
                              pet.profileImage!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.pets, size: 100),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                matchEngine.currentItem?.nope();
                              },
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(0, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 48,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                matchEngine.currentItem?.like();
                              },
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(0, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.green,
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 120,
                      child: GestureDetector(
                        onTap: () {
                          toggleExpansion();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 56, 56, 56)
                                    .withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    pet.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: const Color.fromARGB(255, 14, 14, 14),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      _showDescriptionDialog(context, pet);
                                    },
                                    child: Icon(
                                      Icons.info,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                              if (expanded)
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                                    maxWidth: MediaQuery.of(context).size.width - 32,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      pet.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              onStackFinished: () {
                // Cuando la pila de tarjetas se vacía, se recargan más tarjetas
                _loadInitialPets();
              },
              itemChanged: (SwipeItem item, int index) {
                // Lógica cuando cambia el elemento
              },
              upSwipeAllowed: false,
              fillSpace: true,
            )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        color: Colors.black,
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
    );
  }
}
