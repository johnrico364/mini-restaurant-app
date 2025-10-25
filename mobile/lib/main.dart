import 'package:flutter/material.dart';
import 'package:mobile/screens/customer/customer_name.dart';
import 'package:mobile/screens/qrcode/qrcode.dart';
import 'package:mobile/screens/menu/menu.dart';
import 'package:mobile/screens/menu/menu_detail_screen.dart';
import 'package:mobile/screens/cart/cart_screen.dart';
import 'package:mobile/screens/orders/orders_screen.dart';
import 'routes/app_routes.dart';
import 'package:mobile/services/order_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await orderService.loadFromLocalStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Menu & Ordering',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 👇 This is the key part
      initialRoute: AppRoutes.customerNameScreen,

      routes: {
        AppRoutes.customerNameScreen: (context) => const CustomerNameScreen(),
        AppRoutes.qrCode: (context) => const QRCodeScreen(),
        AppRoutes.menu: (context) => const MenuScreen(),
        AppRoutes.menuDetail: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return MenuDetailScreen(menuItem: args);
        },
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.orders: (context) => const OrdersScreen(),
      },
    );
  }
}
