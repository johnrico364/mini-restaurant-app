import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile/services/order_service.dart';
import 'package:mobile/routes/app_routes.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _ErrorReload extends StatelessWidget {
  final Color blue;
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorReload({
    required this.blue,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final Color blue;
  const _OrderDetailsSheet({required this.order, required this.blue});

  String money(double v) => '₱' + v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: GoogleFonts.poppins(
                            color: blue,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customer: ${order.customerName}',
                          style: GoogleFonts.poppins(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      order.status.isEmpty ? 'Completed' : order.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: order.status.toLowerCase().contains('pend')
                        ? Colors.orange
                        : order.status.toLowerCase().contains('progress')
                        ? Colors.blue
                        : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Items',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: blue,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${i.quantity} × ${i.name}',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      Text(
                        money(i.subtotal),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      color: blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    money(order.totalAmount),
                    style: GoogleFonts.poppins(
                      color: blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: jsonEncode(order.toJson()),
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Show this QR to staff to verify your order',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersScreenState extends State<OrdersScreen> {
  void _ordersListener() => setState(() {});
  bool _loading = true;
  String? _error;
  List<Order> _remoteOrders = const [];

  Future<void> _loadRemote() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await orderService.fetchRemoteOrders();
      if (!mounted) return;
      setState(() {
        _remoteOrders = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load orders: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    orderService.addListener(_ordersListener);
    _loadRemote();
  }

  @override
  void dispose() {
    orderService.removeListener(_ordersListener);
    super.dispose();
  }

  String money(double v) => '₱' + v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF0038A8);
    final localOrders = orderService.orders;
    final hasLocal = localOrders.isNotEmpty;
    final combined = hasLocal
        ? [...localOrders, ..._remoteOrders]
        : _remoteOrders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Orders',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F3F5),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading && combined.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null && combined.isEmpty
            ? _ErrorReload(blue: blue, message: _error!, onRetry: _loadRemote)
            : combined.isEmpty
            ? _EmptyOrders(blue: blue)
            : RefreshIndicator(
                onRefresh: _loadRemote,
                child: _OrdersList(orders: combined, blue: blue),
              ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Order> orders;
  final Color blue;
  const _OrdersList({required this.orders, required this.blue});

  String money(double v) => '₱' + v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _OrderDetailsSheet(order: order, blue: blue),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Number',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.id}',
                            style: GoogleFonts.poppins(
                              color: blue,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        (order.status.isEmpty ? 'Completed' : order.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          order.status.toLowerCase().contains('pend')
                          ? Colors.orange
                          : order.status.toLowerCase().contains('progress')
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Name',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: GoogleFonts.poppins(
                              color: blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total Amount',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            money(order.totalAmount),
                            style: GoogleFonts.poppins(
                              color: blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // QR code area
                    QrImageView(
                      data: jsonEncode(order.toJson()),
                      version: QrVersions.auto,
                      size: 110,
                      eyeStyle: const QrEyeStyle(color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                        color: Colors.black,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.menu),
                  icon: Icon(Icons.add, color: blue),
                  label: Text(
                    'Add Order',
                    style: GoogleFonts.poppins(
                      color: blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final Color blue;
  const _EmptyOrders({required this.blue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 48, color: blue.withOpacity(0.8)),
          const SizedBox(height: 10),
          Text(
            'No orders yet',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.menu),
            icon: const Icon(Icons.add),
            label: const Text('Create your first order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
