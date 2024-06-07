import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/user.dart';
import 'models/shelter.dart';
import 'models/message.dart';
import 'likes.dart';
import 'perfil.dart';
import 'user_principal.dart';
import 'models/api_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  User? _currentUser;
  Map<String, List<Message>> _chatMessages = {};

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
      await _loadAllMessages();
    } else {
      print('No se pudo cargar el usuario');
    }
  }

  Future<void> _loadAllMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var shelterData in _currentUser!.matchedShelters) {
      final Map<String, dynamic> shelter = shelterData as Map<String, dynamic>;
      final String name = shelter['name']?.toString() ?? 'No especificado';
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

  Widget _buildMatchedSheltersList(List<dynamic> matchedShelters) {
    Set<String> shelterNames = {};
    List<Widget> shelterWidgets = [];

    for (var shelterData in matchedShelters) {
      final Map<String, dynamic> shelter = shelterData as Map<String, dynamic>;
      final String name = shelter['name']?.toString() ?? 'No especificado';
      if (!shelterNames.contains(name)) {
        shelterNames.add(name);
        String lastMessage = (_chatMessages[name]?.isNotEmpty ?? false)
            ? _chatMessages[name]!.last.text // Mostrar el último mensaje
            : 'No hay mensajes';

        shelterWidgets.add(
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
                      builder: (context) => ChatScreen(
                        currentUser: _currentUser!,
                        shelterName: name,
                        shelterPhone: shelter['phone']?.toString() ?? 'No especificado',
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

    return Column(children: shelterWidgets);
  }

  Widget _buildChatList() {
    if (_currentUser == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final List<dynamic> matchedShelters = _currentUser!.matchedShelters;
    Set<String> shelterNames = {};

    List<Widget> chatWidgets = matchedShelters.map((shelterData) {
      final Map<String, dynamic> shelter = shelterData as Map<String, dynamic>;
      final String name = shelter['name']?.toString() ?? 'No especificado';
      if (!shelterNames.contains(name)) {
        shelterNames.add(name);
        String lastMessage = (_chatMessages[name]?.isNotEmpty ?? false)
            ? _chatMessages[name]!.last.text // Mostrar el último mensaje
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
                    builder: (context) => ChatScreen(
                      currentUser: _currentUser!,
                      shelterName: name,
                      shelterPhone: shelter['phone']?.toString() ?? 'No especificado',
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
              MaterialPageRoute(builder: (context) => UserPrincipal()),
            );
          },
        ),
        title: Text('Chats'),
        foregroundColor: Colors.white,
      ),
      body: Container(
        child: _currentUser != null ? _buildChatList() : Center(child: CircularProgressIndicator()),
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

class ChatScreen extends StatefulWidget {
  final User currentUser;
  final String shelterName;
  final String shelterPhone;
  final List<Message> messages;

  const ChatScreen({
    Key? key,
    required this.currentUser,
    required this.shelterName,
    required this.shelterPhone,
    this.messages = const [],
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    String? storedMessages = prefs.getString('chat_${widget.shelterName}');
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
    prefs.setString('chat_${widget.shelterName}', jsonEncode(_messages));
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
        title: Text('Chat con ${widget.shelterName}'),
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
    bool isSentByUser = message.issuer == 'USER';

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
          issuer: 'USER',
          user: widget.currentUser,
          shelter: Shelter(
            id: 0,
            cif: '',  // Proporcione el cif aquí
            name: widget.shelterName,
            password: '',  // Proporcione la contraseña aquí
            location: '',  // Proporcione la ubicación aquí
            phone: int.parse(widget.shelterPhone),
          ),
        ));
      });
      _messageController.clear();

      try {
        await sendMessage(widget.currentUser.name, widget.shelterName, messageContent);
      } catch (e) {
        print('Error al enviar mensaje: $e');
      }
    }
  }
}
