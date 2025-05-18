class User {
  final String username;
  final String email;
  final List<String> roles;
  final int coffeeCount;
  final String qrCodeUrl;

  User({
    required this.username,
    required this.email,
    required this.roles,
    required this.coffeeCount,
    required this.qrCodeUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      roles: List<String>.from(json['roles']),
      coffeeCount: json['coffeeCount'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }
}
