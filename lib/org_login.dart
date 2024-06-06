import 'package:flutter/material.dart';
import 'main.dart';
import 'org_register.dart';
import 'org_principal.dart';
import 'models/api_service.dart';

class OrgLoginPage extends StatefulWidget {
  @override
  _OrgLoginPageState createState() => _OrgLoginPageState();
}

class _OrgLoginPageState extends State<OrgLoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,  
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent, 
        elevation: 0,  
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
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
        title: Text('Organización'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7ED957), Color(0xFFFAB134)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 80),
                Image.asset(
                  'assets/images/Logo2.png',
                  height: 240,
                  width: 200,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Nombre de la organización',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
                      _showValidationError(context, 'Por favor, rellena ambos campos.');
                    } else {
                      bool authenticated = await loginShelter(
                        _nameController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (authenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrgPrincipal()),
                        );
                      } else {
                        _showValidationError(context, 'Nombre de organización o contraseña incorrectos.');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Iniciar Sesión'),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrgRegisterPage()),
                    );
                  },
                  child: Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showValidationError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de validación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
