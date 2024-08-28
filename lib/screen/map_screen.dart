import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:heavy_assistant/model/latlng.dart';
import 'package:http/http.dart' as http;
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
  String? address;
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }

  Future<LatLng> getCurrentLocation() async {
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
        return LatLng.defaultLatLng();
      }
    } else {
      return LatLng.defaultLatLng();
    }
  }

  moveToCurrentLocation() async {
    logger.d("[moveToCurrentLocation] invoked.");
    LatLng latlng = await getCurrentLocation();
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
    setAddress(latlng);
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

  setAddress(LatLng latlng) async {
    logger.d("[setCurrentAddress] invoked.");
    if (currentLatLng != null) {
      String? address = await findAddressFromLatLng(latlng);
      setState(() {
        this.address = address;
      });
    }
  }

  Future<String?> findAddressFromLatLng(LatLng latlng) async {
    logger.d(
        "[findAddressFromLatLng] invoked. latitude: ${latlng.latitude}, longitude: ${latlng.longitude}");
    String naverApiClientId = '1uoi9f7ytt';
    String naverApiClientSecret = 'u2o6WssSvWy90JgUA8OeypHeia2GEkWQxelnR5jw';
    final response = await http.get(
      Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${latlng.longitude},${latlng.latitude}&output=json'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverApiClientId,
        'X-NCP-APIGW-API-KEY': naverApiClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      if (results.isEmpty) {
        return null;
      }

      final result = results[0];
      final area1Name = result['region']['area1']['alias'] ??
          result['region']['area1']['name'];
      final area2Name = result['region']['area2']['name'];
      final area3Name = result['region']['area3']['name'];

      final address = '$area1Name $area2Name $area3Name';
      logger.d(
          "[findAddressFromLatLng] latitude: ${latlng.latitude}, longitude: ${latlng.longitude}, address: $address");
      return address;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLatLng == null) {
      getCurrentLocation().then((currentLatLng) {
        findAddressFromLatLng(currentLatLng).then((address) {
          setState(() {
            this.currentLatLng = currentLatLng;
            this.address = address;
          });
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
            onCameraChange: (NCameraUpdateReason reason, bool animated) async {
              if (reason != NCameraUpdateReason.developer) {
                debounceTimer?.cancel();
                debounceTimer =
                    Timer(const Duration(milliseconds: 500), () async {
                  NCameraPosition? cameraPosition =
                      await mapController?.getCameraPosition();
                  if (cameraPosition != null) {
                    setAddress(
                      LatLng(
                        latitude: cameraPosition.target.latitude,
                        longitude: cameraPosition.target.longitude,
                      ),
                    );
                  }
                });
              }
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
          if (address != null)
            Positioned(
              bottom: 55,
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
                    child: Center(
                      child: Text(
                        address!,
                        style: const TextStyle(
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
