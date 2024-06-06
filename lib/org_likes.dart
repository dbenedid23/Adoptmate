import 'package:flutter/material.dart';
import 'org_chat.dart';
import 'org_perfil.dart';
import 'org_principal.dart';

class OrgLikePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<OrgProfile> likedProfiles = [
      OrgProfile('Dani', 'Simplemente, carlino.', ['assets/images/pug.jpeg']),
      OrgProfile(
          'Isma',
          'Perfil para Isma, a tope con los gatetes si no le pongo esto nos suspende asi que bueno... simplemente estoy haciendo essto para que ocupe mas, pues eso',
          ['assets/images/gato1.jpg']),
    ];

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
      body: ListView.builder(
        itemCount: likedProfiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Image.asset(
                        likedProfiles[index].images[0],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                backgroundImage: AssetImage(likedProfiles[index].images[0]),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(likedProfiles[index].name),
                      content: Text(likedProfiles[index].description),
                    );
                  },
                );
              },
              child: Text(likedProfiles[index].name),
            ),
            trailing: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(profile: likedProfiles[index])),
                );
              },
              child: Icon(Icons.send),
            ),
          );
        },
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
