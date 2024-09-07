import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:heavy_assistant/domain/repositories/address_repository.dart';

class FindAddressUseCase {
  final AddressRepository repository;

  FindAddressUseCase(this.repository);

  Future<String?> execute(LatLng latlng) async {
    return await repository.findAddressFromLatLng(latlng);
  }
}
