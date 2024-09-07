import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heavy_assistant/core/utils/location_util.dart';
import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:heavy_assistant/domain/repositories/heavy_equipment_company_repository.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class MapScreenViewModel {
  final HeavyEquipmentCompanyRepository repository;
  final Logger logger = Logger();
  bool isLoading = true;

  LatLng? currentLatLng;
  String? address;
  Timer? debounceTimer;

  MapScreenViewModel(this.repository);

  Future<void> getCurrentLocationAndAddress() async {
    try {
      LatLng latlng = await LocationUtil().getCurrentLocation();
      String? addr = await findAddressFromLatLng(latlng);
      currentLatLng = latlng;
      address = addr;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void setAddress(LatLng latlng) async {
    address = await findAddressFromLatLng(latlng);
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

  Future<void> loadAndDisplayHeavyEquipmentCompanies(
      NaverMapController mapController) async {
    try {
      List<HeavyEquipmentCompany> companies =
          await repository.getHeavyEquipmentCompanies();

      for (var company in companies) {
        await addHeavyEquipmentCompanyOverlay(mapController, company);
      }
    } catch (e) {
      logger.e("[loadAndDisplayHeavyEquipmentCompanies] Error: $e");
      Fluttertoast.showToast(msg: "업체 정보를 불러오는데 실패했습니다.");
    } finally {
      isLoading = false;
    }
  }

  Future<void> addHeavyEquipmentCompanyOverlay(NaverMapController mapController,
      HeavyEquipmentCompany heavyEquipmentCompany) async {
    LatLng location = heavyEquipmentCompany.location;
    final marker = NMarker(
      id: heavyEquipmentCompany.identifier,
      position: NLatLng(location.latitude, location.longitude),
      size: const NSize(40, 40),
      icon: const NOverlayImage.fromAssetImage('assets/images/excavator.png'),
      caption: NOverlayCaption(
        text: heavyEquipmentCompany.companyName,
        color: Colors.black,
      ),
    );
    mapController.addOverlay(marker);
    marker.setOnTapListener((NMarker marker) {
      logger.d("[onTap] Marker tapped: ${marker.info.id}");
    });
  }

  void dispose() {
    debounceTimer?.cancel();
  }
}
