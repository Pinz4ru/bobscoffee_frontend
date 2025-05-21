import 'dart:convert';
import '../../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaristaScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final Locale locale;
  final ValueChanged<String> onChangeLanguage;

  const BaristaScreen({
    Key? key,
    required this.user,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.locale,
    required this.onChangeLanguage,
  }) : super(key: key);

  @override
  _BaristaScreenState createState() => _BaristaScreenState();
}


class _BaristaScreenState extends State<BaristaScreen> {
  final String apiUrl = 'https://bobscoffee-api-edg6fygqbtfhh7gb.westeurope-01.azurewebsites.net/api/admin';

  Future<void> addCoffee(String username) async {
    try {
      final response = await http.post(Uri.parse('$apiUrl/scan/$username?amount=1'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isFreeCoffee = data['isFreeCoffee'] ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFreeCoffee
                  ? AppLocalizations.of(context)!.freeCoffeeEarned(username)
                  : AppLocalizations.of(context)!.coffeeAdded(username),
                  style: const TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(loc.failedToAddCoffee, style: TextStyle(fontSize: 18),),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: const TextStyle(fontSize: 18),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openScanner() async {
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
        title: Text(loc.baristaPanel),
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
      ],
    ),
        IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white,),
          label:  Text(loc.scanQRCodeLabel, style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 75),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: openScanner,
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
  
  bool _scanning = false;
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.scanQRTitle), backgroundColor: Colors.red),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanning) return;
          final barcode = capture.barcodes.first;
          final rawValue = barcode.rawValue;
          if (rawValue != null) {
            _scanning = true;
            Navigator.pop(context, rawValue);
          }
        },
      ),
    );
  }
}
