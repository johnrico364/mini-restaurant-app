import 'package:flutter/foundation.dart';
import 'package:mobile/services/cart_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price; // unit price

  OrderItem({required this.name, required this.quantity, required this.price});

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'subtotal': subtotal,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final dynamic q = map['quantity'];
    final dynamic p = map['price'];
    return OrderItem(
      name: (map['name'] ?? '').toString(),
      quantity: q is num ? q.toInt() : int.tryParse(q?.toString() ?? '0') ?? 0,
      price: p is num ? p.toDouble() : double.tryParse(p?.toString() ?? '0') ?? 0.0,
    );
  }
}

class Order {
  final int id;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // e.g. 'Completed', 'Pending'
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'items': items.map((i) => i.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List?) ?? const [];
    final items = itemsList
        .whereType<Map>()
        .map((m) => OrderItem.fromMap(m.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
    final dynamic total = map['totalAmount'];
    final String created = (map['createdAt'] ?? DateTime.now().toIso8601String()).toString();
    final dynamic idVal = map['id'];
    return Order(
      id: idVal is num ? idVal.toInt() : int.tryParse(idVal?.toString() ?? '0') ?? 0,
      customerName: (map['customerName'] ?? '').toString(),
      items: items,
      totalAmount: total is num ? total.toDouble() : double.tryParse(total?.toString() ?? '0') ?? 0.0,
      status: (map['status'] ?? 'Completed').toString(),
      createdAt: DateTime.tryParse(created) ?? DateTime.now(),
    );
  }
}

class OrderService extends ChangeNotifier {
  final List<Order> _orders = [];
  int _nextId = 1;
  static const String _ordersApi =
      'https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/orders';
  static const String _prefsKeyOrders = 'orders_v1';

  List<Order> get orders => List.unmodifiable(_orders);

  Order createOrder({
    required String customerName,
    required List<CartItem> cartItems,
    String status = 'Completed',
  }) {
    final items = cartItems
        .map((c) => OrderItem(name: c.name, quantity: c.quantity, price: c.price))
        .toList(growable: false);
    final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);
    final order = Order(
      id: _nextId++,
      customerName: customerName,
      items: items,
      totalAmount: total,
      status: status,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order); // newest first
    notifyListeners();
    // Persist in background
    saveToLocalStorage();
    return order;
  }

  // Best-effort POST; my-json-server may be read-only, so this can fail gracefully
  Future<void> tryPostOrder(Order order) async {
    try {
      final res = await http
          .post(
            Uri.parse(_ordersApi),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // success (ignored body)
      }
    } catch (_) {
      // ignore network errors; keep local state so UI remains responsive
    }
  }

  Future<List<Order>> fetchRemoteOrders() async {
    final res = await http
        .get(Uri.parse(_ordersApi))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => Order.fromMap(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList(growable: false);
      }
      return const [];
    } else {
      throw Exception('HTTP ${res.statusCode}');
    }
  }

  void clear() {
    _orders.clear();
    _nextId = 1;
    notifyListeners();
    saveToLocalStorage();
  }

  Future<void> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKeyOrders);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final loaded = decoded
            .whereType<Map>()
            .map((m) => Order.fromMap(m.map((k, v) => MapEntry(k.toString(), v))))
            .toList(growable: false);
        _orders
          ..clear()
          ..addAll(loaded);
        // set next ID to max(existing)+1
        int maxId = 0;
        for (final o in _orders) {
          if (o.id > maxId) maxId = o.id;
        }
        _nextId = maxId + 1;
        notifyListeners();
      }
    } catch (_) {
      // ignore local load errors
    }
  }

  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _orders.map((o) => o.toJson()).toList(growable: false);
      await prefs.setString(_prefsKeyOrders, jsonEncode(data));
    } catch (_) {
      // ignore local save errors
    }
  }
}

final OrderService orderService = OrderService();
