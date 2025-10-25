import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String image;
  final double price; // unit price
  int quantity;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}

double parsePrice(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }
  return 0;
}

class CartService extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);
  int get itemCount => _items.length;
  double get total => _items.values.fold(0, (sum, i) => sum + i.subtotal);

  void addItem(Map<String, dynamic> menuItem) {
    final String name = menuItem['name'] as String;
    final String image = (menuItem['image'] as String?) ?? '';
    final double price = parsePrice(menuItem['price']);

    if (_items.containsKey(name)) {
      _items[name]!.quantity += 1;
    } else {
      _items[name] = CartItem(name: name, image: image, price: price);
    }
    notifyListeners();
  }

  void increment(String name) {
    final item = _items[name];
    if (item == null) return;
    item.quantity += 1;
    notifyListeners();
  }

  void decrement(String name) {
    final item = _items[name];
    if (item == null) return;
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(name);
    }
    notifyListeners();
  }

  void remove(String name) {
    _items.remove(name);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final CartService cartService = CartService();
