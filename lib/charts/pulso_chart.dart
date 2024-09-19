import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PulsoChart extends StatefulWidget {
  final MqttServerClient client;
  final String topic;

  const PulsoChart({super.key, required this.client, required this.topic});

  @override
  _HeartRateChartState createState() => _HeartRateChartState();
}

class _HeartRateChartState extends State<PulsoChart> {
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    widget.client.updates!.listen(_onMessage);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final message = event[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    final value = double.tryParse(payload);

    if (event[0].topic == widget.topic && value != null) {
      setState(() {
        _spots.add(FlSpot(_spots.length.toDouble(), value));
        if (_spots.length > 20) {
          _spots.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Pulso',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16), // Espacio entre el título y la gráfica
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    barWidth: 4,
                    color: Colors.red,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}