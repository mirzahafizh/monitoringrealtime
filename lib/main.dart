import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitoringapp/LihatGrafikKadarAir.dart';
import 'package:monitoringapp/LihatGrafikKekeruhan.dart';
import 'package:monitoringapp/LihatGrafikPage.dart';
import 'package:monitoringapp/LihatGrafikTdsAir.dart';
import 'package:monitoringapp/LihatGrafikTinggiAir.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    // Define your primary color
    MaterialColor myPrimaryColor = const MaterialColor(0xFF00FDA4, {
      50: const Color(0xFFE0FFF1),
      100: const Color(0xFFB3FFDE),
      200: const Color(0xFF80FFC8),
      300: const Color(0xFF4DFFB1),
      400: const Color(0xFF26FFA0),
      500: const Color(0xFF00FDA4), // Primary color
      600: const Color(0xFF00DB94),
      700: const Color(0xFF00B982),
      800: const Color(0xFF009770),
      900: const Color(0xFF006B5E),
    });

    return MaterialApp(
      title: 'Sensor Value App',
      theme: ThemeData(
        primarySwatch: myPrimaryColor,
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

  // Define your FlutterLocalNotificationsPlugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Threshold values for each sensor
  final double suhuThreshold = 18.0;
  final double turbidityThreshold = 7.0;
  final double pHThreshold = 7.0;
  final double waterLevelThreshold = 5.0;
  final double tdsThreshold = 800.0;

  Future<void> showNotification(String sensorName, double sensorValue) async {
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
      'Nilai Sensor Dibawah Ketentuan',
      '$sensorName: $sensorValue',
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();
    _sensorRef = FirebaseDatabase.instance
        .reference()
        .child('monitoringflutter/sensor/suhu_air/value');
    _turbidityRef = FirebaseDatabase.instance
        .reference()
        .child('monitoringflutter/sensor/kekeruhan_air/value');
    _pHRef = FirebaseDatabase.instance
        .reference()
        .child('monitoringflutter/sensor/kadar_air/value');
    _waterLevelRef = FirebaseDatabase.instance
        .reference()
        .child('monitoringflutter/sensor/tinggi_air/value');
    _tdsRef = FirebaseDatabase.instance
        .reference()
        .child('monitoringflutter/sensor/tds_air/value');

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
            showNotification('Suhu Air', sensorValue);
          }
        });
      }
    });

    _turbidityRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          turbidityValue = double.parse(data.toString());
          if (turbidityValue < suhuThreshold) {
            showNotification('Kekeruhan Air', turbidityValue);
          }
        });
      }
    });

    _pHRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          pHValue = double.parse(data.toString());
          if (pHValue < suhuThreshold) {
            showNotification('pH Air', pHValue);
          }
        });
      }
    });

    _waterLevelRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          waterLevelValue = double.parse(data.toString());
          if (waterLevelValue < suhuThreshold) {
            showNotification('Ketinggian Air', waterLevelValue);
          }
        });
      }
    });

    _tdsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          tdsValue = double.parse(data.toString());
          if (tdsValue < suhuThreshold) {
            showNotification('TDS Air', tdsValue);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff142870),
        title: const Text(
          'Monitoring Aquaponic',
          style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30.0), // Tambahkan jarak di sini
              // Text(
              //   'MONITORING SENSOR REALTIME', // Tambahkan judul "IPPL" di sini
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              buildSensorCard('SUHU AIR', sensorValue, '°C', 'suhu_air'),
              buildSensorCard(
                  'KEKERUHAN AIR', turbidityValue, 'ntu', 'kekeruhan_air'),
              buildSensorCard('KADAR AIR', pHValue, 'pH', 'kadar_air'),
              buildSensorCard(
                  'TINGGI AIR', waterLevelValue, 'cm', 'tinggi_air'),
              buildSensorCard('TDS AIR', tdsValue, 'ppm', 'tds_air'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSensorCard(
      String title, double value, String unit, String sensorType) {
    return Container(
      width: 300.0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff54DCC7),
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
          color: const Color(0xff142870), // Warna border card
          width: 2, // Lebar border
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: 'RobotoMono', // Menambahkan fontFamily 'RobotoMono'
                color: Color(0xff142870),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFamily: 'RobotoMono', // Menambahkan fontFamily 'RobotoMono'
                color: Color(0xff142870),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (sensorType == 'suhu_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LihatGrafikPage(),
                    ),
                  );
                } else if (sensorType == 'kekeruhan_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LihatGrafikKekeruhan(),
                    ),
                  );
                } else if (sensorType == 'kadar_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LihatGrafikKadarAir(),
                    ),
                  );
                } else if (sensorType == 'tinggi_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LihatGrafikTinggiAir(),
                    ),
                  );
                } else if (sensorType == 'tds_air') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LihatGrafikTdsAir(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xffFDE982), // Warna latar belakang tombol
                onPrimary: const Color(0xff142870),
                minimumSize: const Size(400, 30),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10)), // Warna teks pada tombol
                side: const BorderSide(
                  color: Color(0xff142870), // Warna border tombol
                  width: 2.0, // Lebar border tombol
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
