import 'package:flutter/material.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'package:mobile/services/session_service.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> with WidgetsBindingObserver {
  // MobileScanner controller to manage camera lifecycle
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    // Handle hot reload: stop on Android first, then start to refresh preview
    if (Platform.isAndroid) {
      controller.stop();
    }
    controller.start();
  }

  // Handle app lifecycle to properly stop/start camera
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      controller.start();
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!mounted || !isScanning) return;
    final barcodes = capture.barcodes;
    final String? code = barcodes.isNotEmpty ? barcodes.first.rawValue : null;
    if (code == null) return;

    setState(() {
      isScanning = false;
    });

    await controller.stop();

    if (!mounted) return;

    // Show a snackbar with the scanned data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanned: $code')),
    );

    // Navigate to menu screen and reset scanning when returning
    Navigator.pushNamed(context, AppRoutes.menu).then((_) async {
      if (!mounted) return;
      setState(() {
        isScanning = true;
      });
      await controller.start();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableText = sessionService.tableNumber != null
        ? 'Table ${sessionService.tableNumber}'
        : 'Table';
    return Scaffold(
      appBar: AppBar(title: Text(tableText)),
      body: Container(
        color: const Color(0xFF0038A8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scan the QR code to view the menu',
                style: GoogleFonts.jomolhari(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // QR Code Scanner
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Stop camera before navigating away
                  await controller.stop();
                  if (!mounted) return;

                  // Navigate to menu screen directly and resume when back
                  Navigator.pushNamed(context, AppRoutes.menu).then((_) async {
                    if (!mounted) return;
                    setState(() {
                      isScanning = true;
                    });
                    await controller.start();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0038A8),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('View Menu Directly', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
    }
}
