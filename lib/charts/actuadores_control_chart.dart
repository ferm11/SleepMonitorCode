import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ActuadoresControlChart extends StatefulWidget {
  final MqttServerClient client;

  ActuadoresControlChart({Key? key, required this.client}) : super(key: key);

  @override
  _SensoresControlState createState() => _SensoresControlState();
}

class _SensoresControlState extends State<ActuadoresControlChart> {
  bool _ledVerdeState = true;
  bool _ledBlancoState = true;
  bool _ledAzulState = true;
  bool _buzzerState = true;
  bool _vibradorState = true;

  void _publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    widget.client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  // Led verde

  void _toggleLedVerde(bool state) {
    setState(() {
      _ledVerdeState = state;
    });

    if (state) {
      _publishMessage('actuadores/ledVerde', 'on');
    } else {
      _publishMessage('actuadores/ledVerde', 'off');
    }
  }

  // Led blanco

  void _toggleLedBlanco(bool state) {
    setState(() {
      _ledBlancoState = state;
    });

    if (state) {
      _publishMessage('actuadores/ledBlanco', 'on');
    } else {
      _publishMessage('actuadores/ledBlanco', 'off');
    }
  }

  // Led azul

  void _toggleLedAzul(bool state) {
    setState(() {
      _ledAzulState = state;
    });

    if (state) {
      _publishMessage('actuadores/ledAzul', 'on');
    } else {
      _publishMessage('actuadores/ledAzul', 'off');
    }
  }

  // Buzzer

  void _toggleBuzzer(bool state) {
    setState(() {
      _buzzerState = state;
    });

    if (state) {
      _publishMessage('actuadores/buzzer', 'on');
    } else {
      _publishMessage('actuadores/buzzer', 'off');
    }
  }

  // Vibrador

  void _toggleVibrador(bool state) {
    setState(() {
      _vibradorState = state;
    });

    if (state) {
      _publishMessage('actuadores/vibrador', 'on');
    } else {
      _publishMessage('actuadores/vibrador', 'off');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('LED Verde'),
              value: _ledVerdeState,
              onChanged: _toggleLedVerde,
            ),
            SwitchListTile(
              title: const Text('LED Blanco'),
              value: _ledBlancoState,
              onChanged: _toggleLedBlanco,
            ),
            SwitchListTile(
              title: const Text('LED Azul'),
              value: _ledAzulState,
              onChanged: _toggleLedAzul,
            ),
            SwitchListTile(
              title: const Text('Control del Buzzer'),
              value: _buzzerState,
              onChanged: _toggleBuzzer,
            ),
            SwitchListTile(
              title: const Text('Control del Vibrador'),
              value: _vibradorState,
              onChanged: _toggleVibrador,
            ),
          ],
        ),
      ),
    );
  }
}