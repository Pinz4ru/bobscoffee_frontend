import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class LoyaltyScreen extends StatelessWidget {
  final User user;

  const LoyaltyScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.username}!'),
            const SizedBox(height: 10),
            Text('Coffee Count: ${user.coffeeCount}'),
          ],
        ),
      ),
    );
  }
}
