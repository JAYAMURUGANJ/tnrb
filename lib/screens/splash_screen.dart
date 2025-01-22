import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tnrb/utils/constant.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Display splash screen for a short duration
      await Future.delayed(const Duration(seconds: 2));

      // Request required permissions
      final permissionsGranted = await _requestPermissions();
      if (permissionsGranted) {
        // Check login status and navigate accordingly
        final isLoggedIn = await _checkLoginStatus();
        _navigateToNextScreen(isLoggedIn);
      } else {
        // Show permission denied dialog
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _showInitializationErrorDialog();
    }
  }

  Future<bool> _requestPermissions() async {
    // Request camera permission
    final cameraPermission = await Permission.camera.request();

    if (cameraPermission.isPermanentlyDenied) {
      // Open app settings if the permission is permanently denied
      await openAppSettings();
    }

    // Return true if camera permission is granted
    return cameraPermission.isGranted;
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  void _navigateToNextScreen(bool isLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Camera permission is necessary for the app to function. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInitializationErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: const Text(
          'An error occurred during app initialization. Please restart the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: const ValueKey('app-logo'),
              child: Image.asset(
                Assets.logo,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'TNRB\nQR Scanner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Loading indicator
          ],
        ),
      ),
    );
  }
}
