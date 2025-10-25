import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/services/order_service.dart';
import 'package:mobile/services/session_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _dineIn = true;

  void _cartListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    cartService.addListener(_cartListener);
  }

  @override
  void dispose() {
    cartService.removeListener(_cartListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF0038A8);
    final items = cartService.items;

    String money(double v) => '₱${v.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: blue,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Table ${sessionService.tableNumber}', 
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Dine-in / Takeout toggle
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Container(
            //     padding: const EdgeInsets.all(4),
            //     decoration: BoxDecoration(
            //       color: Colors.white.withOpacity(0.2),
            //       borderRadius: BorderRadius.circular(22),
            //     ),
            //     child: Row(
            //       children: [
            //         _ModePill(
            //           label: 'Dine in',
            //           selected: _dineIn,
            //           onTap: () => setState(() => _dineIn = true),
            //         ),
            //         _ModePill(
            //           label: 'Takeout',
            //           selected: !_dineIn,
            //           onTap: () => setState(() => _dineIn = false),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),

            // White rounded panel
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Your Cart',
                        style: GoogleFonts.poppins(
                          color: blue,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: items.isEmpty
                          ? _EmptyCart(blue: blue)
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _CartRow(
                                  item: item,
                                  onRemove: () => cartService.remove(item.name),
                                  onMinus: () =>
                                      cartService.decrement(item.name),
                                  onPlus: () =>
                                      cartService.increment(item.name),
                                  blue: blue,
                                  money: money,
                                );
                              },
                              separatorBuilder: (_, __) => const Divider(),
                              itemCount: items.length,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton.icon(
                        onPressed: () {
                          // Return to menu to add more items
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.menu,
                          );
                        },
                        icon: Icon(Icons.add, color: Colors.grey[600]),
                        label: Text(
                          'Add more items',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              color: blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            money(cartService.total),
                            style: GoogleFonts.poppins(
                              color: blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                          try {
                            final rawName = sessionService.customerName;
                            final name = (rawName == null || rawName.trim().isEmpty)
                                ? 'Guest'
                                : rawName.trim();
                            // Brief confirmation first
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Placing order...')),
                              );
                            }
                            orderService.createOrder(
                              customerName: name,
                              cartItems: List.of(items),
                            );
                            // Navigate to Orders screen via root navigator
                            if (!mounted) return;
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacementNamed(AppRoutes.orders);
                            // Clear the cart after navigating
                            cartService.clear();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to place order: $e')),
                              );
                            }
                          }
                        },
                  child: Text(
                    'Place Order',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: selected ? const Color(0xFF0038A8) : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Color blue;
  final String Function(double) money;

  const _CartRow({
    required this.item,
    required this.onRemove,
    required this.onMinus,
    required this.onPlus,
    required this.blue,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  color: blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SquareButton(icon: Icons.delete_outline, onTap: onRemove),
                  const SizedBox(width: 8),
                  _SquareButton(icon: Icons.remove, onTap: onMinus),
                  const SizedBox(width: 8),
                  Text('${item.quantity}', style: GoogleFonts.poppins()),
                  const SizedBox(width: 8),
                  _SquareButton(icon: Icons.add, onTap: onPlus),
                ],
              ),
            ],
          ),
        ),
        Text(
          money(item.subtotal),
          style: GoogleFonts.poppins(color: blue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade700),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final Color blue;
  const _EmptyCart({required this.blue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: blue.withOpacity(0.8),
          ),
          const SizedBox(height: 10),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
