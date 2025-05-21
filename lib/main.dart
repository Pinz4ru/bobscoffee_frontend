import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/barista/barista_screen.dart';
import 'screens/user/loyalty_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('username');
  final savedEmail = prefs.getString('email');
  final savedRoles = prefs.getStringList('roles') ?? [];
  final savedCoffeeCount = prefs.getInt('coffeeCount') ?? 0;
  final savedQrCodeUrl = prefs.getString('qrCodeUrl') ?? '';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final savedLangCode = prefs.getString('languageCode') ?? 'en';

  runApp(MyApp(
    initialUser: savedUsername != null
        ? User(
            username: savedUsername,
            email: savedEmail ?? '',
            roles: savedRoles,
            coffeeCount: savedCoffeeCount,
            qrCodeUrl: savedQrCodeUrl,
          )
        : null,
    initialDarkMode: isDarkMode,
    initialLangCode: savedLangCode,
  ));
}

class MyApp extends StatefulWidget {
  final User? initialUser;
  final bool initialDarkMode;
  final String initialLangCode;

  const MyApp({
    Key? key,
    this.initialUser,
    required this.initialDarkMode,
    required this.initialLangCode,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  User? user;
  bool isDarkMode = false;
  Locale locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    user = widget.initialUser;
    isDarkMode = widget.initialDarkMode;
    locale = Locale(widget.initialLangCode);
  }

  Future<void> login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setStringList('roles', user.roles);
    await prefs.setInt('coffeeCount', user.coffeeCount);
    await prefs.setString('qrCodeUrl', user.qrCodeUrl);
    setState(() {
      this.user = user;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      user = null;
    });
  }

  void toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  void changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', langCode);
    setState(() {
      locale = Locale(langCode);
    });
  }

  Widget _buildHomeScreen() {
    final loc = AppLocalizations.of(context)!;
    if (user == null) return LoginScreen(onLogin: login);

    if (user!.roles.contains('Admin')) {
      return AdminScreen(
        onLogout: logout,
        isDarkMode: isDarkMode,
        onToggleDarkMode: toggleDarkMode,
        locale: locale,
        onChangeLanguage: changeLanguage,
        user: user!,
      );
    } else if (user!.roles.contains('Barista')) {
      return BaristaScreen(
        onLogout: logout,
        isDarkMode: isDarkMode,
        onToggleDarkMode: toggleDarkMode,
        locale: locale,
        onChangeLanguage: changeLanguage,
        user: user!,
      );
    } else if (user!.roles.contains('Customer')) {
      return LoyaltyScreen(
        onLogout: logout,
        isDarkMode: isDarkMode,
        onToggleDarkMode: toggleDarkMode,
        locale: locale,
        onChangeLanguage: changeLanguage,
        user: user!,
      );
    } else {
      return Scaffold(
        
        appBar: AppBar(title:  Text(loc.unknownRoleMessage)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(loc.unknownRoleMessage),
              ElevatedButton(onPressed: logout, child: Text(loc.logout)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bob's Coffee",
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('ro')],
      localizationsDelegates: const [
    AppLocalizations.delegate,                  // your generated localizations
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red.shade900,
        scaffoldBackgroundColor: const Color(0xFF1B1F3B),
        colorScheme: ColorScheme.dark(primary: Colors.red.shade900),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _buildHomeScreen(),
    );
  }
}
