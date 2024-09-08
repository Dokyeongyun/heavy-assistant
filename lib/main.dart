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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const MapScreen(),
    const Text(
      '기사찾기',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
    const Text(
      '장비찾기',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
    const MapScreen(),
    const Text(
      '나의정보',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home_filled),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_search_outlined),
                activeIcon: Icon(Icons.person_search),
                label: '기사찾기',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.manage_search_outlined),
                activeIcon: Icon(Icons.manage_search),
                label: '장비찾기',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                activeIcon: Icon(Icons.location_on),
                label: '중기지도',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                activeIcon: Icon(Icons.person_2),
                label: '나의정보',
              ),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            iconSize: 22.0,
            selectedItemColor: const Color(0xbe131313),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11.0,
            unselectedFontSize: 11.0,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.normal,
            ),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
