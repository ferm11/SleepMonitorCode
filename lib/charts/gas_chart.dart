import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class GasChart extends StatefulWidget {
  final MqttServerClient client;
  final String topic;

  const GasChart({super.key, required this.client, required this.topic});

  @override
  _IrChartState createState() => _IrChartState();
}

class _IrChartState extends State<GasChart> {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Gas', // Título para la gráfica
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20), // Espacio entre el título y la gráfica
            Expanded(
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
                      color: Colors.orange, // Definiendo el color de la línea
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.3), // Definiendo el color del área bajo la línea
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}