import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitoringapp/LihatGrafikKadarAir.dart';
import 'package:monitoringapp/LihatGrafikKekeruhan.dart';
import 'package:monitoringapp/LihatGrafikPage.dart';
import 'package:monitoringapp/LihatGrafikTdsAir.dart';
import 'package:monitoringapp/LihatGrafikTinggiAir.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);

    MaterialColor myPrimaryColor = const MaterialColor(0xff142870, {
      50: Color(0xFF142870),
      100: Color(0xFF142870),
      200: Color(0xFF142870),
      300: Color(0xFF142870),
      400: Color(0xff142870),
      500: Color(0xff142870),
      600: Color(0xFF142870),
      700: Color(0xFF142870),
      800: Color(0xFF142870),
      900: Color(0xFF142870),
    });

    return MaterialApp(
      title: 'Aquaponic',
      theme: ThemeData(
        primarySwatch: myPrimaryColor,
        brightness:
            _themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: const MySensorPage(),
    );
  }
}

class MySensorPage extends StatefulWidget {
  const MySensorPage({Key? key});

  @override
  _MySensorPageState createState() => _MySensorPageState();
}

class _MySensorPageState extends State<MySensorPage> {
  late double sensorValue;
  late double turbidityValue;
  late double pHValue;
  late double waterLevelValue;
  late double tdsValue;
  late DatabaseReference _sensorRef;
  late DatabaseReference _turbidityRef;
  late DatabaseReference _pHRef;
  late DatabaseReference _waterLevelRef;
  late DatabaseReference _tdsRef;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final double suhuThreshold = 25.0;
  // final double turbidityThreshold = 7.0;
  final double pHThreshold = 5.0;
  final double waterLevelThreshold = 25.0;
  final double tdsThreshold = 700.0;

  final double suhuThreshold2 = 36.0;
  // final double turbidityThreshold2 = 7.0;
  final double pHThreshold2 = 8.0;
  final double waterLevelThreshold2 = 65.0;
  final double tdsThreshold2 = 1500.0;

  Future<void> showNotification(String sensorName, double sensorValue,
      String satuan, String messageSensor) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Sensor Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      messageSensor,
      '$sensorName: $sensorValue $satuan',
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();
    _sensorRef = FirebaseDatabase.instance.reference().child('suhuair');
    _turbidityRef = FirebaseDatabase.instance.reference().child('kekeruhanair');
    _pHRef = FirebaseDatabase.instance.reference().child('pHair');
    _waterLevelRef = FirebaseDatabase.instance.reference().child('tinggiair');
    _tdsRef = FirebaseDatabase.instance.reference().child('ppmair');

    sensorValue = 0.0;
    turbidityValue = 0.0;
    pHValue = 0.0;
    waterLevelValue = 0.0;
    tdsValue = 0.0;

    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          sensorValue = double.parse(data.toString());
          if (sensorValue < suhuThreshold) {
            showNotification(
                'Suhu Air', sensorValue, '°C', 'Suhu Air Terlalu Dingin!');
          } else if (sensorValue > suhuThreshold2) {
            showNotification(
                'Suhu Air', sensorValue, '°C', 'Suhu Air Terlalu Panas!');
          }
        });
      }
    });

    _turbidityRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          turbidityValue = double.parse(data.toString());
        });
      }
    });

    _pHRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          pHValue = double.parse(data.toString());
          if (pHValue < pHThreshold) {
            showNotification(
                'pH Air', pHValue, 'pH', 'Kadar Air kritis terdeteksi!');
          } else if (pHValue > pHThreshold2) {
            showNotification('pH Air', pHValue, 'pH',
                'Kadar Air di luar batas normal, Periksa Segera!');
          }
        });
      }
    });

    _waterLevelRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          waterLevelValue = double.parse(data.toString());
          if (waterLevelValue < waterLevelThreshold) {
            showNotification(
                'Ketinggian Air', waterLevelValue, 'cm', 'Air hampir habis!');
          } else if (waterLevelValue > waterLevelThreshold2) {
            showNotification('Ketinggian Air', waterLevelValue, 'cm',
                'Air akan segera penuh! matikan sumber air!');
          }
        });
      }
    });

    _tdsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          tdsValue = double.parse(data.toString());
          if (tdsValue < tdsThreshold) {
            showNotification(
                'TDS Air', tdsValue, 'ppm', 'Kualitas air kritis terdeteksi!');
          } else if (tdsValue > tdsThreshold2) {
            showNotification('TDS Air', tdsValue, 'ppm',
                'Kualitas Air di luar batas normal, Periksa Segera!');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorRef.onValue.drain();
    _turbidityRef.onValue.drain();
    _pHRef.onValue.drain();
    _waterLevelRef.onValue.drain();
    _tdsRef.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeProvider.isDarkMode
            ? Color.fromARGB(255, 99, 99, 99)
            : const Color(0xff142870),
        title: const Text(
          'Monitoring Aquaponic',
          style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              _themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15.0),
              buildSensorCard('SUHU AIR', sensorValue, '°C', 'suhu_air',
                  _themeProvider.isDarkMode),
              buildSensorCard('KEKERUHAN AIR', turbidityValue, 'ntu',
                  'kekeruhan_air', _themeProvider.isDarkMode),
              buildSensorCard('KADAR AIR', pHValue, 'pH', 'kadar_air',
                  _themeProvider.isDarkMode),
              buildSensorCard('TINGGI AIR', waterLevelValue, 'cm', 'tinggi_air',
                  _themeProvider.isDarkMode),
              buildSensorCard('TDS AIR', tdsValue, 'ppm', 'tds_air',
                  _themeProvider.isDarkMode),
              SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSensorCard(String title, double value, String unit,
      String sensorType, bool isDarkMode) {
    Color cardBackgroundColor =
        isDarkMode ? Color.fromARGB(255, 72, 72, 72) : const Color(0xff54DCC7);
    Color borderColor = isDarkMode ? Colors.white : const Color(0xff142870);
    Color textColor = isDarkMode ? Colors.white : const Color(0xff142870);

    return Container(
      width: 300.0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: 'RobotoMono',
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFamily: 'RobotoMono',
                color: textColor,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (sensorType == 'suhu_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LihatGrafikPage(theme: Theme.of(context)),
                    ),
                  );
                } else if (sensorType == 'kekeruhan_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LihatGrafikKekeruhan(theme: Theme.of(context)),
                    ),
                  );
                } else if (sensorType == 'kadar_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LihatGrafikKadarAir(theme: Theme.of(context)),
                    ),
                  );
                } else if (sensorType == 'tinggi_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LihatGrafikTinggiAir(theme: Theme.of(context)),
                    ),
                  );
                } else if (sensorType == 'tds_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          LihatGrafikTdsAir(theme: Theme.of(context)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: isDarkMode
                    ? const Color(0xff54DCC7)
                    : const Color(0xffFDE982),
                onPrimary: isDarkMode ? Colors.black : const Color(0xff142870),
                minimumSize: const Size(400, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(
                  color: borderColor,
                  width: 2.0,
                ),
              ),
              child: const Text('LIHAT GRAFIK'),
            ),
          ],
        ),
      ),
    );
  }
}
