import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/cart_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _menuItems = [];

  // Fallback images for known items to preserve the visual design
  static const Map<String, String> _imageMap = {
    'Soda': 'https://truefoodfact.com/wp-content/uploads/2020/08/Soda.jpg',
    'Burger':
        'https://assets.epicurious.com/photos/5c745a108918ee7ab68daf79/1:1/w_1920,c_limit/Smashburger-recipe-120219.jpg',
    'Pizza':
        'https://kitchenswagger.com/wp-content/uploads/2023/05/margherita-pizza-final.jpg',
    'Fries':
        'https://thesaltedpotato.com/wp-content/uploads/elementor/thumbs/twice-fried-fries-r5iw2utg66f3cxdkbpzpbtoa3lnsvtuv13yrmgr1l0.webp',
    'Pasta Carbonara':
        'https://www.willcookforsmiles.com/wp-content/uploads/2024/02/Chicken-Alfredo-in-the-pan-done-768x1152.jpg',
    'Caesar Salad':
        'https://www.onceuponachef.com/images/2010/08/Homemade-Caesar-Salad-Dressing-760x887.jpg',
    'Garlic Bread':
        'https://www.ambitiouskitchen.com/wp-content/uploads/2023/02/Garlic-Bread-4-750x750.jpg',
    'Iced Tea':
        'https://leftoversthenbreakfast.com/wp-content/uploads/2022/10/lemon-iced-tea-1200x1800-1-720x1080.jpeg',
    'Chocolate Cake':
        'https://i.pinimg.com/736x/2d/f0/3d/2df03d5a1ba624b07528d2e5e45da701.jpg',
    'Ice Cream Sundae':
        'https://cookienameddesire.com/wp-content/uploads/2018/05/brownie-sundae.jpg',
    'Grilled Chicken':
        'https://joyfullymad.com/wp-content/uploads/2023/08/grilled-chicken-salad-5-720x1080.jpg',
    'Fish and Chips':
        'https://images.getrecipekit.com/20220707143834-atlantic_cod_fish_chips_recipe_1024x1024.webp?class=16x9',
    'Coffee':
        'https://www.cookingclassy.com/wp-content/uploads/2022/07/iced-coffee-05-768x1152.jpg',
    'Milkshake':
        'https://cookienameddesire.com/wp-content/uploads/2019/06/bacon-milkshake-5-720x1087.jpg',
    'Steak':
        'https://www.cookingclassy.com/wp-content/uploads/2022/07/grilled-steak-15-768x1152.jpg',
    'Onion Rings':
        'https://therecipecritic.com/wp-content/uploads/2023/01/air-fryer-frozen-onion-rings-1-750x1000.jpg',
  };

  @override
  void initState() {
    super.initState();
    _fetchMenuFromApi();
  }

  String _formatPrice(dynamic value) {
    final double numPrice = parsePrice(value);
    return '₱' + numPrice.toStringAsFixed(2);
  }

  Map<String, dynamic> _ensureItemShape(Map<String, dynamic> raw) {
    final String name = (raw['name'] ?? '').toString();
    final String image = (() {
      final dynamic incoming = raw['image'];
      if (incoming is String && incoming.trim().isNotEmpty) return incoming;
      return _imageMap[name] ??
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836';
    })();
    return {
      'id': raw['id'],
      'name': name,
      'category': (raw['category'] ?? '').toString(),
      'price': _formatPrice(raw['price']),
      'description': (raw['description'] ?? '').toString(),
      'isAvailable': (raw['available'] ?? true) == true,
      'image': image,
    };
  }

  Future<void> _fetchMenuFromApi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/menu');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          final items = decoded
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .map<Map<String, dynamic>>(_ensureItemShape)
              .toList(growable: false);
          if (!mounted) return;
          setState(() {
            _menuItems = items;
            _isLoading = false;
          });
        } else {
          throw const FormatException('Unexpected response shape');
        }
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load menu: $e';
      });
    }
  }

  // Measure text width for underline sizing
  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'All'},
      {'name': 'Appetizers'},
      {'name': 'Main Course'},
      {'name': 'Sides'},
      {'name': 'Beverages'},
      {'name': 'Desserts'},
    ];

    final List<Map<String, dynamic>> menuItems = [
      {
        'name': 'Soda',
        'price': '₱80.00',
        'category': 'Beverages',
        'description': 'Refreshing soft drink',
        'isAvailable': true,
        'image': 'https://truefoodfact.com/wp-content/uploads/2020/08/Soda.jpg',
      },
      {
        'name': 'Burger',
        'price': '₱250.00',
        'category': 'Main Course',
        'description':
            'Juicy beef patty with cheddar, lettuce, tomato, and our house sauce.',
        'isAvailable': true,
        'image':
            'https://assets.epicurious.com/photos/5c745a108918ee7ab68daf79/1:1/w_1920,c_limit/Smashburger-recipe-120219.jpg',
      },
      {
        'name': 'Pizza',
        'price': '₱350.00',
        'category': 'Main Course',
        'description':
            'Wood-fired pizza with fresh mozzarella, basil, and tomato sauce.',
        'isAvailable': true,
        'image':
            'https://kitchenswagger.com/wp-content/uploads/2023/05/margherita-pizza-final.jpg',
      },
      {
        'name': 'Fries',
        'price': '₱250.00',
        'category': 'Sides',
        'description': 'Crispy golden fries.',
        'isAvailable': true,
        'image':
            'https://thesaltedpotato.com/wp-content/uploads/elementor/thumbs/twice-fried-fries-r5iw2utg66f3cxdkbpzpbtoa3lnsvtuv13yrmgr1l0.webp',
      },
      {
        'name': 'Pasta Carbonara',
        'price': '₱350.00',
        'category': 'Main Course',
        'description': 'Creamy pasta with bacon and parmesan.',
        'isAvailable': true,
        'image':
            'https://www.willcookforsmiles.com/wp-content/uploads/2024/02/Chicken-Alfredo-in-the-pan-done-768x1152.jpg',
      },
      {
        'name': 'Caesar Salad',
        'price': '₱169.00',
        'category': 'Appetizers',
        'description':
            'Crisp romaine with Caesar dressing, croutons, and parmesan.',
        'isAvailable': true,
        'image':
            'https://www.onceuponachef.com/images/2010/08/Homemade-Caesar-Salad-Dressing-760x887.jpg',
      },
      {
        'name': 'Garlic Bread',
        'price': '₱99.00',
        'category': 'Sides',
        'description': 'Toasted bread with garlic butter',
        'isAvailable': true,
        'image':
            'https://www.ambitiouskitchen.com/wp-content/uploads/2023/02/Garlic-Bread-4-750x750.jpg',
      },
      {
        'name': 'Iced Tea',
        'price': '₱79.00',
        'category': 'Beverages',
        'description': 'Refreshing iced tea with a zesty lemon twist.',
        'isAvailable': true,
        'image':
            'https://leftoversthenbreakfast.com/wp-content/uploads/2022/10/lemon-iced-tea-1200x1800-1-720x1080.jpeg',
      },
      {
        'name': 'Chocolate Cake',
        'price': '₱250.00',
        'category': 'Desserts',
        'description': 'Rich chocolate layer cake',
        'isAvailable': true,
        'image':
            'https://i.pinimg.com/736x/2d/f0/3d/2df03d5a1ba624b07528d2e5e45da701.jpg',
      },
      {
        'name': 'Ice Cream Sundae',
        'price': '₱150.00',
        'category': 'Desserts',
        'description': 'Vanilla ice cream with toppings',
        'isAvailable': true,
        'image':
            'https://cookienameddesire.com/wp-content/uploads/2018/05/brownie-sundae.jpg',
      },
      {
        'name': 'Grilled Chicken',
        'price': '₱350.00',
        'category': 'Main Course',
        'description': 'Tender grilled chicken breast with herbs',
        'isAvailable': true,
        'image':
            'https://joyfullymad.com/wp-content/uploads/2023/08/grilled-chicken-salad-5-720x1080.jpg',
      },
      {
        'name': 'Fish and Chips',
        'price': '₱400.00',
        'category': 'Main Course',
        'description': 'Refreshing soft drink',
        'isAvailable': true,
        'image':
            'https://images.getrecipekit.com/20220707143834-atlantic_cod_fish_chips_recipe_1024x1024.webp?class=16x9',
      },
      {
        'name': 'Coffee',
        'price': '₱100.00',
        'category': 'Beverages',
        'description': 'Freshly brewed coffee',
        'isAvailable': true,
        'image':
            'https://www.cookingclassy.com/wp-content/uploads/2022/07/iced-coffee-05-768x1152.jpg',
      },
      {
        'name': 'Milkshake',
        'price': '₱200.00',
        'category': 'Beverages',
        'description': 'Creamy vanilla milkshake',
        'isAvailable': true,
        'image':
            'https://cookienameddesire.com/wp-content/uploads/2019/06/bacon-milkshake-5-720x1087.jpg',
      },
      {
        'name': 'Steak',
        'price': '450.00',
        'category': 'Main Course',
        'description': 'Premium ribeye steak cooked to perfection',
        'isAvailable': true,
        'image':
            'https://www.cookingclassy.com/wp-content/uploads/2022/07/grilled-steak-15-768x1152.jpg',
      },
      {
        'name': 'Onion Rings',
        'price': '₱200.00',
        'category': 'Sides',
        'description': 'Crispy golden onion rings',
        'isAvailable': true,
        'image':
            'https://therecipecritic.com/wp-content/uploads/2023/01/air-fryer-frozen-onion-rings-1-750x1000.jpg',
      },
    ];

    // Filtered list based on selected category
    final List<Map<String, dynamic>> filteredFromApi = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems
            .where((item) => item['category'] == _selectedCategory)
            .toList();

    // Fallback to hardcoded list if API not loaded
    final List<Map<String, dynamic>> filteredFromHardcoded = _selectedCategory == 'All'
        ? menuItems
        : menuItems
            .where((item) => item['category'] == _selectedCategory)
            .toList();

    final List<Map<String, dynamic>> filteredItems =
        _menuItems.isNotEmpty ? filteredFromApi : filteredFromHardcoded;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Menu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0038A8),
        elevation: 0,
        toolbarHeight: 88,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.customerNameScreen,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cart);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0038A8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            'View Your Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF0038A8),
        child: Column(
          children: [
            // Categories horizontal scroll
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = categories[index]['name'];
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              final String label = categories[index]['name'];
                              final bool isSelected =
                                  _selectedCategory == label;
                              final TextStyle textStyle = TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              );
                              final double lineWidth = _measureTextWidth(
                                label,
                                textStyle,
                              );

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(label, style: textStyle),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 3,
                                    width: lineWidth,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Menu items grid inside rounded white panel
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: _buildMenuContent(filteredItems),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(List<Map<String, dynamic>> filteredItems) {
    if (_isLoading && _menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _menuItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchMenuFromApi,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0038A8)),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.menuDetail,
              arguments: item,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image area expands to fill available height
              Expanded(
                child: Hero(
                  tag: 'menu-item-${item['name']}',
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox.expand(
                          child: Image.network(
                            item['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            cartService.addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, size: 18, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Centered item name
              Text(
                item['name'],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Color(0xFF0038A8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
