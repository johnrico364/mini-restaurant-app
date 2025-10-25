import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/session_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerNameScreen extends StatefulWidget {
  const CustomerNameScreen({Key? key}) : super(key: key);

  @override
  _CustomerNameScreenState createState() => _CustomerNameScreenState();
}

class _CustomerNameScreenState extends State<CustomerNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0038A8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please enter your name',
                style: GoogleFonts.jomolhari(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                cursorColor: Colors.white, // white blinking cursor
                style: const TextStyle(color: Colors.white), // white text
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ), // white label
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white,
                    ), // white border when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ), // white border when focused
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your name')),
                      );
                      return;
                    }

                    // Persist customer name in session
                    sessionService.setCustomerName(name);

                    // Show lightweight feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Looking up your table...')),
                    );

                    int? resolvedTable;
                    try {
                      // 1) Try reservations lookup
                      const reservationsUrl =
                          'https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/reservations';
                      final res = await http
                          .get(Uri.parse(reservationsUrl))
                          .timeout(const Duration(seconds: 10));
                      if (res.statusCode == 200) {
                        final decoded = jsonDecode(res.body);
                        if (decoded is List) {
                          Map<String, dynamic>? matchMap;
                          for (final e in decoded) {
                            if (e is Map) {
                              final m = e.map((k, v) => MapEntry(k.toString(), v));
                              final n = (m['customerName'] ?? m['name'] ?? '').toString();
                              if (n.toLowerCase().trim() == name.toLowerCase().trim()) {
                                matchMap = m;
                                break;
                              }
                            }
                          }
                          if (matchMap != null) {
                            resolvedTable = _extractTableNumber(matchMap);
                          }
                        }
                      }

                      // 2) If no reservation match, try available table
                      if (resolvedTable == null) {
                        const tablesUrl =
                            'https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/tables';
                        final res2 = await http
                            .get(Uri.parse(tablesUrl))
                            .timeout(const Duration(seconds: 10));
                        if (res2.statusCode == 200) {
                          final decoded2 = jsonDecode(res2.body);
                          if (decoded2 is List) {
                            for (final t in decoded2) {
                              if (t is Map) {
                                final map = t.map((k, v) => MapEntry(k.toString(), v));
                                final status = (map['status'] ?? '').toString().toLowerCase();
                                if (status.contains('available')) {
                                  resolvedTable = _extractTableNumber(map);
                                  break;
                                }
                              }
                            }
                          }
                        }
                      }
                    } catch (e) {
                      // Ignore network errors but log to console
                      // We'll still navigate; table may remain null
                      // and QR screen can show generic title
                      // print('Lookup error: $e');
                    }

                    // Save table number (if any)
                    sessionService.setTableNumber(resolvedTable);

                    // Navigate to QR screen
                    if (!mounted) return;
                    Navigator.pushNamed(context, AppRoutes.qrCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.jomolhari(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0038A8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper to extract an integer table number from a flexible map shape
int? _extractTableNumber(Map<String, dynamic> m) {
  final candidates = [
    m['tableNumber'],
    m['table_no'],
    m['table'],
    m['number'],
    m['id'],
  ];
  for (final c in candidates) {
    if (c == null) continue;
    if (c is num) return c.toInt();
    final parsed = int.tryParse(c.toString());
    if (parsed != null) return parsed;
  }
  return null;
}
