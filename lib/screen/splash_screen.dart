import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initLocationProcess();
  }

  Future<void> _initLocationProcess() async {
    bool permissionGranted = await _requestLocationPermission();
    if (!permissionGranted) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', position.latitude);
    await prefs.setDouble('longitude', position.longitude);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset('assets/icon/app_icon.png'),
        ),
      ),
    );
  }
}
