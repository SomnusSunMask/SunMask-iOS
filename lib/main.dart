import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    loadClickCount();
  }

  Future<void> loadClickCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        clickCount = prefs.getInt('clickCount') ?? 0;
      });
    } catch (e) {
      debugPrint("⚠️ Fehler beim Laden von SharedPreferences: $e");
    }
  }

  Future<void> incrementClickCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        clickCount++;
      });
      await prefs.setInt('clickCount', clickCount);
    } catch (e) {
      debugPrint("⚠️ Fehler beim Speichern von SharedPreferences: $e");
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: incrementClickCount,
              child: Text("Geklickt: $clickCount mal"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startBLEScan,
              child: const Text("BLE-Scan starten"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}
