import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
    MaterialColor myPrimaryColor = MaterialColor(0xFF00FDA4, {
      50: Color(0xFFE0FFF1),
      100: Color(0xFFB3FFDE),
      200: Color(0xFF80FFC8),
      300: Color(0xFF4DFFB1),
      400: Color(0xFF26FFA0),
      500: Color(0xFF00FDA4), // Primary color
      600: Color(0xFF00DB94),
      700: Color(0xFF00B982),
      800: Color(0xFF009770),
      900: Color(0xFF006B5E),
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

  @override
  void initState() {
    super.initState();
    _sensorRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/suhu_air/value');
    _turbidityRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/kekeruhan_air/value');
    _pHRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/kadar_air/value');
    _waterLevelRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/tinggi_air/value');
    _tdsRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/tds_air/value');

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
        });
      }
    });

    _waterLevelRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          waterLevelValue = double.parse(data.toString());
        });
      }
    });

    _tdsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          tdsValue = double.parse(data.toString());
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
        title: Text('Monitoring Aquaponic'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30.0), // Tambahkan jarak di sini
              Text(
              'IPPL SELALU DIHATI ❤️', // Tambahkan judul "IPPL" di sini
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
              buildSensorCard('Sensor Suhu Air', sensorValue, '°C', 'suhu_air'),
              buildSensorCard('Kekeruhan Air', turbidityValue, 'ntu', 'kekeruhan_air'),
              buildSensorCard('Kadar Air', pHValue, 'pH', 'kadar_air'),
              buildSensorCard('Tinggi Air', waterLevelValue, 'cm', 'tinggi_air'),
              buildSensorCard('TDS Air', tdsValue, 'ppm', 'tds_air'),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildSensorCard(String title, double value, String unit, String sensorType) {
  return Container(
    width: 300.0,
    margin: EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: Colors.teal,
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            child: Text('Lihat Grafik'),
          ),
        ],
      ),
    ),
  );
}
}