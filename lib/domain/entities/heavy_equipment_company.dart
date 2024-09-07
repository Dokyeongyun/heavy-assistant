import 'latlng.dart';

class HeavyEquipmentCompany {
  final String identifier;
  final String companyName;
  final String address;
  final String roadAddress;
  final LatLng location;
  final String? phone;
  final String url;

  HeavyEquipmentCompany({
    required this.identifier,
    required this.companyName,
    required this.address,
    required this.roadAddress,
    required this.location,
    required this.phone,
    required this.url,
  });
}
