import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LihatGrafikTdsAir extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lihat Grafik TDS Air'),
      ),
      body: RealtimeChart(), // Gunakan widget RealtimeChart untuk menampilkan grafik
    );
  }
}

class RealtimeChart extends StatefulWidget {
  @override
  _RealtimeChartState createState() => _RealtimeChartState();
}

class _RealtimeChartState extends State<RealtimeChart> {
  List<double> sensorData = [0.0]; // Data awal // Data sensor yang akan digunakan untuk membuat grafik
  late DatabaseReference _sensorRef;

  @override
  void initState() {
    super.initState();
    _sensorRef = FirebaseDatabase.instance.reference().child('monitoringflutter/sensor/tds_air/value');

    // Tambahkan listener untuk memantau perubahan nilai sensor di Firebase
    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          // Perbarui nilai sensorData dengan data yang diterima dari Firebase
          sensorData.add(double.parse(data.toString()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xff37434d),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: sensorData.length.toDouble() - 1,
        minY: 0,
        maxY: sensorData.reduce((a, b) => a > b ? a : b) + 10, // Sesuaikan dengan skala grafik
        lineBarsData: [
          LineChartBarData(
            spots: sensorData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            colors: [Colors.blue], // Warna garis grafik
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorRef.onValue.drain();
    super.dispose();
  }
}


