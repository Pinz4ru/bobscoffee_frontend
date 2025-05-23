import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoyaltyScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final Locale locale;
  final ValueChanged<String> onChangeLanguage;

  const LoyaltyScreen({
    Key? key,
    required this.user,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.locale,
    required this.onChangeLanguage,
  }) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  late User currentUser;
  final bool _loading = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  Future<void> _refreshData() async {
  final username = currentUser.username;
  final url = Uri.parse(
    'https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net/api/User/tracked-by-username/$username',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final updatedCoffeeCount = jsonData['coffeeCount'];

      if (mounted && updatedCoffeeCount is int) {
        setState(() {
          currentUser = User(
            username: currentUser.username,
            email: currentUser.email,
            roles: currentUser.roles,
            coffeeCount: updatedCoffeeCount,
            qrCodeUrl: currentUser.qrCodeUrl,
          );
        });
      }
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e, stack) {
    debugPrint('Error refreshing coffee count: $e');
    debugPrintStack(stackTrace: stack);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh coffee count')),
      );
    }
  }
}

  static const int totalCoffees = 10;

  List<Positioned> buildCrosses(int coffeeCount) {
    const positions = [
      Offset(47, 54),
      Offset(103, 54),
      Offset(160, 54),
      Offset(216, 54),
      Offset(272, 54),
      Offset(47, 117),
      Offset(103, 117),
      Offset(160, 117),
      Offset(216, 117),
      Offset(271, 117),
    ];

    return List.generate(coffeeCount.clamp(0, totalCoffees), (index) {
      return Positioned(
        left: positions[index].dx,
        top: positions[index].dy,
        child: const Icon(Icons.close, color: Colors.red, size: 40),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final qrImageUrl =
        'https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net${currentUser.qrCodeUrl}';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.helloUser(currentUser.username)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
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
              const SizedBox(width: 8),
              DropdownButton<String>(
                dropdownColor: Colors.white,
                value: widget.locale.languageCode,
                icon: const Icon(Icons.language, color: Colors.white),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  if (value != null) widget.onChangeLanguage(value);
                },
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                  DropdownMenuItem(value: 'ro', child: Text('RO')),
                  DropdownMenuItem(value: 'ru', child: Text('RU')),
                ],
              ),
              IconButton(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/loyalty_default.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        ...buildCrosses(currentUser.coffeeCount),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      loc.qrInstruction,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.network(
                        qrImageUrl,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) =>
                            Text(loc.failedToLoadQRCode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
