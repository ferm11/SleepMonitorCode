import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:math' as math;

class HumedadChart extends StatefulWidget {
  final MqttServerClient client;
  final String topic;

  const HumedadChart({super.key, required this.client, required this.topic});

  @override
  _HumedadChartState createState() => _HumedadChartState();
}

class _HumedadChartState extends State<HumedadChart> {
  double _temperature = 0.0;

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
        _temperature = value;
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
          children: [
            Text(
              'Humedad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(200, 200),
              painter: _GaugePainter(_temperature),
            ),
            SizedBox(height: 20),
            Text(
              '${_temperature.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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

class _GaugePainter extends CustomPainter {
  final double value;

  _GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (value / 50); // Normalizando valor

    // Determinar el color basado en el valor de la temperatura
    Color needleColor;
    Color gaugeColor;

    if (value >= 1 && value <= 39.0) {
      needleColor = Colors.blue;
      gaugeColor = Colors.blue.withOpacity(0.3);
    } else if (value >= 40.0 && value <= 80.0) {
      needleColor = Colors.green;
      gaugeColor = Colors.green.withOpacity(0.3);
    } else {
      needleColor = Colors.red;
      gaugeColor = Colors.red.withOpacity(0.3);
    }

    final paint = Paint()
      ..color = gaugeColor
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final angle = startAngle + sweepAngle;
    final needleEnd = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

    canvas.drawLine(center, needleEnd, needlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}