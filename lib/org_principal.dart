import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'org_chat.dart';
import 'org_likes.dart';
import 'org_perfil.dart';

class OrgProfile {
  final String name;
  final String description;
  final List<String> images;

  OrgProfile(this.name, this.description, this.images);
}

class OrgPrincipal extends StatelessWidget {
  final List<OrgProfile> profiles = [
    OrgProfile(
      'Bene',
      'Simplemente, carlino.',
      [
        'assets/images/pug.jpeg',
        'assets/images/pugsito.jpeg',
        'assets/images/pugsi.jpg',
      ],
    ),
    OrgProfile(
      'Isma',
      'Perfil para Isma, a tope con los gatetes si no le pongo esto nos suspende asi que bueno... simplemente estoy haciendo essto para que ocupe mas, pues eso ' +
          'bogibogi wangwang',
      [
        'assets/images/gato1.jpg',
        'assets/images/gato2.jpeg',
        'assets/images/gato3.jpg',
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
      home: OrgPrincipalPage(profiles),
    );
  }
}

class OrgPrincipalPage extends StatefulWidget {
  final List<OrgProfile> profiles;

  OrgPrincipalPage(this.profiles);

  @override
  _OrgPrincipalPageState createState() => _OrgPrincipalPageState();
}

class _OrgPrincipalPageState extends State<OrgPrincipalPage> {
  late List<SwipeItem> swipeItems;
  late MatchEngine matchEngine;
  int currentProfileIndex = 0;
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7ED957), Color(0xFFFAB134)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('AdoptMate'),
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
                  OrgProfile profile = widget.profiles[index % widget.profiles.length];
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(profile.name),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      profile.description,
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
                                    Icon(
                                      Icons.info,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ],
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("No more profiles!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
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
          ],
        ),
      ),
    );
  }
}
