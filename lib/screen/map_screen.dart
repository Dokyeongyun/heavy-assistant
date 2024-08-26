import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = Logger();

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? mapController;
  Position? currentLocation;
  double defaultLatitude = 37.5664056;
  double defaultLongitude = 126.9778222;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<Position?> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    logger
        .i("[getCurrentLocation] Current permission status: $permissionStatus");
    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        logger.i("[getCurrentLocation] Current location: $position");
        setState(() {
          currentLocation = position;
        });
        return position;
      } catch (e) {
        Fluttertoast.showToast(msg: "위치 정보를 가져오는데 실패했습니다.");
        return null;
      }
    } else {
      return null;
    }
  }

  moveToCurrentLocation() async {
    logger.d("[moveToCurrentLocation] invoked.");
    Position? position = await getCurrentLocation();
    if (position != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 16,
      );

      cameraUpdate.setAnimation(
        animation: NCameraAnimation.fly,
        duration: const Duration(milliseconds: 1000),
      );

      mapController?.updateCamera(cameraUpdate);
    }
  }

  showLocationOverlay() async {
    logger.d("[showLocationOverlay] invoked.");
    var locationOverlay = mapController?.getLocationOverlay();
    if (locationOverlay != null && currentLocation != null) {
      locationOverlay.setIsVisible(true);
      locationOverlay.setPosition(
        NLatLng(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(
                    defaultLatitude,
                    defaultLongitude,
                  ),
                  zoom: 16,
                  bearing: 0,
                  tilt: 0,
                ),
              ),
              onMapReady: (controller) async {
                mapController = controller;
                await moveToCurrentLocation();
                await showLocationOverlay();
              },
            ),
            if (currentLocation != null)
              Positioned(
                bottom: 50,
                right: 16,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      moveToCurrentLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(242, 255, 255, 255),
                      foregroundColor: Colors.blueAccent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.my_location, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
