import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sleep_monitor/charts/actuadores_control_chart.dart';

// Nuevas importaciones para los gráficos
import 'package:sleep_monitor/charts/humedad_chart.dart';
import 'package:sleep_monitor/charts/temperatura_chart.dart';
import 'package:sleep_monitor/charts/gas_chart.dart';
import 'package:sleep_monitor/charts/pulso_chart.dart';
import 'package:sleep_monitor/charts/giroscopio_chart.dart';

void main() {
  runApp(AppInitializer());
}

class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  MqttServerClient? _mqttClient;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    //final client = MqttServerClient.withPort('broker.hivemq.com, 192.168.200.116', '', 1883);
    final client = MqttServerClient.withPort('192.168.200.116', '', 1883);
    client.keepAlivePeriod = 20;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('sleepmonitor')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.autoReconnect = true;
    client.connectionMessage = connMessage;

    try {
      await client.connect();

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print('MQTT Client Connected');
        setState(() {
          _mqttClient = client;
          _isLoading = false;
        });

        // Suscripciones a los tópicos
        client.subscribe('utng/proyecto/temperature', MqttQos.atMostOnce);
        client.subscribe('utng/proyecto/humidity', MqttQos.atMostOnce);
        client.subscribe('utng/proyecto/pulse', MqttQos.atMostOnce);
        client.subscribe('utng/proyecto/gyroscope', MqttQos.atMostOnce);
        client.subscribe('utng/proyecto/gas', MqttQos.atMostOnce);
        // Eliminado: client.subscribe('sensor/estado/alarma', MqttQos.atMostOnce);
      } else {
        print('Connection failed, retrying in 5 seconds...');
        Future.delayed(const Duration(seconds: 5), _initializeApp);
      }
    } catch (e) {
      print('Connection failed: $e, retrying in 5 seconds...');
      Future.delayed(const Duration(seconds: 5), _initializeApp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return MainApp(client: _mqttClient!);
    }
  }
}

class MainApp extends StatelessWidget {
  final MqttServerClient client;

  const MainApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> charts = [
      {'title': 'Temperatura', 'widget': TemperaturaChart(topic: 'utng/proyecto/temperature', client: client)},
      {'title': 'Humedad', 'widget': HumedadChart(topic: 'utng/proyecto/humidity', client: client)},
      {'title': 'Pulso', 'widget': PulsoChart(topic: 'utng/proyecto/pulse', client: client)},
      {'title': 'Giroscopio', 'widget': GiroscopioChart(topic: 'utng/proyecto/gyroscope', client: client)},
      {'title': 'Gas', 'widget': GasChart(topic: 'utng/proyecto/gas', client: client)},
      {'title': 'Control de Actuadores', 'widget': ActuadoresControlChart(client: client)},
      // Eliminado: {'title': 'Estado de Alarma', 'widget': AlarmStatusChart(topic: 'sensor/estado/alarma', client: client)},
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('App'),
          backgroundColor: const Color.fromARGB(255, 2, 162, 13),
        ),
        body: ListView.builder(
          itemCount: charts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(charts[index]['title']),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChartScreen(
                      title: charts[index]['title'],
                      chartWidget: charts[index]['widget'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChartScreen extends StatelessWidget {
  final String title;
  final Widget chartWidget;

  const ChartScreen({super.key, required this.title, required this.chartWidget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 98, 200, 200),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: chartWidget,
      ),
    );
  }
}