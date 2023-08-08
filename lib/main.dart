import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Check if Bluetooth is available and enabled
    bool isAvailable = await FlutterBlue.instance.isAvailable;
    bool isEnabled = await FlutterBlue.instance.isOn;

    if (isAvailable && isEnabled) {
      // Initialize Bluetooth scanning
      FlutterBlue.instance.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
      });
    } else {
      print('Bluetooth is not available or not enabled.');
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      await FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
    } catch (e) {
      print('Error while scanning for devices: $e');
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _stopScan() async {
    try {
      await FlutterBlue.instance.stopScan();
    } catch (e) {
      print('Error while stopping scan: $e');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : _startScan,
              child: Text(_isScanning ? 'Stop Scanning' : 'Scan for Devices'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final device = _scanResults[index].device;
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
