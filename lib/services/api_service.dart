import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net/api/Auth/login';

  static Future<User?> login(String username, String password) async {
  final url = Uri.parse('$baseUrl/login');
  final body = jsonEncode({'username': username, 'password': password});
  print('Sending POST to $url');
  print('Request Body: $body');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    return null;
  }
}


}
