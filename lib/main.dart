import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:heavy_assistant/screen/splash_screen.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '1uoi9f7ytt');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}
