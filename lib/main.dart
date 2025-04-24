import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blaugrau = Color(0xFF7A9CA3);
    return MaterialApp(
      title: 'SunMask Test',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: blaugrau),
        ),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('de', '')],
      home: const BLETestPage(),
    );
  }
}

class BLETestPage extends StatefulWidget {
  const BLETestPage({super.key});

  @override
  State<BLETestPage> createState() => _BLETestPageState();
}

class _BLETestPageState extends State<BLETestPage> {
  List<BluetoothDevice> foundDevices = [];

  @override
  void initState() {
    super.initState();
    startBLEScan();
  }

  void startBLEScan() async {
    foundDevices.clear();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        foundDevices = results.map((r) => r.device).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const blaugrau = Color(0xFF7A9CA3);
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE-Test"),
      ),
      body: ListView.builder(
        itemCount: foundDevices.length,
        itemBuilder: (context, index) {
          final device = foundDevices[index];
          return ListTile(
            title: Text(
              device.platformName.isNotEmpty
                  ? device.platformName
                  : "Unbekanntes Gerät",
              style: const TextStyle(color: blaugrau),
            ),
            subtitle: Text(
              "ID: ${device.remoteId.str}",
              style: const TextStyle(color: blaugrau),
            ),
          );
        },
      ),
    );
  }
}
