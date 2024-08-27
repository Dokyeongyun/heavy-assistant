import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heavy_assistant/model/latlng.dart';
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
  LatLng? currentLatLng;

  @override
  void initState() {
    super.initState();
  }

  Future<LatLng?> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    logger
        .i("[getCurrentLocation] Current permission status: $permissionStatus");
    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        logger.i("[getCurrentLocation] Current location: $position");
        return LatLng(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "위치 정보를 가져오는데 실패했습니다.");
        return null;
      }
    } else {
      return LatLng.defaultLatLng();
    }
  }

  moveToCurrentLocation() async {
    logger.d("[moveToCurrentLocation] invoked.");
    LatLng? latlng = await getCurrentLocation();
    if (latlng != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(
          latlng.latitude,
          latlng.longitude,
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

  showLocationOverlay(LatLng latlng) async {
    logger.d("[showLocationOverlay] invoked.");
    var locationOverlay = mapController?.getLocationOverlay();
    if (locationOverlay != null) {
      locationOverlay.setIsVisible(true);
      locationOverlay.setPosition(
        NLatLng(
          latlng.latitude,
          latlng.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLatLng == null) {
      getCurrentLocation().then((value) {
        setState(() {
          currentLatLng = value;
        });
      });

      return Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.amberAccent,
              backgroundColor: Colors.amber,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  currentLatLng!.latitude,
                  currentLatLng!.longitude,
                ),
                zoom: 16,
                bearing: 0,
                tilt: 0,
              ),
            ),
            onMapReady: (controller) async {
              mapController = controller;
              await showLocationOverlay(currentLatLng!);
            },
          ),
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
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '서울 서초구',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
