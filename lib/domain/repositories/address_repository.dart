import 'package:heavy_assistant/domain/entities/latlng.dart';

abstract class AddressRepository {
  Future<String?> findAddressFromLatLng(LatLng latlng);
}
