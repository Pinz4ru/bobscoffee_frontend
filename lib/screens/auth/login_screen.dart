import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_screen.dart';
import '../../models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  
  final Future<void> Function(User user) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = User.fromJson(json);
        await widget.onLogin(user);
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['message'] ?? AppLocalizations.of(context)!.loginFailed;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.somethingWentWrong;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo at top
                  Image.asset(
              'assets/images/logo.png',
              height: 300,  // Adjust size as needed
              width: 300,
              fit: BoxFit.contain,
            ),
                  
                  const SizedBox(height: 32),
                  TextFormField(
  controller: _usernameController,
  style: const TextStyle(color: Colors.black), // 👈 Text color
  decoration: InputDecoration(
    labelText: loc.username,
    labelStyle: const TextStyle(color: Colors.red), // 👈 Label color (optional)
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
  ),
  validator: (value) =>
                    value == null || value.isEmpty ? loc.enterUsername : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                   controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black), // 👈 Text color
                    decoration: InputDecoration(
                    labelText: loc.password,
                    labelStyle: const TextStyle(color: Colors.red), // 👈 Label color (optional)
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) =>
                    value == null || value.isEmpty ? loc.enterPassword : null,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              loc.login,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    
                  ),
                  TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(onLogin: widget.onLogin),
      ),
    );
  },
  child: Text(loc.dontHaveAccountRegister),
),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
