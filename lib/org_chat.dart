import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user.dart';
import 'models/shelter.dart';
import 'models/message.dart';
import 'org_principal.dart';
import 'org_likes.dart';
import 'org_perfil.dart';
import 'models/api_service.dart';

class OrgChatPage extends StatefulWidget {
  @override
  _OrgChatPageState createState() => _OrgChatPageState();
}

class _OrgChatPageState extends State<OrgChatPage> {
  Shelter? _currentShelter;
  Map<String, List<Message>> _chatMessages = {};

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
      await _loadAllMessages();
    } else {
      print('No se pudo cargar el shelter');
    }
  }

  Future<void> _loadAllMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var userData in _currentShelter!.matchedUsers) {
      final Map<String, dynamic> user = userData as Map<String, dynamic>;
      final String name = user['name']?.toString() ?? 'No especificado';
      String? storedMessages = prefs.getString('chat_$name');
      if (storedMessages != null) {
        setState(() {
          _chatMessages[name] = (jsonDecode(storedMessages) as List)
              .map((data) => Message.fromJson(data))
              .toList();
        });
      }
    }
  }

  Widget _buildMatchedUsersList(List<dynamic> matchedUsers) {
    Set<String> userNames = {};
    List<Widget> userWidgets = [];

    for (var userData in matchedUsers) {
      final Map<String, dynamic> user = userData as Map<String, dynamic>;
      final String name = user['name']?.toString() ?? 'No especificado';
      if (!userNames.contains(name)) {
        userNames.add(name);
        String lastMessage = (_chatMessages[name]?.isNotEmpty ?? false)
            ? _chatMessages[name]!.last.text
            : 'No hay mensajes';

        userWidgets.add(
          Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(lastMessage),
              trailing: IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrgChatScreen(
                        currentShelter: _currentShelter!,
                        userName: name,
                        userPhone: user['phone']?.toString() ?? 'No especificado',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    }

    return Column(children: userWidgets);
  }

  Widget _buildChatList() {
    if (_currentShelter == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final List<dynamic> matchedUsers = _currentShelter!.matchedUsers;
    Set<String> userNames = {};

    List<Widget> chatWidgets = matchedUsers.map((userData) {
      final Map<String, dynamic> user = userData as Map<String, dynamic>;
      final String name = user['name']?.toString() ?? 'No especificado';
      if (!userNames.contains(name)) {
        userNames.add(name);
        String lastMessage = (_chatMessages[name]?.isNotEmpty ?? false)
            ? _chatMessages[name]!.last.text
            : 'No hay mensajes';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lastMessage),
            trailing: IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrgChatScreen(
                      currentShelter: _currentShelter!,
                      userName: name,
                      userPhone: user['phone']?.toString() ?? 'No especificado',
                      messages: _chatMessages[name] ?? [],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        return Container();
      }
    }).toList();

    return ListView(children: chatWidgets);
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
        foregroundColor: Colors.white,
      ),
      body: Container(
        child: _currentShelter != null ? _buildChatList() : Center(child: CircularProgressIndicator()),
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

class OrgChatScreen extends StatefulWidget {
  final Shelter currentShelter;
  final String userName;
  final String userPhone;
  final List<Message> messages;

  const OrgChatScreen({
    Key? key,
    required this.currentShelter,
    required this.userName,
    required this.userPhone,
    this.messages = const [],
  }) : super(key: key);

  @override
  _OrgChatScreenState createState() => _OrgChatScreenState();
}

class _OrgChatScreenState extends State<OrgChatScreen> {
  TextEditingController _messageController = TextEditingController();
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedMessages = prefs.getString('chat_${widget.userName}');
    if (storedMessages != null) {
      setState(() {
        _messages = (jsonDecode(storedMessages) as List)
            .map((data) => Message.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chat_${widget.userName}', jsonEncode(_messages));
  }

  @override
  void dispose() {
    _saveMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.userName}'),
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
    bool isSentByShelter = message.issuer == 'SHELTER';

    return Align(
      alignment: isSentByShelter ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByShelter ? Color.fromARGB(255, 68, 207, 13) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          softWrap: true,
        ),
      ),
    );
  }

  void _sendMessage() async {
    String messageContent = _messageController.text;
    if (messageContent.isNotEmpty) {
      setState(() {
        _messages.insert(0, Message(
          time: DateTime.now(),
          text: messageContent,
          issuer: 'SHELTER',
          user: User(
            id: 0,
            name: widget.userName,
            password: '',
            phone: int.parse(widget.userPhone),
          ),
          shelter: widget.currentShelter,
        ));
      });
      _messageController.clear();

      try {
        await sendMessageShelter(widget.userName, widget.currentShelter.name, messageContent);
      } catch (e) {
        print('Error al enviar mensaje: $e');
      }
    }
  }
}
