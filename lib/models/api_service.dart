import 'dart:convert';
import 'shelter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'pet.dart';

const String baseUrl = 'http://13.60.50.5/api/user';
const String baseUrlOrg = 'http://13.60.50.5/api/shelter';
const String baseUrlPet = 'http://13.60.50.5/api/pet';
//10.0.2.2:8080
//13.60.50.5

// Save User to SharedPreferences
Future<void> saveUserToPrefs(User user) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user', jsonEncode(user.toJson()));
}
Future<void> saveShelterToPrefs(Shelter shelter) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('shelter', jsonEncode(shelter.toJson()));
}
Future<Shelter?> loadShelterFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final shelterJson = prefs.getString('shelter');
  if (shelterJson != null) {
    return Shelter.fromJson(jsonDecode(shelterJson));
  }
  return null;
}
// Load User from SharedPreferences
Future<User?> loadUserFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  if (userJson != null) {
    return User.fromJson(jsonDecode(userJson));
  }
  return null;
}

// Save Token to SharedPreferences
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
}

// Get Token from SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}
Future<void> saveUser(User user) async {
  final url = Uri.parse('$baseUrl/save');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('User registrado correctamente');
  } else {
    print('fallo al registrar user: ${response.statusCode}');
    print('Error: ${response.body}');
    throw Exception('fallo al registrar user: ${response.body}');
  }
}
Future<void> saveShelter(Shelter shelter) async {
  final url = Uri.parse('$baseUrlOrg/save');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(shelter.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('org registrado correctamente');
  } else {
    print('fallo al registrar org: ${response.statusCode}');
    print('Error: ${response.body}');
    throw Exception('fallo al registrar org: ${response.body}');
  }
}
 Future<void> savePet(Pet pet) async {
  final url = Uri.parse('$baseUrlPet/save');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(pet.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('pet registrado correctamente');
  } else {
    print('fallo al registrar pet: ${response.statusCode}');
    print('Error: ${response.body}');
    print(pet.toString());
    throw Exception('fallo al registrar pet: ${response.body}');
  }
}
Future<bool> loginUser(String username, String pass) async {
  final url = Uri.http(
    '13.60.50.5',
    '/api/user/login',
    {
      'username': username,
      'pass': pass,
    },
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    try {
      if (response.body.isEmpty) {
        print('body vacío');
        return false;
      }
      var usuario = jsonDecode(response.body);
     if (usuario != null && usuario['name'] == username && usuario['password'] == pass) {
        final token = usuario['token'] ?? '';
        final user = User.fromJson(usuario); 
        await saveToken(token);
        await saveUserToPrefs(user); 
        print('Login bueno');
        print(response.body);
        return true;
      } else {
        print('User o contraseña incorrecta');
        print(username);
        print(pass);
        print('fallo al logear user dentro del 200: ${response.statusCode}');
        print('Error dentro de 200: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      return false;
    }
  } else {
    print('fallo al logear user: ${response.statusCode}');
    print('Error: ${response.body}');
    return false;
  }
}
Future<bool> loginShelter(String username, String pass) async {
    final url = Uri.http(
    '13.60.50.5',
    '/api/shelter/login',
    {
      'username': username,
      'pass': pass,
    },
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    try {
      if (response.body.isEmpty) {
        print('body vacío');
        return false;
      }
      var shelteraux = jsonDecode(response.body);
     if (shelteraux != null && shelteraux['name'] == username && shelteraux['password'] == pass) {
        final token = shelteraux['token'] ?? '';
        final shelter = Shelter.fromJson(shelteraux); 
        await saveToken(token);
        await saveShelterToPrefs(shelter); 
        print('Login bueno');
        print(response.body);
        return true;
      } else {
        print('User o contraseña incorrecta');
        print(username);
        print(pass);
        print('fallo al logear org dentro del 200: ${response.statusCode}');
        print('Error dentro de 200: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      return false;
    }
  } else {
    print('fallo al logear org: ${response.statusCode}');
    print('Error: ${response.body}');
    return false;
  }
}
Future<List<String>> fetchBreeds(String query) async {
  final url = Uri.http(
    '13.60.50.5',
    '/api/pet/breeds',
    {
      'name': query,
    },
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> breedsJson = jsonDecode(response.body);
     List<String> breedNames = breedsJson.map((breed) => breed['name'] as String).toList();
    return breedNames;
  } else {
     print('fallo al cargar breeds: ${response.statusCode}');
     print('Error: ${response.body}');
    throw Exception('fallo al cargar breeds');

  }
}
Future<void> sendLike(int userId, int petId) async {
  final url = Uri.parse('$baseUrl/like');


  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'petId': petId,
    }),
  );

  if (response.statusCode == 200) {
    print('like guardado');
  } else {
    print('fallo al guardar like: ${response.statusCode}');
    print('Error: ${response.body}');
    throw Exception('Fallo al guardar like: ${response.body}');
  }
}
