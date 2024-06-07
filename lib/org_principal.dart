import 'package:AdoptMate/models/shelter.dart';
import 'package:AdoptMate/org_chat.dart';
import 'package:AdoptMate/org_likes.dart';
import 'package:AdoptMate/org_perfil.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'models/api_service.dart';
import 'models/user.dart';
import 'models/pet.dart'; // Asegúrate de importar el modelo Pet

class OrgPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdoptMate',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OrgPrincipalPage(),
    );
  }
}

class OrgPrincipalPage extends StatefulWidget {
  @override
  _OrgPrincipalPageState createState() => _OrgPrincipalPageState();
}

class _OrgPrincipalPageState extends State<OrgPrincipalPage> {
  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    matchEngine = MatchEngine(swipeItems: swipeItems);
    _loadInitialUsers();
  }

  Future<void> _loadInitialUsers() async {
    for (int i = 0; i < 5; i++) {
      await _fetchRandomUser();
    }
    setState(() {
      matchEngine = MatchEngine(swipeItems: swipeItems);
    });
  }

  Future<void> _fetchRandomUser() async {
    User? user = await fetchRandomUser();
    if (user != null) {
      setState(() {
        swipeItems.add(
          SwipeItem(
            content: user,
            likeAction: () {
              _fetchRandomUser();
              print("like");
              _showSnackBar(context, 'LIKE', user.name, Colors.green);
              print("like desde un shelter para user");
              _sendLike(user.id!);
            },
            nopeAction: () {
              _fetchRandomUser();
              print("dislike");
              _showSnackBar(context, 'DISLIKE', user.name, Colors.red);
            },
          ),
        );
      });
    }
  }

  Future<void> _sendLike(int userId) async {
    Shelter? currentShelter = await loadShelterFromPrefs();
    if (currentShelter != null && currentShelter.pets.isNotEmpty) {
      // Asumiendo que el shelter tiene al menos una pet
      int petId = currentShelter.pets.first.id!;
      await sendLikeShelterToUser(petId, userId);
    } else {
      print("El shelter no tiene pets o no está logueado correctamente");
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

  void _showDescriptionDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.name),
          content: SingleChildScrollView(
            child: Text(
              user.description ?? 'no',
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
                User user = swipeItems[index].content;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: user.profileImage != null
                          ? Image.memory(
                              user.profileImage!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person, size: 100),
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
                                color: const Color.fromARGB(255, 56, 56, 56).withOpacity(0.5),
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
                                    user.name ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: const Color.fromARGB(255, 14, 14, 14),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      _showDescriptionDialog(context, user);
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
                                      user.description ?? 'No description available',
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
                _loadInitialUsers();
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
                    MaterialPageRoute(builder: (context) =>OrgPerfilPage()),
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
