import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'model/visitor.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VisitorAdapter()); // Initialize Hive
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.blueTheme,
      home: const SplashScreen(),
    );
  }
}
