import 'package:heavy_assistant/data/datasources/naver_datasource.dart';
import 'package:heavy_assistant/domain/entities/latlng.dart';
import 'package:heavy_assistant/domain/repositories/address_repository.dart';

class AddressRepositoryNaverImpl implements AddressRepository {
  final NaverDatasource naverDatasource;

  AddressRepositoryNaverImpl(this.naverDatasource);

  @override
  Future<String?> findAddressFromLatLng(LatLng latlng) async {
    return naverDatasource.findAddressFromLatLng(latlng);
  }
}
