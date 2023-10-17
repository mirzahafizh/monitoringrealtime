import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LihatGrafikTinggiAir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.navigate_before_rounded,
              color: Colors.white,
            )),
        backgroundColor: Color(0xff142870),
        title: Text('Grafik Tinggi Air', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child:
                RealtimeChart(), // Gunakan widget RealtimeChart untuk menampilkan grafik
          ),
        ),
      ),
    );
  }
}

class RealtimeChart extends StatefulWidget {
  @override
  _RealtimeChartState createState() => _RealtimeChartState();
}

class _RealtimeChartState extends State<RealtimeChart> {
  List<double> sensorData = [
    0.0
  ]; // Data awal // Data sensor yang akan digunakan untuk membuat grafik
  late DatabaseReference _sensorRef;

  @override
  void initState() {
    super.initState();
    _sensorRef = FirebaseDatabase.instance.reference().child('Jarak');

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
    return Column(
      children: [
        AspectRatio(
          aspectRatio:
              1.5, // Sesuaikan perbandingan aspek sesuai dengan kebutuhan
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: const Color(0xff142870),
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: sensorData.length.toDouble() - 1,
              minY: 0, // Tetapkan tinggi minimum garis grafik di sini
              maxY: sensorData.reduce((a, b) => a > b ? a : b) +
                  10, // Sesuaikan dengan skala grafik
              lineBarsData: [
                LineChartBarData(
                  spots: sensorData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  colors: const [Color(0xff54DCC7)], // Warna garis grafik
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 4.0,
          margin: EdgeInsets.all(16.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Realtime Tinggi Air',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200, // Atur tinggi kontainer tabel sesuai kebutuhan
                  child: ListView.builder(
                    itemCount: sensorData.length > 5 ? 5 : sensorData.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = sensorData.length - index - 1;
                      return ListTile(
                        title: Text('Data Ke-${reversedIndex + 1}'),
                        subtitle:
                            Text('Tinggi Air: ${sensorData[reversedIndex]}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sensorRef.onValue.drain();
    super.dispose();
  }
}
