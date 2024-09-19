import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class GiroscopioChart extends StatefulWidget {
  final MqttServerClient client;
  final String topic;

  const GiroscopioChart({super.key, required this.client, required this.topic});

  @override
  _Spo2ChartState createState() => _Spo2ChartState();
}

class _Spo2ChartState extends State<GiroscopioChart> {
  double _spo2Level = 0.0;

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
        _spo2Level = value / 100; // Normalizando el valor entre 0.0 y 1.0
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Envolver el Column con Center
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Giroscopio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: _spo2Level,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _spo2Level <= 500 ? Colors.green : _spo2Level > 500 ? Colors.yellow :  Colors.red,
                    ),
                  ),
                ),
                Text(
                  '${(_spo2Level * 100).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}