// Vediporul - Amazon-style shopping app + admin panel (black & orange theme)
// Single-file version: copy this whole file into lib/main.dart
// No extra packages needed. Admin demo password: admin123
// Login is required. Demo customer: demo@vediporul.com / demo1234
// Admin account: admin@vediporul.com / admin123 (only admins see the Admin panel)
//
// PRODUCT IMAGES (real photos):
//  * Save a photo for each product in  assets/crackers/  named by product id:
//        1.jpg, 2.jpg, 3.jpg ... 36.jpg
//    and add to pubspec.yaml:
//        flutter:
//          assets:
//            - assets/crackers/
//  * Or paste a web image link in the admin "Image URL" box.
//  * If a photo is missing, a built-in cracker illustration is shown instead.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const VediporulApp());

// ============================================================
// THEME
// ============================================================
const kOrange = Color(0xFFFF7A00);
const kBlack = Color(0xFF0B0B0B);
const kCard = Color(0xFF1B1B1B);

String money(num v) => '₹${v.toStringAsFixed(0)}';

ThemeData vediporulTheme() {
  final radius = BorderRadius.circular(12);
  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: kBlack,
    colorScheme: const ColorScheme.dark(
      primary: kOrange,
      onPrimary: Colors.black,
      secondary: kOrange,
      surface: kCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBlack,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kOrange,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kOrange,
        side: const BorderSide(color: kOrange),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCard,
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: kOrange),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: kCard,
      indicatorColor: Color(0x40FF7A00),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kOrange,
      contentTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    ),
    dividerColor: Colors.white12,
  );
}

class VediporulLogo extends StatelessWidget {
  const VediporulLogo({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_cart_checkout, color: kOrange, size: size + 2),
        const SizedBox(width: 6),
        Text.rich(
          const TextSpan(children: [
            TextSpan(text: 'Vedi', style: TextStyle(color: Colors.white)),
            TextSpan(text: 'porul', style: TextStyle(color: kOrange)),
          ]),
          style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, letterSpacing: .5),
        ),
      ],
    );
  }
}

/// Shows the product's own photo (bundled asset or web link) when set,
/// otherwise a built-in cracker illustration for its category.
class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final art = CrackerArt(category: product.category, seed: product.id.hashCode);
    final url = product.imageUrl.trim();

    // No link set: look for a bundled photo named after the product id,
    // for example assets/crackers/1.jpg, assets/crackers/2.jpg ...
    // If that file does not exist, the drawn cracker artwork shows instead.
    final path = url.isEmpty ? 'assets/crackers/${product.id}.jpg' : url;

    // Local photo bundled with the app
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => art,
      );
    }

    // Photo from the internet
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => art,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: kCard,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kOrange)),
            ),
    );
  }
}

class CrackerArt extends StatelessWidget {
  const CrackerArt({super.key, required this.category, this.seed = 0});
  final String category;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _CrackerPainter(category, seed)),
    );
  }
}

class _CrackerPainter extends CustomPainter {
  _CrackerPainter(this.category, this.seed);
  final String category;
  final int seed;

  static const _base = [
    Color(0xFFFFD54F),
    Color(0xFFFF9800),
    Color(0xFFFF5252),
    Color(0xFFFFFFFF),
    Color(0xFFFF4081),
    Color(0xFF69F0AE),
  ];

  // Colour order shifts per product so every item looks different.
  List<Color> get _palette => [
        for (var i = 0; i < _base.length; i++) _base[(i + seed.abs()) % _base.length]
      ];

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..strokeWidth = w
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  Paint _fill(Color c) => Paint()..color = c;

  void _burst(Canvas canvas, Offset o, double r, math.Random rnd, int n) {
    final palette = _palette;
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n + rnd.nextDouble() * .2;
      final len = r * (.6 + rnd.nextDouble() * .4);
      final color = palette[i % palette.length];
      canvas.drawLine(
        o + Offset(math.cos(a) * r * .25, math.sin(a) * r * .25),
        o + Offset(math.cos(a) * len, math.sin(a) * len),
        _stroke(color, 1.6),
      );
      canvas.drawCircle(
          o + Offset(math.cos(a) * len, math.sin(a) * len), 1.2, _fill(color));
    }
    final glow = Rect.fromCircle(center: o, radius: r * .35);
    canvas.drawCircle(
      o,
      r * .35,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
        ).createShader(glow),
    );
  }

  Path _star(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * .45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    return path..close();
  }

  void _sparkle(Canvas canvas, Offset o, double r) {
    final p = _stroke(Colors.white, 1.6);
    canvas.drawLine(o + Offset(-r, 0), o + Offset(r, 0), p);
    canvas.drawLine(o + Offset(0, -r), o + Offset(0, r), p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final palette = _palette;

    // background
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF140A1F), Color(0xFF2A1000)],
        ).createShader(Offset.zero & size),
    );
    // night-sky stars
    for (var i = 0; i < 22; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        .6 + rnd.nextDouble() * 1.2,
        _fill(Colors.white.withOpacity(.25 + rnd.nextDouble() * .5)),
      );
    }

    // draw in a centred 100 x 100 coordinate space
    final u = math.min(size.width, size.height) / 100;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(u);

    switch (category) {
      case 'Sparklers':
        {
          const tips = [
            Offset(-24, -18),
            Offset(0, -28),
            Offset(24, -16),
            Offset(-10, -8),
          ];
          final count = 2 + seed.abs() % 3; // 2 to 4 sparklers
          for (final t in tips.take(count)) {
            canvas.drawLine(
                Offset(t.dx * .4, 46), t, _stroke(const Color(0xFFB0BEC5), 2.4));
            _burst(canvas, t, 17, rnd, 14);
          }
          break;
        }
      case 'Flower Pots':
        {
          for (var i = -9; i <= 9; i++) {
            final x = i * 4.5;
            final endY = -34 + (i.abs() * 1.8);
            final path = Path()
              ..moveTo(0, 12)
              ..quadraticBezierTo(i * 1.5, -48, x, endY);
            final color = palette[(i + 9) % palette.length];
            canvas.drawPath(path, _stroke(color.withOpacity(.9), 1.8));
            canvas.drawCircle(Offset(x, endY), 1.4, _fill(color));
          }
          final pot = Path()
            ..moveTo(-16, 18)
            ..lineTo(16, 18)
            ..lineTo(12, 44)
            ..lineTo(-12, 44)
            ..close();
          canvas.drawPath(pot, _fill(const Color(0xFFE65100)));
          canvas.drawRRect(
            RRect.fromLTRBR(-18, 12, 18, 20, const Radius.circular(3)),
            _fill(const Color(0xFFFF9800)),
          );
          break;
        }
      case 'Rockets':
        {
          canvas.save();
          canvas.translate(-6, 8);
          canvas.rotate(0.65);
          canvas.drawRect(
              const Rect.fromLTRB(-1, 14, 1, 48), _fill(const Color(0xFF8D6E63)));
          final flame = Path()
            ..moveTo(-5, 16)
            ..lineTo(0, 36)
            ..lineTo(5, 16)
            ..close();
          canvas.drawPath(flame, _fill(const Color(0xFFFFD54F)));
          canvas.drawRRect(
            RRect.fromLTRBR(-7, -22, 7, 16, const Radius.circular(3)),
            _fill(const Color(0xFFD32F2F)),
          );
          canvas.drawRect(
              const Rect.fromLTRB(-7, -8, 7, -2), _fill(const Color(0xFFFFD54F)));
          final nose = Path()
            ..moveTo(-7, -22)
            ..lineTo(0, -38)
            ..lineTo(7, -22)
            ..close();
          canvas.drawPath(nose, _fill(const Color(0xFFFF9800)));
          final finL = Path()
            ..moveTo(-7, 6)
            ..lineTo(-15, 18)
            ..lineTo(-7, 16)
            ..close();
          final finR = Path()
            ..moveTo(7, 6)
            ..lineTo(15, 18)
            ..lineTo(7, 16)
            ..close();
          canvas.drawPath(finL, _fill(const Color(0xFFFF9800)));
          canvas.drawPath(finR, _fill(const Color(0xFFFF9800)));
          canvas.restore();
          _burst(canvas, const Offset(32, -32), 13, rnd, 12);
          break;
        }
      case 'Chakras':
        {
          canvas.drawCircle(
              Offset.zero, 44, _stroke(const Color(0x33FFB74D), 1.5));
          for (var i = 0; i < 8; i++) {
            final a = i * math.pi / 4;
            final path = Path()
              ..moveTo(math.cos(a) * 8, math.sin(a) * 8)
              ..quadraticBezierTo(
                math.cos(a + .6) * 28,
                math.sin(a + .6) * 28,
                math.cos(a + 1.1) * 42,
                math.sin(a + 1.1) * 42,
              );
            canvas.drawPath(path, _stroke(palette[i % palette.length], 3.2));
          }
          canvas.drawCircle(Offset.zero, 7, _fill(const Color(0xFFE65100)));
          canvas.drawCircle(Offset.zero, 2.5, _fill(Colors.white));
          break;
        }
      case 'Gift Boxes':
        {
          canvas.drawRRect(
            RRect.fromLTRBR(-30, -2, 30, 38, const Radius.circular(4)),
            _fill(const Color(0xFFB71C1C)),
          );
          canvas.drawRRect(
            RRect.fromLTRBR(-34, -14, 34, -2, const Radius.circular(4)),
            _fill(const Color(0xFFD32F2F)),
          );
          canvas.drawRect(const Rect.fromLTRB(-5, -14, 5, 38),
              _fill(const Color(0xFFFFD54F)));
          canvas.drawOval(
              Rect.fromCenter(center: const Offset(-9, -20), width: 18, height: 12),
              _fill(const Color(0xFFFFD54F)));
          canvas.drawOval(
              Rect.fromCenter(center: const Offset(9, -20), width: 18, height: 12),
              _fill(const Color(0xFFFFD54F)));
          canvas.drawCircle(const Offset(0, -17), 4, _fill(const Color(0xFFFFA000)));
          _sparkle(canvas, const Offset(-40, -30), 5);
          _sparkle(canvas, const Offset(40, -34), 6);
          _sparkle(canvas, const Offset(-42, 20), 4);
          _sparkle(canvas, const Offset(42, 14), 4);
          break;
        }
      case 'Fancy Shots':
        {
          _burst(canvas, const Offset(-22, -26), 14, rnd, 12);
          _burst(canvas, const Offset(16, -32), 16, rnd, 14);
          _burst(canvas, const Offset(0, -10), 10, rnd, 10);
          canvas.drawRRect(
            RRect.fromLTRBR(-28, 10, 24, 42, const Radius.circular(4)),
            _fill(const Color(0xFF6A1B9A)),
          );
          canvas.drawRect(const Rect.fromLTRB(-28, 20, 24, 26), _fill(const Color(0xFFFFD54F)));
          for (var i = 0; i < 4; i++) {
            canvas.drawCircle(Offset(-20.0 + i * 13, 10), 3, _fill(Colors.black));
          }
          break;
        }
      case 'Ground Crackers':
        {
          final string = Path()
            ..moveTo(-44, 10)
            ..quadraticBezierTo(0, -30, 44, 10);
          canvas.drawPath(string, _stroke(const Color(0xFF8D6E63), 1.2));
          for (var i = 0; i <= 8; i++) {
            final t = i / 8;
            final x = -44 + 88 * t;
            final y = (1 - t) * (1 - t) * 10 + 2 * (1 - t) * t * (-30) + t * t * 10;
            canvas.drawRRect(
              RRect.fromLTRBR(x - 3, y, x + 3, y + 14, const Radius.circular(2)),
              _fill(i.isEven ? const Color(0xFFD32F2F) : const Color(0xFFFFB300)),
            );
          }
          _sparkle(canvas, const Offset(-44, 0), 5);
          _burst(canvas, const Offset(-12, 32), 10, rnd, 10);
          break;
        }
      case 'Kids Special':
        {
          for (var i = 0; i < 3; i++) {
            canvas.save();
            canvas.translate(-22.0 + i * 20, 8);
            canvas.rotate(-0.25 + i * 0.25);
            canvas.drawRect(const Rect.fromLTRB(-3, -10, 3, 30), _fill(const Color(0xFFFFEB3B)));
            canvas.drawRect(const Rect.fromLTRB(-3, 12, 3, 18), _fill(const Color(0xFFE53935)));
            final tip = Path()
              ..moveTo(-3, -10)
              ..lineTo(0, -18)
              ..lineTo(3, -10)
              ..close();
            canvas.drawPath(tip, _fill(const Color(0xFFFF9800)));
            canvas.restore();
          }
          _burst(canvas, const Offset(0, -28), 13, rnd, 12);
          _sparkle(canvas, const Offset(-38, -12), 4);
          _sparkle(canvas, const Offset(38, -12), 4);
          break;
        }
      case 'Twinkling Stars':
        {
          const spots = [
            Offset(-20, -14),
            Offset(18, -22),
            Offset(0, 8),
            Offset(-30, 18),
            Offset(26, 8),
          ];
          for (var i = 0; i < spots.length; i++) {
            final r = i == 2 ? 16.0 : 10.0;
            canvas.drawPath(_star(spots[i], r), _fill(palette[i % palette.length]));
            _sparkle(canvas, spots[i] + Offset(r * 1.1, -r * 1.1), 3);
          }
          break;
        }
      case 'Sound Crackers':
        {
          _burst(canvas, const Offset(0, -20), 24, rnd, 16);
          for (var i = 0; i < 4; i++) {
            final x = -24.0 + i * 15;
            canvas.drawRRect(
              RRect.fromLTRBR(x - 5, 8, x + 5, 36, const Radius.circular(3)),
              _fill(i.isEven ? const Color(0xFFD32F2F) : const Color(0xFFFFB300)),
            );
            canvas.drawRect(Rect.fromLTRB(x - 5, 18, x + 5, 22), _fill(Colors.white));
            canvas.drawLine(Offset(x, 8), Offset(x + 2, 2), _stroke(const Color(0xFF8D6E63), 1.2));
          }
          break;
        }
      case 'Mega Combo':
        {
          canvas.drawLine(const Offset(-16, 6), const Offset(-24, -26),
              _stroke(const Color(0xFFB0BEC5), 2.2));
          _burst(canvas, const Offset(-24, -26), 12, rnd, 12);
          canvas.drawRRect(
            RRect.fromLTRBR(12, -18, 22, 8, const Radius.circular(3)),
            _fill(const Color(0xFFD32F2F)),
          );
          final nose = Path()
            ..moveTo(12, -18)
            ..lineTo(17, -30)
            ..lineTo(22, -18)
            ..close();
          canvas.drawPath(nose, _fill(const Color(0xFFFF9800)));
          _sparkle(canvas, const Offset(4, -34), 5);
          canvas.drawRRect(
            RRect.fromLTRBR(-34, 6, 34, 42, const Radius.circular(4)),
            _fill(const Color(0xFF6D4C41)),
          );
          canvas.drawRect(const Rect.fromLTRB(-34, 18, 34, 22), _fill(const Color(0xFF4E342E)));
          canvas.drawCircle(const Offset(0, 30), 6, _stroke(const Color(0xFFFFD54F), 2));
          break;
        }
      default:
        _burst(canvas, Offset.zero, 38, rnd, 18);
    }

    // Diwali diya (oil lamp) in the corner of every picture
    final lamp = Path()
      ..moveTo(30, 42)
      ..quadraticBezierTo(40, 54, 52, 42)
      ..close();
    canvas.drawPath(lamp, _fill(const Color(0xFFE65100)));
    canvas.drawPath(lamp, _stroke(const Color(0xFFFFB74D), 1.2));
    final flameShape = Path()
      ..moveTo(41, 41)
      ..quadraticBezierTo(36, 33, 41, 27)
      ..quadraticBezierTo(46, 33, 41, 41)
      ..close();
    canvas.drawPath(flameShape, _fill(const Color(0xFFFFD54F)));
    canvas.drawCircle(const Offset(41, 36), 1.6, _fill(Colors.white));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrackerPainter old) =>
      old.category != category || old.seed != seed;
}

// ============================================================
// MODELS
// ============================================================
class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.mrp,
    this.rating = 4.2,
    this.stock = 20,
  });

  final String id;
  String name, description, category, imageUrl;
  double price, mrp, rating;
  int stock;

  int get discount => mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;
}

class CartItem {
  CartItem(this.product, [this.qty = 1]);
  final Product product;
  int qty;
  double get total => product.price * qty;
}

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.isAdmin = false,
  });
  final String name, email, phone;
  final bool isAdmin;
  final String password; // demo only: use real authentication before going live
}

enum OrderStatus { placed, packed, shipped, delivered, cancelled }

Color statusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.placed:
      return const Color(0xFFFF7A00);
    case OrderStatus.packed:
      return const Color(0xFFFFB74D);
    case OrderStatus.shipped:
      return const Color(0xFF42A5F5);
    case OrderStatus.delivered:
      return const Color(0xFF66BB6A);
    case OrderStatus.cancelled:
      return const Color(0xFFEF5350);
  }
}

String statusLabel(OrderStatus s) => s.name[0].toUpperCase() + s.name.substring(1);

class Order {
  Order({
    required this.id,
    required this.customer,
    required this.address,
    required this.items,
    required this.total,
    required this.date,
    required this.userEmail,
    this.status = OrderStatus.placed,
  });

  final String id, customer, address, userEmail;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  OrderStatus status;
}

// ============================================================
// STORE (in-memory data shared by shop + admin)
// Replace with Firebase / REST API to persist data.
// ============================================================
class Store extends ChangeNotifier {
  Store() {
    _seed();
  }

  static const categories = [
    'All',
    'Sparklers',
    'Flower Pots',
    'Rockets',
    'Chakras',
    'Fancy Shots',
    'Ground Crackers',
    'Kids Special',
    'Twinkling Stars',
    'Sound Crackers',
    'Mega Combo',
    'Gift Boxes',
  ];

  final List<Product> products = [];
  final List<CartItem> cart = [];
  final List<Order> orders = [];
  int _orderSeq = 1000;

  // ----- login (in-memory demo; replace with Firebase Auth / your API) -----
  final List<AppUser> users = [
    AppUser(
        name: 'Demo Customer',
        email: 'demo@vediporul.com',
        phone: '9876543210',
        password: 'demo1234'),
    AppUser(
        name: 'Store Admin',
        email: 'admin@vediporul.com',
        phone: '9000000000',
        password: 'admin123',
        isAdmin: true),
  ];
  final Map<String, int> _failedTries = {};
  final Map<String, DateTime> _lockedUntil = {};
  static const maxTries = 5;
  static const lockSeconds = 30;
  AppUser? currentUser;
  bool entered = false; // true once signed in or continued as guest

  String? signIn(String email, String password) {
    final e = email.trim().toLowerCase();
    final until = _lockedUntil[e];
    if (until != null && DateTime.now().isBefore(until)) {
      final secs = until.difference(DateTime.now()).inSeconds + 1;
      return 'Too many wrong attempts. Try again in $secs seconds';
    }
    final match = users.where((u) => u.email == e && u.password == password);
    if (match.isEmpty) {
      final n = (_failedTries[e] ?? 0) + 1;
      if (n >= maxTries) {
        _failedTries[e] = 0;
        _lockedUntil[e] = DateTime.now().add(const Duration(seconds: lockSeconds));
        return 'Too many wrong attempts. Try again in $lockSeconds seconds';
      }
      _failedTries[e] = n;
      return 'Wrong email or password (${maxTries - n} tries left)';
    }
    _failedTries.remove(e);
    _lockedUntil.remove(e);
    currentUser = match.first;
    entered = true;
    notifyListeners();
    return null;
  }

  /// One account per email and per mobile number.
  String? signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    final e = email.trim().toLowerCase();
    final ph = phone.trim();
    if (users.any((u) => u.email == e)) {
      return 'This email is already registered. Please sign in';
    }
    if (users.any((u) => u.phone == ph)) {
      return 'This mobile number is already registered. Please sign in';
    }
    final user = AppUser(name: name.trim(), email: e, phone: ph, password: password);
    users.add(user);
    currentUser = user;
    entered = true;
    notifyListeners();
    return null;
  }

  void signOut() {
    currentUser = null;
    entered = false;
    notifyListeners();
  }

  void _seed() {
    Product p(String id, String name, String cat, double price, double mrp,
            double rating, int stock, String desc, [String img = '']) =>
        Product(
          id: id,
          name: name,
          category: cat,
          price: price,
          mrp: mrp,
          rating: rating,
          stock: stock,
          description: desc,
          imageUrl: img,
        );

    // No photo is set, so every item shows the built-in Diwali cracker artwork.
    // To use your own photo, add its path or web link as an extra last argument
    // (for example 'assets/crackers/sparklers.jpg') or set it in the admin panel.
    products.addAll([
      p('1', '5 Star Colour Sparklers (10 pcs)', 'Sparklers', 120, 180, 4.5, 150,
          'Classic hand-held colour sparklers, 10 pcs per pack. Bright golden sparks for the festival evening.'),
      p('2', 'Electric Sparklers 30 cm (10 pcs)', 'Sparklers', 160, 240, 4.4, 120,
          'Long 30 cm sparklers with a bright, long-lasting glow. Use under adult supervision.'),
      p('3', 'Crackling Sparklers 15 cm (10 pcs)', 'Sparklers', 70, 110, 4.2, 180,
          'Short sparklers with a crackling sound. Perfect for children with an adult nearby.'),
      p('4', 'Flower Pots Deluxe (5 pcs)', 'Flower Pots', 250, 400, 4.6, 90,
          'Ground fountain that throws a tall shower of colourful sparks. Pack of 5.'),
      p('5', 'Colour Changing Giant Flower Pot', 'Flower Pots', 180, 300, 4.3, 60,
          'Big flower pot with a multi-colour effect that changes as it burns.'),
      p('6', 'Asoka Flower Pots Special (10 pcs)', 'Flower Pots', 320, 520, 4.5, 75,
          'Bright golden fountain, long burning time. Pack of 10 pots.'),
      p('7', 'Whistling Sky Rockets (10 pcs)', 'Rockets', 220, 350, 4.2, 70,
          'Rockets with a whistling sound and bright burst. Launch from an open ground only.'),
      p('8', 'Colour Rockets Bomb (5 pcs)', 'Rockets', 260, 420, 4.3, 55,
          'Rockets that go high and burst into many colours. Pack of 5.'),
      p('9', 'Ground Chakkar Big (10 pcs)', 'Chakras', 90, 150, 4.4, 200,
          'Spinning ground wheel that lights up in bright colours. Pack of 10.'),
      p('10', 'Vishnu Chakra Special (5 pcs)', 'Chakras', 110, 180, 4.1, 0,
          'Special chakra with a longer spin and extra bright sparks. Pack of 5.'),
      p('11', 'Rainbow Fountain Sky Shots (5 shots)', 'Fancy Shots', 450, 700, 4.5, 25,
          'Multi-shot fountain that sends colourful bursts into the sky. Pack of 5 shots.'),
      p('12', 'Fancy Multi Colour Shots (12 shots)', 'Fancy Shots', 850, 1350, 4.7, 30,
          'Aerial repeater cake with 12 colourful shots and a loud finale.'),
      p('13', 'Lakshmi Crackers Garland (100 wala)', 'Ground Crackers', 140, 220, 4.4, 110,
          'Traditional red garland string with 100 small crackers for the festival morning.'),
      p('14', 'Bijili Crackers Red (100 pcs)', 'Ground Crackers', 95, 150, 4.2, 140,
          'Classic red bijili crackers. Light one at a time in an open area.'),
      p('15', 'Pencil Crackers Kids Pack (10 pcs)', 'Kids Special', 80, 130, 4.3, 160,
          'Colourful pencil-shaped sparkle crackers made for kids, low noise. Adult supervision needed.'),
      p('16', 'Magic Pop Pop & Snake Tablets Pack', 'Kids Special', 60, 100, 4.1, 200,
          'Small fun pack with pop-pop and snake tablets for little ones. Adult supervision needed.'),
      p('17', 'Diwali Family Gift Box (50 items)', 'Gift Boxes', 999, 1599, 4.7, 40,
          'Assorted box with sparklers, flower pots, chakras and fountains for the whole family.'),
      p('18', 'Premium Gift Box (100 items)', 'Gift Boxes', 1899, 2999, 4.8, 8,
          'Our biggest combo pack: a wide range of sparklers, pots, rockets and chakras.'),
      p('19', 'Golden Rain Sparklers 50 cm (5 pcs)', 'Sparklers', 210, 320, 4.6, 85,
          'Extra long 50 cm sparklers that burn with a golden rain effect. Use under adult supervision.'),
      p('20', 'Mini Flower Pots Kids (10 pcs)', 'Flower Pots', 120, 190, 4.2, 130,
          'Small ground fountains with a low height, a good first pot for kids with an adult nearby.'),
      p('21', 'Giant Anar Pot Super (3 pcs)', 'Flower Pots', 390, 620, 4.7, 35,
          'Extra tall flower pot with a long shower of silver and gold sparks. Pack of 3.'),
      p('22', 'Bambara Rocket Colour Burst (5 pcs)', 'Rockets', 300, 480, 4.4, 45,
          'Sky rockets that burst into bright colours high above. Launch from an open ground only.'),
      p('23', 'Neon Chakkar Colour (10 pcs)', 'Chakras', 100, 170, 4.3, 150,
          'Colourful spinning ground wheels with a neon glow. Pack of 10.'),
      p('24', 'Peacock Dance Fancy Shots (7 shots)', 'Fancy Shots', 620, 980, 4.6, 28,
          'Seven colourful aerial shots that open like a peacock tail.'),
      p('25', 'Sky Thunder Cake (30 shots)', 'Fancy Shots', 1450, 2300, 4.8, 12,
          'Big 30-shot repeater cake with a loud and bright finale. Open ground only.'),
      p('26', 'Lakshmi Garland 1000 wala', 'Ground Crackers', 950, 1450, 4.5, 18,
          'Long traditional red garland with 1000 small crackers. Hang it high and light from a safe distance.'),
      p('27', 'Magic Fire Pencil Pack (20 pcs)', 'Kids Special', 140, 220, 4.3, 95,
          'Pencil-style sparkle crackers that glow in many colours. Low noise, adult supervision needed.'),
      p('28', 'Twinkling Star Pack (10 pcs)', 'Twinkling Stars', 85, 140, 4.4, 170,
          'Small star shaped crackers that shine and twinkle in different colours. Pack of 10.'),
      p('29', 'Silver Twinkling Star Big (5 pcs)', 'Twinkling Stars', 150, 240, 4.5, 70,
          'Bigger stars with a bright silver sparkle that lasts longer. Pack of 5.'),
      p('30', 'Colour Twinkling Star Deluxe (10 pcs)', 'Twinkling Stars', 190, 300, 4.6, 9,
          'Deluxe stars with red, green and gold sparkle. Pack of 10.'),
      p('31', 'Delux Sound Crackers (10 pcs)', 'Sound Crackers', 110, 170, 4.1, 125,
          'Loud sound crackers for the Diwali morning. Light one at a time in an open area.'),
      p('32', 'Thunder Crackers Pack (5 pcs)', 'Sound Crackers', 160, 250, 4.2, 65,
          'Extra loud thunder crackers with a long fuse. Keep children at a safe distance.'),
      p('33', 'Sound Crackers Mini (20 pcs)', 'Sound Crackers', 75, 120, 4.0, 0,
          'Small light-sound crackers in a pack of 20.'),
      p('34', 'Kids Fun Combo Box (30 items)', 'Mega Combo', 499, 799, 4.5, 50,
          'Safe and colourful mix of sparklers, pencils, twinkling stars and pop-pop for kids.'),
      p('35', 'Family Combo Box (60 items)', 'Mega Combo', 1299, 2099, 4.7, 22,
          'Mix of sparklers, flower pots, chakras, rockets and ground crackers for the whole family.'),
      p('36', 'Mega Diwali Combo Box (150 items)', 'Mega Combo', 2799, 4499, 4.9, 6,
          'Our largest Diwali box with every kind of cracker: pots, rockets, shots, stars, chakras and sparklers.'),
    ]);
  }

  // ----- customer -----
  int get cartCount => cart.fold(0, (s, i) => s + i.qty);
  double get cartTotal => cart.fold(0.0, (s, i) => s + i.total);

  void addToCart(Product product) {
    if (product.stock <= 0) return;
    final existing = cart.where((i) => i.product.id == product.id);
    if (existing.isEmpty) {
      cart.add(CartItem(product));
    } else if (existing.first.qty < product.stock) {
      existing.first.qty++;
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int delta) {
    final next = item.qty + delta;
    if (next <= 0) {
      cart.remove(item);
    } else if (next <= item.product.stock) {
      item.qty = next;
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  Order? placeOrder({required String name, required String address}) {
    if (cart.isEmpty || currentUser == null) return null;
    final items = cart.map((i) => CartItem(i.product, i.qty)).toList();
    for (final i in items) {
      i.product.stock = (i.product.stock - i.qty).clamp(0, 1 << 30);
    }
    final order = Order(
      id: 'VP${++_orderSeq}',
      customer: name,
      address: address,
      items: items,
      total: cartTotal,
      date: DateTime.now(),
      userEmail: currentUser!.email,
    );
    orders.insert(0, order);
    cart.clear();
    notifyListeners();
    return order;
  }

  // ----- admin -----
  double get revenue => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (s, o) => s + o.total);

  int get lowStockCount => products.where((p) => p.stock <= 10).length;

  void saveProduct(Product product) {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      products.insert(0, product);
    } else {
      products[index] = product;
    }
    notifyListeners();
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    cart.removeWhere((i) => i.product.id == id);
    notifyListeners();
  }

  void setStatus(Order order, OrderStatus status) {
    if (status == OrderStatus.cancelled && order.status != OrderStatus.cancelled) {
      for (final i in order.items) {
        i.product.stock += i.qty;
      }
    }
    order.status = status;
    notifyListeners();
  }
}

class StoreScope extends InheritedNotifier<Store> {
  const StoreScope({super.key, required Store store, required super.child})
      : super(notifier: store);

  static Store of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}

// ============================================================
// APP + SHOP SHELL
// ============================================================
class VediporulApp extends StatefulWidget {
  const VediporulApp({super.key});

  @override
  State<VediporulApp> createState() => _VediporulAppState();
}

class _VediporulAppState extends State<VediporulApp> {
  final Store _store = Store();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: _store,
      child: MaterialApp(
        title: 'Vediporul',
        debugShowCheckedModeBanner: false,
        theme: vediporulTheme(),
        home: const AppGate(),
      ),
    );
  }
}

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    const pages = [HomeScreen(), CartScreen(), OrdersScreen(), AccountScreen()];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: kOrange),
              label: 'Home'),
          NavigationDestination(
              icon: Badge.count(
                  count: store.cartCount,
                  isLabelVisible: store.cartCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined)),
              selectedIcon: Badge.count(
                  count: store.cartCount,
                  isLabelVisible: store.cartCount > 0,
                  child: const Icon(Icons.shopping_cart, color: kOrange)),
              label: 'Cart'),
          const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: kOrange),
              label: 'Orders'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kOrange),
              label: 'Account'),
        ],
      ),
    );
  }
}

// ============================================================
// LOGIN / SIGN UP (customer)
// ============================================================
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return store.entered ? const ShopShell() : const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _signUp = false;
  bool _hide = true;
  String? _error;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRe = RegExp(r'^[6-9]\d{9}$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final store = StoreScope.of(context);
    final err = _signUp
        ? store.signUp(
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            password: _password.text)
        : store.signIn(_email.text, _password.text);
    // On success the app moves to the shop by itself.
    if (err != null) setState(() => _error = err);
  }

  void _toggle() => setState(() {
        _signUp = !_signUp;
        _error = null;
        _password.clear();
        _confirm.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: VediporulLogo(size: 36)),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text('Sign in to enter the app',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    const SizedBox(height: 28),
                    Text(_signUp ? 'Create your account' : 'Welcome back',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    if (_signUp) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          _emailRe.hasMatch(v?.trim() ?? '') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 14),
                    if (_signUp) ...[
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Mobile number',
                          prefixText: '+91  ',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => _phoneRe.hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Enter a valid 10-digit mobile number',
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _password,
                      obscureText: _hide,
                      onFieldSubmitted: (_) {
                        if (!_signUp) _submit();
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText:
                            _signUp ? 'At least 8 characters with a letter and a number' : null,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: (v) {
                        final t = v ?? '';
                        if (t.isEmpty) return 'Enter your password';
                        if (!_signUp) return null;
                        if (t.length < 8 ||
                            !t.contains(RegExp(r'[A-Za-z]')) ||
                            !t.contains(RegExp(r'\d'))) {
                          return 'Use 8+ characters with a letter and a number';
                        }
                        return null;
                      },
                    ),
                    if (_signUp) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _hide,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) =>
                            v == _password.text ? null : 'Passwords do not match',
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_signUp ? 'Sign up' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _toggle,
                      child: Text(
                        _signUp
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                        style: const TextStyle(color: kOrange),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'One account per email and mobile number.\n'
                        'Demo login: demo@vediporul.com / demo1234',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final items = store.products.where((p) {
      final matchCat = _category == 'All' || p.category == _category;
      return matchCat && p.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const VediporulLogo(),
        actions: [
          IconButton(
            icon: Badge.count(
              count: store.cartCount,
              isLabelVisible: store.cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen(showBack: true)),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search Diwali crackers',
                  prefixIcon: Icon(Icons.search, color: kOrange),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: Store.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = Store.categories[i];
                  final sel = c == _category;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    selectedColor: kOrange,
                    backgroundColor: kCard,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color: sel ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _category = c),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _Banner()),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('No products found', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: .6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => ProductCard(product: items[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFFFF7A00), Color(0xFFFF4E00)]),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diwali Dhamaka Sale',
                    style: TextStyle(
                        color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Up to 40% off on crackers. Celebrate safely!',
                    style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          const Icon(Icons.celebration_rounded, size: 54, color: Colors.black87),
        ],
      ),
    );
  }
}

class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: kOrange, size: 16),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final out = product.stock <= 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product),
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: kOrange, borderRadius: BorderRadius.circular(6)),
                        child: Text('${product.discount}% OFF',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  RatingRow(rating: product.rating),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(money(product.price),
                          style: const TextStyle(
                              color: kOrange, fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(money(product.mrp),
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(34)),
                      onPressed: out
                          ? null
                          : () {
                              store.addToCart(product);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1)));
                            },
                      child: Text(out ? 'Out of stock' : 'Add to cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAIL
// ============================================================
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final out = product.stock <= 0;

    return Scaffold(
      appBar: AppBar(title: const VediporulLogo(size: 20)),
      body: ListView(
        children: [
          AspectRatio(aspectRatio: 1.1, child: ProductImage(product)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category.toUpperCase(),
                    style: const TextStyle(
                        color: kOrange,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                RatingRow(rating: product.rating),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(money(product.price),
                        style: const TextStyle(
                            color: kOrange, fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 10),
                    Text(money(product.mrp),
                        style: const TextStyle(
                            color: Colors.white38, decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 10),
                    if (product.discount > 0)
                      Text('${product.discount}% off',
                          style: const TextStyle(
                              color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  out
                      ? 'Currently unavailable'
                      : product.stock <= 10
                          ? 'Only ${product.stock} left in stock'
                          : 'In stock',
                  style: TextStyle(
                    color: out
                        ? Colors.redAccent
                        : product.stock <= 10
                            ? kOrange
                            : Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('About this item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(product.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kOrange.withOpacity(.4)),
                  ),
                  child: const Text(
                    'Safety: use outdoors in an open area under adult supervision, '
                    'keep water nearby, and light one item at a time.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: out
                      ? null
                      : () {
                          store.addToCart(product);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Added to cart')));
                        },
                  child: const Text('Add to cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: out
                      ? null
                      : () {
                          store.addToCart(product);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CartScreen(showBack: true)),
                          );
                        },
                  child: const Text('Buy now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CART + CHECKOUT
// ============================================================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.showBack = false});
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: Text('Your cart (${store.cartCount})'),
      ),
      body: store.cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.white24),
                  SizedBox(height: 12),
                  Text('Your cart is empty. Add some crackers!', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: store.cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CartTile(item: store.cart[i]),
            ),
      bottomNavigationBar: store.cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: kCard,
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.white54)),
                          Text(money(store.cartTotal),
                              style: const TextStyle(
                                  color: kOrange, fontSize: 22, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: ElevatedButton(
                        onPressed: () => _checkout(context),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _checkout(BuildContext context) {
    final store = StoreScope.of(context);
    final nameCtrl = TextEditingController(text: store.currentUser?.name ?? '');
    final addrCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 20, 16, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addrCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => (v == null || v.trim().length < 8)
                    ? 'Enter a full address'
                    : null,
              ),
              const SizedBox(height: 12),
              Text('Pay on delivery  •  Total ${money(store.cartTotal)}',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final order = store.placeOrder(
                    name: nameCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                  );
                  Navigator.pop(sheetCtx);
                  if (order != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order ${order.id} placed!')));
                  }
                },
                child: const Text('Place order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 80, height: 80, child: ProductImage(item.product)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(money(item.total),
                    style: const TextStyle(color: kOrange, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _QtyBtn(icon: Icons.remove, onTap: () => store.changeQty(item, -1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.qty}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _QtyBtn(icon: Icons.add, onTap: () => store.changeQty(item, 1)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white54),
                      onPressed: () => store.removeFromCart(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: kOrange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: kOrange),
      ),
    );
  }
}

// ============================================================
// ORDERS (customer) + shared OrderCard
// ============================================================
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    // Customers only see their own orders.
    final mine =
        store.orders.where((o) => o.userEmail == store.currentUser?.email).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Your orders')),
      body: mine.isEmpty
          ? const Center(
              child: Text('No orders yet', style: TextStyle(color: Colors.white54)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mine.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => OrderCard(order: mine[i]),
            ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.trailing});
  final Order order;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final d = order.date;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final color = statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel(order.status),
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order.customer}  •  $date',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          for (final i in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${i.qty} × ${i.product.name}',
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(money(i.total), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          const Divider(height: 20),
          Row(
            children: [
              const Text('Total', style: TextStyle(color: Colors.white54)),
              const Spacer(),
              Text(money(order.total),
                  style: const TextStyle(
                      color: kOrange, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          if (trailing != null) ...[const SizedBox(height: 10), trailing!],
        ],
      ),
    );
  }
}

// ============================================================
// ACCOUNT
// ============================================================
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final user = store.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: kOrange,
                  child: Icon(Icons.person, color: Colors.black, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user == null ? 'Welcome, guest' : 'Hello, ${user.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 6),
                      const VediporulLogo(size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(Icons.favorite_border, 'Wishlist', () {}),
          _tile(Icons.location_on_outlined, 'Saved addresses', () {}),
          _tile(Icons.help_outline, 'Help & support', () {}),
          _tile(
            user == null ? Icons.login : Icons.logout,
            user == null ? 'Sign in / Sign up' : 'Sign out',
            store.signOut,
          ),
          if (user?.isAdmin == true) ...[
            const SizedBox(height: 12),
            _tile(
              Icons.admin_panel_settings_outlined,
              'Admin panel',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminShell()),
              ),
              highlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: highlight ? Border.all(color: kOrange) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: kOrange),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// ADMIN: LOGIN
// Demo-only password. Use real authentication before going live.
// ============================================================
const _kAdminPassword = 'admin123';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController(text: 'admin@vediporul.com');
  final _password = TextEditingController();
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (_password.text == _kAdminPassword) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminShell()));
    } else {
      setState(() => _error = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                const VediporulLogo(size: 34),
                const SizedBox(height: 6),
                const Text('ADMIN PANEL',
                    style: TextStyle(
                        color: kOrange, letterSpacing: 3, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: _hide,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _error,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(onPressed: _login, child: const Text('Sign in')),
                const SizedBox(height: 14),
                const Text('Demo password: admin123',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN: SHELL
// ============================================================
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  static const _titles = ['Dashboard', 'Products', 'Orders'];

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    if (store.currentUser?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Access denied. Admins only.',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }
    final pending = store.orders.where((o) => o.status.index <= 1).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const VediporulLogo(size: 20),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration:
                  BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(6)),
              child: Text(_titles[_index].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Exit admin',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(onOpenOrders: () => setState(() => _index = 2)),
          const AdminProductsPage(),
          const AdminOrdersPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: kOrange),
              label: 'Dashboard'),
          const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: kOrange),
              label: 'Products'),
          NavigationDestination(
              icon: Badge.count(
                  count: pending,
                  isLabelVisible: pending > 0,
                  child: const Icon(Icons.receipt_long_outlined)),
              selectedIcon: Badge.count(
                  count: pending,
                  isLabelVisible: pending > 0,
                  child: const Icon(Icons.receipt_long, color: kOrange)),
              label: 'Orders'),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN: DASHBOARD
// ============================================================
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.onOpenOrders});
  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final recent = store.orders.take(5).toList();
    final lowStock = store.products.where((p) => p.stock <= 10).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
                icon: Icons.currency_rupee,
                label: 'Revenue',
                value: money(store.revenue),
                highlight: true),
            _StatCard(
                icon: Icons.receipt_long,
                label: 'Orders',
                value: '${store.orders.length}'),
            _StatCard(
                icon: Icons.inventory_2,
                label: 'Products',
                value: '${store.products.length}'),
            _StatCard(
                icon: Icons.warning_amber_rounded,
                label: 'Low stock',
                value: '${store.lowStockCount}'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('Recent orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: onOpenOrders,
              child: const Text('View all', style: TextStyle(color: kOrange)),
            ),
          ],
        ),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No orders yet. Place one from the shop to see it here.',
                style: TextStyle(color: Colors.white54)),
          ),
        for (final o in recent)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration:
                BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text('#${o.id}  •  ${o.customer}'),
              subtitle: Text(statusLabel(o.status),
                  style: TextStyle(color: statusColor(o.status))),
              trailing: Text(money(o.total),
                  style: const TextStyle(color: kOrange, fontWeight: FontWeight.w900)),
            ),
          ),
        const SizedBox(height: 16),
        const Text('Low stock alerts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (lowStock.isEmpty)
          const Text('All products are well stocked.',
              style: TextStyle(color: Colors.white54)),
        for (final p in lowStock)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration:
                BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 44, height: 44, child: ProductImage(p)),
              ),
              title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(p.stock == 0 ? 'Out' : '${p.stock} left',
                  style: TextStyle(
                      color: p.stock == 0 ? Colors.redAccent : kOrange,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final IconData icon;
  final String label, value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? kOrange : kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: highlight ? Colors.black : kOrange),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(value,
                    style: TextStyle(
                        color: highlight ? Colors.black : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
              ),
              Text(label,
                  style: TextStyle(
                      color: highlight ? Colors.black87 : Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN: PRODUCTS
// ============================================================
class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kOrange,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add product', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
        ),
      ),
      body: store.products.isEmpty
          ? const Center(
              child: Text('No products. Add your first one!',
                  style: TextStyle(color: Colors.white54)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: store.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = store.products[i];
                return Container(
                  decoration:
                      BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                            width: 64, height: 64, child: ProductImage(p)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${p.category}  •  ${money(p.price)}',
                                style: const TextStyle(
                                    color: kOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            Text(p.stock == 0 ? 'Out of stock' : 'Stock: ${p.stock}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: p.stock <= 10
                                        ? Colors.redAccent
                                        : Colors.white54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: kOrange),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductFormScreen(product: p)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, store, p),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Store store, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Delete product?'),
        content: Text('"${p.name}" will be removed from Vediporul.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok == true) store.deleteProduct(p.id);
  }
}

// ============================================================
// ADMIN: ADD / EDIT PRODUCT
// ============================================================
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Product? product; // null = add new

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _desc, _image, _price, _mrp, _stock;
  late String _category;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price.round()}');
    _mrp = TextEditingController(text: p == null ? '' : '${p.mrp.round()}');
    _stock = TextEditingController(text: p == null ? '' : '${p.stock}');
    _category = p?.category ?? Store.categories[1];
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _image, _price, _mrp, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _number(String? v) =>
      (v == null || double.tryParse(v.trim()) == null) ? 'Enter a number' : null;

  void _save() {
    if (!_form.currentState!.validate()) return;
    final store = StoreScope.of(context);
    final price = double.parse(_price.text.trim());
    final mrp = double.parse(_mrp.text.trim());
    final id = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final image = _image.text.trim();

    store.saveProduct(Product(
      id: id,
      name: _name.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      imageUrl: image,
      price: price,
      mrp: mrp < price ? price : mrp,
      rating: widget.product?.rating ?? 4.0,
      stock: int.parse(_stock.text.trim()),
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editing ? 'Product updated' : 'Product added')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit product' : 'Add product')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Product name'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: kCard,
              decoration: const InputDecoration(labelText: 'Category'),
              items: Store.categories
                  .skip(1)
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₹)'),
                    validator: _number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mrp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'MRP (₹)'),
                    validator: _number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock quantity'),
              validator: (v) => (v == null || int.tryParse(v.trim()) == null)
                  ? 'Enter a whole number'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _image,
              decoration: const InputDecoration(
                  labelText: 'Image URL or asset path (optional)',
                  helperText:
                      'Web link, or assets/crackers/name.jpg. Leave empty for built-in artwork'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: _required,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _save,
              child: Text(_editing ? 'Save changes' : 'Add product'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN: ORDERS
// ============================================================
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final orders =
        store.orders.where((o) => _filter == null || o.status == _filter).toList();

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            children: [
              _chip('All', _filter == null, () => setState(() => _filter = null)),
              for (final s in OrderStatus.values)
                _chip(statusLabel(s), _filter == s, () => setState(() => _filter = s)),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Text('No orders here', style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return OrderCard(
                      order: o,
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ship to: ${o.address}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<OrderStatus>(
                            value: o.status,
                            dropdownColor: kCard,
                            decoration: const InputDecoration(
                                labelText: 'Update status', isDense: true),
                            items: OrderStatus.values
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(statusLabel(s),
                                          style: TextStyle(color: statusColor(s))),
                                    ))
                                .toList(),
                            onChanged: (s) {
                              if (s != null) store.setStatus(o, s);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: kOrange,
        backgroundColor: kCard,
        side: BorderSide.none,
        labelStyle: TextStyle(
            color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w600),
        onSelected: (_) => onTap(),
      ),
    );
  }
}