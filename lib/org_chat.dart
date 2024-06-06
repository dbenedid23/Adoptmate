import 'package:flutter/material.dart';
import 'org_principal.dart';
import 'org_likes.dart';
import 'org_perfil.dart';

class OrgChatPage extends StatefulWidget {
  @override
  _OrgChatPageState createState() => _OrgChatPageState();
}

class _OrgChatPageState extends State<OrgChatPage> {
  List<OrgProfile> orgProfiles = [
    OrgProfile('Dani', 'Simplemente, carlino.', ['assets/images/pug.jpeg']),
    OrgProfile(
        'Isma',
        'Perfil para Isma, a tope con los gatetes si no le pongo esto nos suspende asi que bueno... simplemente estoy haciendo essto para que ocupe mas, pues eso',
        ['assets/images/gato1.jpg']),
  ];

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
        title: Text('Chats'),
       
      ),
      body: Container(
        //color: Color.fromARGB(255, 165, 132, 196),
        child: ListView.builder(
          itemCount: orgProfiles.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Image.asset(
                          orgProfiles[index].images[0],
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(orgProfiles[index].images[0]),
                ),
              ),
              title: Text(orgProfiles[index].name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(profile: orgProfiles[index])),
                );
              },
            );
          },
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

class ChatScreen extends StatefulWidget {
  final OrgProfile profile;

  const ChatScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  Map<String, List<Message>> _chatMessages = {};

  @override
  void initState() {
    super.initState();
    _messages = _chatMessages[widget.profile.name] ?? [];
  }

  @override
  void dispose() {
    _chatMessages[widget.profile.name] = _messages;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.profile.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    bool isSentByUser = message.sender == 'Usuario';

    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByUser ? Color.fromARGB(255, 68, 207, 13) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.content,
          softWrap: true,
        ),
      ),
    );
  }

  void _sendMessage() {
    setState(() {
      String messageContent = _messageController.text;
      if (messageContent.isNotEmpty) {
        _messages.insert(0, Message(sender: 'Usuario', content: messageContent));
        _messageController.clear();
      }
    });
  }
}

class Message {
  final String sender;
  final String content;

  Message({required this.sender, required this.content});
}
