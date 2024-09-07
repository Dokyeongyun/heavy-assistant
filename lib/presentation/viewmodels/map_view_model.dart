import 'package:flutter/material.dart';
import 'package:heavy_assistant/core/utils/location_util.dart';
import 'package:heavy_assistant/domain/entities/heavy_equipment_company.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:heavy_assistant/domain/usecases/find_heavy_equipment_company_use_case.dart';
import 'package:heavy_assistant/domain/usecases/find_address_use_case.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class MapViewModel extends ChangeNotifier {
  final FindHeavyEquipmentCompanyUseCase findHeavyEquipmentCompanyUseCase;
  final FindAddressUseCase findAddressUseCase;

  List<HeavyEquipmentCompany> heavyEquipmentCompanies = [];
  LatLng? currentLatLng;
  String? address;
  bool isLoading = true;
  bool isInitialized = false;

  MapViewModel(
    this.findHeavyEquipmentCompanyUseCase,
    this.findAddressUseCase,
  );

  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    try {
      currentLatLng = await LocationUtil().getCurrentLocation();
    } catch (e) {
      currentLatLng = LatLng.defaultLatLng();
    }

    address = await findAddressUseCase.execute(currentLatLng!);
    heavyEquipmentCompanies = await findHeavyEquipmentCompanyUseCase.execute();
    isLoading = false;
    isInitialized = true;
    notifyListeners();
  }

  Future<void> setAddress(LatLng latLng) async {
    address = await findAddressUseCase.execute(latLng);
    notifyListeners();
  }

  Future<void> updateCurrentLocation(LatLng latLng) async {
    notifyListeners();
  }
}
