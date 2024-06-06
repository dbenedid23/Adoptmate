import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'chat.dart';
import 'likes.dart';
import 'perfil.dart';
import 'models/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String description;
  final List<String> images;

  UserProfile(this.name, this.description, this.images);
}

class UserPrincipal extends StatelessWidget {
  final List<UserProfile> profiles = [
    UserProfile(
      'Peter',
      'Elegante pero callejero.',
      [
        'assets/images/pug.jpeg',
        'assets/images/pugsito.jpeg',
        'assets/images/pugsi.jpg',
      ],
    ),
    UserProfile(
      'Isma',
      'Soy un gato naranja siempre puesto para hacer amigos o no jeje',
      [
        'assets/images/gato1.jpg',
        'assets/images/gato2.jpeg',
        'assets/images/gato3.jpg',
      ],
    ),
    UserProfile(
      'Marta',
      'Soy un pequeño pajarito que solo quiere volar',
      [
        'assets/images/aga.jpg',
        'assets/images/aga2.jpg',
        'assets/images/aga3.jpg',
      ],
    ),
    UserProfile(
      'Enrique',
      'Fiel y leal, las apariencias engañan',
      [
        'assets/images/rot.jpg',
        'assets/images/rot1.jpg',
        'assets/images/rot3.jpg',
      ],
    ),
    UserProfile(
      'Raúl',
      'Se busca:',
      [
        'assets/images/yeti.jpg',
        'assets/images/yet1.jpg',
        'assets/images/yeti2.jpg',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdoptMate',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserPrincipalPage(profiles),
    );
  }
}

class UserPrincipalPage extends StatefulWidget {
  final List<UserProfile> profiles;

  UserPrincipalPage(this.profiles);

  @override
  _UserPrincipalPageState createState() => _UserPrincipalPageState();
}

class _UserPrincipalPageState extends State<UserPrincipalPage> {
  late List<SwipeItem> swipeItems;
  late MatchEngine matchEngine;
  int currentProfileIndex = 0;
  bool expanded = false;
  bool descriptionExpanded = false;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    swipeItems = widget.profiles.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () {
          changeProfile(true);
        },
        nopeAction: () {
          changeProfile(false);
        },
      );
    }).toList();

    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  void toggleExpansion() {
    setState(() {
      expanded = !expanded;
    });
  }

  void toggleDescriptionExpansion() {
    setState(() {
      descriptionExpanded = !descriptionExpanded;
    });
  }

  void changeProfile(bool like) {
    setState(() {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: like ? Colors.green : Colors.red,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                like ? Icons.thumb_up : Icons.thumb_down,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                like ? 'LIKE' : 'DISLIKE',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      currentProfileIndex = (currentProfileIndex + 1) % widget.profiles.length;
      currentImageIndex = 0; // Reset the image index when changing profile
    });
  }

  void resetSwipeItems() {
    swipeItems = widget.profiles.map((profile) {
      return SwipeItem(
        content: profile,
        likeAction: () {
          changeProfile(true);
        },
        nopeAction: () {
          changeProfile(false);
        },
      );
    }).toList();
    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  void _showDescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.profiles[currentProfileIndex].name),
          content: SingleChildScrollView(
            child: Text(
              widget.profiles[currentProfileIndex].description,
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

  void _changeImage(int direction) {
    setState(() {
      currentImageIndex =
          (currentImageIndex + direction) % widget.profiles[currentProfileIndex].images.length;
      if (currentImageIndex < 0) {
        currentImageIndex += widget.profiles[currentProfileIndex].images.length;
      }
    });
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
      body: GestureDetector(
        onTapUp: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localOffset = box.globalToLocal(details.globalPosition);
          final screenWidth = box.size.width;

          if (localOffset.dx > screenWidth / 2) {
            _changeImage(1); // Next image
          } else {
            _changeImage(-1); // Previous image
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SwipeCards(
                matchEngine: matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  UserProfile profile = widget.profiles[index % widget.profiles.length];
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          profile.images[currentImageIndex],
                          fit: BoxFit.cover,
                        ),
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
                                      profile.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: const Color.fromARGB(255, 14, 14, 14),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        _showDescriptionDialog(context);
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
                                        profile.description,
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
                  resetSwipeItems(); // Reiniciar las tarjetas cuando se acaban
                },
                itemChanged: (SwipeItem item, int index) {
                  setState(() {
                    currentProfileIndex = index % widget.profiles.length;
                    currentImageIndex = 0; // Reset the image index when changing profile
                  });
                },
                upSwipeAllowed: false,
                fillSpace: true,
              ),
            ),
            Container(
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
            if (descriptionExpanded)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Text(
                      widget.profiles[currentProfileIndex].description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
