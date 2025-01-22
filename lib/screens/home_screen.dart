import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/appbar.dart';
import '../widgets/choicechip.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> scannedData = [];
  String? selectedGate;
  String? deviceId;

  // Gate options
  final List<String> gates = ['1', '2', '3', '4'];

  Future<void> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceId = androidInfo.id; // Get unique ID for Android devices
    });
  }

  Future<void> getSelectedGate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGate = prefs.getString('selectedGate') ?? gates[0];
    });
  }

  Future<void> saveSelectedGate(String gate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGate', gate);
  }

  @override
  void initState() {
    super.initState();
    getDeviceId();
    getSelectedGate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KAppbar(
        appBarTitle: "QR-Code Scanner",
        iconData: Icons.qr_code_scanner_outlined,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Choose The Gate',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 50,
                mainAxisSpacing: 0.5,
              ),
              itemCount: gates.length,
              itemBuilder: (context, index) {
                final gate = gates[index];
                return KChoiceChip(
                  gate: gate,
                  isSelected: selectedGate == gate,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedGate = selected ? gate : null;
                    });
                    saveSelectedGate(selected ? gate : gates[0]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (selectedGate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a gate'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScannerAndResultScreen(
                deviceId: deviceId!,
                gate: selectedGate!,
              ),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
    );
  }
}
