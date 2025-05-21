import 'dart:convert';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final Locale locale;
  final ValueChanged<String> onChangeLanguage;
  
  const AdminScreen({
    Key? key,
    required this.user,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.locale,
    required this.onChangeLanguage,
  }) : super(key: key);
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  
  List<dynamic> _users = [];
  bool _loading = false;

  final String apiUrl = 'https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net/api/admin';

  @override
  void initState() {
    super.initState();
    fetchLoyaltyCards();
  }

  Future<void> fetchLoyaltyCards() async {
  if (!mounted) return;
  setState(() => _loading = true);

  final response = await http.get(Uri.parse('$apiUrl/loyalty'));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (!mounted) return;
    setState(() => _users = data);
  }

  if (!mounted) return;
  setState(() => _loading = false);
}
Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved login data
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login'); // Or your login route
  }

  Future<void> createAccount(String username, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$apiUrl/accounts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (response.statusCode == 200) {
      fetchLoyaltyCards();
    }
  }
  Future<void> updateAccount(String username, String email, String role) async {
  final response = await http.put(
    Uri.parse('$apiUrl/accounts/$username'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'role': role,
    }),
  );

  if (response.statusCode == 200) {
    fetchLoyaltyCards();
  }
}


  Future<void> deleteAccount(String username) async {
    await http.delete(Uri.parse('$apiUrl/accounts/$username'));
    fetchLoyaltyCards();
  }

  Future<void> resetCoffee(String username) async {
    await http.patch(Uri.parse('$apiUrl/loyalty/$username/reset'));
    fetchLoyaltyCards();
  }

  Future<void> removeCoffee(String username) async {
    await http.patch(Uri.parse('$apiUrl/loyalty/$username/remove'));
    fetchLoyaltyCards();
  }

  Future<void> addCoffee(String username) async {
    await http.post(Uri.parse('$apiUrl/scan/$username?amount=1'));
    fetchLoyaltyCards();
  }

  void showCreateUserDialog() {
    final loc = AppLocalizations.of(context)!;
    final _username = TextEditingController();
    final _email = TextEditingController();
    final _password = TextEditingController();
    final _role = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:  Text(loc.createUserTitle ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: _role, decoration: const InputDecoration(labelText: 'Role')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              createAccount(
                _username.text,
                _email.text,
                _password.text,
                _role.text,
              );
            },
            child:  Text(loc.createUserButton),
          ),
        ],
      ),
    );
  }

  void showUpdateUserDialog(Map<String, dynamic> user) {
  final loc = AppLocalizations.of(context)!;
  final _email = TextEditingController(text: loc.emailInfo(user['email']));
  final _role = TextEditingController(text: user['roles']);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title:  Text(loc.updateUserTitle),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(loc.usernameLabel(user['username'])),
            TextField(controller: _email, decoration: InputDecoration(labelText: loc.emailLabel)),
            TextField(controller: _role, decoration: InputDecoration(labelText: loc.roleLabel)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            updateAccount(
              user['username'],
              _email.text,
              _role.text,
            );
          },
          child: Text(loc.updateButton),
        ),
      ],
    ),
  );
}


  void scanAndAddCoffee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScanPage()),
    );

    if (result != null && result is String) {
      await addCoffee(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
  title: Text(loc.adminPanel),
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
  actions: [
    // Dark mode toggle switch
    Row(
      children: [
        const Icon(Icons.light_mode, color: Colors.white),
        Switch(
          value: widget.isDarkMode,
          onChanged: widget.onToggleDarkMode,
          activeColor: Colors.white,
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[600],
        ),
        const Icon(Icons.dark_mode, color: Colors.white),
      ],
    ),

    IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
  ],
),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchLoyaltyCards,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: showCreateUserDialog,
                            child:  Text(loc.createUserButton, style: TextStyle(color: Colors.red)),
                          ),
                          OutlinedButton(
                            onPressed: fetchLoyaltyCards,
                            child: Text(loc.showAllUsersButton, style: TextStyle(color: Colors.red)),
                          ),
                          OutlinedButton(
                            onPressed: scanAndAddCoffee,
                            child: Text(loc.scanQRButton, style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(loc.allUsersTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      for (var user in _users)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.usernameLabel(user.username), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("Email: ${user['email']}"),
                                Text(loc.coffeeRoleInfo(user.coffeeCount, user.roles)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.local_cafe),
                                          onPressed: () => addCoffee(user['username']),
                                        ),
                                         Text(loc.addButton)
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.refresh),
                                          onPressed: () => resetCoffee(user['username']),
                                        ),
                                        Text(loc.resetButton)
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => removeCoffee(user['username']),
                                        ),
                                        Text(loc.removeButton)
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => showUpdateUserDialog(user),
                                        ),
                                        Text(loc.updateButtonText)
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => deleteAccount(user['username']),
                                        ),
                                        Text(loc.deleteButton)
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String? scannedData;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title:  Text(loc.scanQRTitle), backgroundColor: Colors.red),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null && mounted) {
            Navigator.pop(context, barcode.rawValue);
          }
        },
      ),
    );
  }
}
