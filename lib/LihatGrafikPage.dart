import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LihatGrafikPage extends StatelessWidget {
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
          ),
        ),
        backgroundColor: const Color(0xff142870),
        title: const Text('Grafik Suhu Air',
            style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RealtimeChart(),
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
  List<ChartData> sensorData = []; // Data awal
  Map<String, dynamic> dataMap = {};

  late DatabaseReference _sensorRef;
  late DatabaseReference _grafikRef;
  int dataIndex = 0;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    _sensorRef = FirebaseDatabase.instance.reference().child('Suhu');
    _grafikRef = FirebaseDatabase.instance.reference().child('Grafik/suhu');

    _grafikRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && !initialized) {
        // Tambahkan kondisi !initialized
        if (data is List) {
          for (int i = 0; i < data.length; i++) {
            final value = data[i];
            if (value != null) {
              setState(() {
                dataMap[dataIndex.toString()] = double.parse(value.toString());
                sensorData.add(ChartData(
                    dataIndex.toDouble(), double.parse(value.toString())));
                dataIndex++;
              });
            }
          }
          // Set initialized menjadi true setelah mendapatkan data pertama kali
          initialized = true;
        }
      }
    });

    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          if (dataMap.isNotEmpty) {
            final lastIndexValue = dataMap[dataMap.keys.last];
            if (lastIndexValue != double.parse(data.toString())) {
              dataMap[dataIndex.toString()] = double.parse(data.toString());
              _grafikRef
                  .child(dataIndex.toString())
                  .set(double.parse(data.toString()));
              sensorData.add(ChartData(
                  dataIndex.toDouble(), double.parse(data.toString())));
              dataIndex++;
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: SfCartesianChart(
            primaryXAxis: NumericAxis(
              majorGridLines: const MajorGridLines(width: 0.5),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(
              majorGridLines: const MajorGridLines(width: 0.5),
              minimum: 0,
              maximum:
                  sensorData.fold(0.0, (max, e) => max > e.y ? max : e.y) + 10,
            ),
            series: <LineSeries<ChartData, double>>[
              LineSeries<ChartData, double>(
                dataSource: sensorData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: const Color(0xff54DCC7),
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
        Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Realtime Suhu Air',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: sensorData.length > 5 ? 5 : sensorData.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = sensorData.length - index - 1;
                      return ListTile(
                        title: Text('Data Ke - ${reversedIndex + 1}'),
                        subtitle:
                            Text('Suhu Air: ${sensorData[reversedIndex].y}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            resetGrafik();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LihatGrafikPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff54DCC7),
            onPrimary: Colors.white,
            minimumSize: const Size(280, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(
              color: Color(0xff54DCC7),
              width: 2.0,
            ),
          ),
          child: const Text('RESET GRAFIK'),
        )
      ],
    );
  }

  void resetGrafik() {
    _grafikRef.set({0: 0});
  }

  @override
  void dispose() {
    _sensorRef.onValue.drain();
    super.dispose();
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
