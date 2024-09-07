import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:heavy_assistant/data/datasources/naver_datasource.dart';
import 'package:heavy_assistant/data/repositories/address_repository_naver_impl.dart';
import 'package:heavy_assistant/domain/usecases/find_address_use_case.dart';
import 'package:heavy_assistant/presentation/viewmodels/map_view_model.dart';
import 'package:heavy_assistant/presentation/views/map_screen.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'core/network/network_client.dart';
import 'data/datasources/notion_datasource.dart';
import 'data/repositories/heavy_equipment_company_repository_impl.dart';
import 'domain/usecases/find_heavy_equipment_company_use_case.dart';

final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '1uoi9f7ytt');

  final networkClient = NetworkClient(http.Client());

  final notionDatasource = NotionDatasource(networkClient);
  final naverDatasource = NaverDatasource(networkClient);

  final heavyEquipmentRepository =
      HeavyEquipmentCompanyRepositoryImpl(notionDatasource);
  final addressRepository = AddressRepositoryNaverImpl(naverDatasource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapViewModel(
              FindHeavyEquipmentCompanyUseCase(heavyEquipmentRepository),
              FindAddressUseCase(addressRepository)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: MapScreen(),
      ),
    );
  }
}
