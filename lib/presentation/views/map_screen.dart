import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:heavy_assistant/core/utils/location_util.dart';
import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:heavy_assistant/presentation/viewmodels/map_view_model.dart';
import 'package:heavy_assistant/presentation/widgets/current_location_button.dart';
import 'package:heavy_assistant/presentation/widgets/map_loading_indicator.dart';
import 'package:heavy_assistant/presentation/widgets/map_location_label.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final Logger logger = Logger();

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? mapController;
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MapViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }

  Future<void> moveCamera(LatLng latLng) async {
    if (mapController != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(latLng.latitude, latLng.longitude),
        zoom: 16,
      );

      cameraUpdate.setAnimation(
        animation: NCameraAnimation.fly,
        duration: const Duration(milliseconds: 1000),
      );

      await mapController!.updateCamera(cameraUpdate);
    }
  }

  Future<void> showLocationOverlay(LatLng latlng) async {
    if (mapController != null) {
      var locationOverlay = mapController!.getLocationOverlay();
      locationOverlay.setIsVisible(true);
      locationOverlay.setPosition(
        NLatLng(latlng.latitude, latlng.longitude),
      );
    }
  }

  Future<void> addHeavyEquipmentCompanyOverlays(
    List<HeavyEquipmentCompany> heavyEquipmentCompanies,
  ) async {
    for (var company in heavyEquipmentCompanies) {
      LatLng location = company.location;
      final marker = NMarker(
        id: company.identifier,
        position: NLatLng(
          location.latitude,
          location.longitude,
        ),
        size: const NSize(24, 24),
        icon: const NOverlayImage.fromAssetImage('assets/images/excavator.png'),
        caption: NOverlayCaption(
          text: company.companyName,
          color: Colors.black,
        ),
      );

      mapController?.addOverlay(marker);
      marker.setOnTapListener((NMarker marker) {
        logger.d("[onTap] Marker tapped: ${marker.info.id}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context, listen: true);
    if (!viewModel.isInitialized) {
      return const Scaffold(
        body: Center(
          child: MapLoadingIndicator(),
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
                  viewModel.currentLatLng?.latitude ??
                      LatLng.defaultLatLng().latitude,
                  viewModel.currentLatLng?.longitude ??
                      LatLng.defaultLatLng().longitude,
                ),
                zoom: 14,
                bearing: 0,
                tilt: 0,
              ),
            ),
            onMapReady: (controller) async {
              mapController = controller;
              LatLng? currentLatLng = viewModel.currentLatLng;
              if (currentLatLng != null) {
                showLocationOverlay(currentLatLng);
                moveCamera(currentLatLng);
              }

              addHeavyEquipmentCompanyOverlays(
                viewModel.heavyEquipmentCompanies,
              );
            },
            onCameraChange: (NCameraUpdateReason reason, bool animated) async {
              if (reason != NCameraUpdateReason.developer) {
                debounceTimer?.cancel();
                debounceTimer =
                    Timer(const Duration(milliseconds: 300), () async {
                  NCameraPosition? cameraPosition =
                      await mapController?.getCameraPosition();
                  if (cameraPosition != null) {
                    viewModel.setAddress(
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
              child: CurrentLocationButton(
                onPressed: () {
                  LocationUtil().getCurrentLocation().then((latlng) {
                    viewModel.setAddress(latlng);
                    moveCamera(latlng);
                  });
                },
              ),
            ),
          ),
          if (viewModel.address != null)
            Positioned(
              bottom: 55,
              left: 0,
              right: 0,
              child: Center(
                child: MapLocationLabel(address: viewModel.address!),
              ),
            ),
        ],
      ),
    );
  }
}
