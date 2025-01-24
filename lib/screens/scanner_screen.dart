// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tnrb/widgets/appbar.dart';

import '../model/visitor.dart';
import '../utils/constant.dart';
import '../utils/data_service.dart';

class ScannerAndResultScreen extends StatefulWidget {
  final String deviceId;
  final String gate;

  const ScannerAndResultScreen(
      {super.key, required this.deviceId, required this.gate});

  @override
  State<ScannerAndResultScreen> createState() => _ScannerAndResultScreenState();
}

class _ScannerAndResultScreenState extends State<ScannerAndResultScreen>
    with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Map<String, String>? parsedJson;
  bool isValidQR = false;
  bool isSavingData = false;
  bool isSuccess = false; // Track if the data was saved successfully
  String apiResponseMessage = '';
  bool localSaveSuccess = false;
  String selectedAdults = '0';
  String selectedChildren = '0';

  // Function to parse and validate the scanned QR URL
  bool validateAndParseQR(String url) {
    Uri uri = Uri.parse(url);
    if (uri.host == Api.apiUrl.host) {
      parsedJson = uri.queryParameters
          .map((key, value) => MapEntry(key.toLowerCase(), value));
      parsedJson!['device_id'] = widget.deviceId;
      parsedJson!['gate'] = widget.gate;
      return true;
    }
    return false;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && mounted) {
        bool isValid = validateAndParseQR(scanData.code!);
        setState(() {
          isValidQR = isValid;
        });
      }
    });
  }

  Future<void> saveScannedData() async {
    if (parsedJson == null) return;

    setState(() {
      isSavingData = true;
      apiResponseMessage = 'Saving data...';
    });

    // Create a new map with the original parsed data and add adult/children counts
    Map<String, String> visitorData = Map.from(parsedJson!);
    visitorData['adult_count'] = selectedAdults;
    visitorData['child_count'] = selectedChildren;

    // Create the Visitor object using the updated map
    Visitor visitor = Visitor.fromJson(visitorData);

    // Print visitor data to verify
    debugPrint('Visitor data: ${visitor.toJson()}');

    var box = await Hive.openBox('scannedDataBox');

    try {
      await box.add(visitor);
      localSaveSuccess = true;
    } catch (e) {
      debugPrint('Error saving data locally to Hive: $e');
      localSaveSuccess = false;
    }

    await sendDataToAPI(context, [visitor]).then((isApiSuccess) {
      setState(() {
        isSuccess = isApiSuccess && localSaveSuccess;
        apiResponseMessage =
            isSuccess ? 'Visitor confirmed' : 'Failed to save visitor data';
      });
    }).catchError((e) {
      debugPrint('Error sending data to API: $e');
      setState(() {
        isSuccess = false;
        apiResponseMessage = 'Error sending data to API';
      });
    });

    setState(() {
      isSavingData = false;
    });
  }

  void _onScanAgainPressed() {
    setState(() {
      selectedAdults = '0';
      selectedChildren = '0';
      localSaveSuccess = false;
      isValidQR = false;
      parsedJson = null;
      apiResponseMessage = ''; // Clear API response message
      isSuccess = false; // Reset success state
    });
    controller?.resumeCamera(); // Resume the camera for scanning again
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller != null && mounted) {
      if (state == AppLifecycleState.paused) {
        controller?.pauseCamera();
      } else if (state == AppLifecycleState.resumed) {
        controller?.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          KAppbar(appBarTitle: "QR Scanner", iconData: Icons.qr_code_scanner),
      body: isSavingData
          ? const Center(child: CircularProgressIndicator())
          : isValidQR && parsedJson != null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 5,
                      children: [
                        SizedBox(height: 15),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Assets.logo,
                                    width: 100,
                                    height: 100,
                                  ),
                                  Text(
                                    'Visitor Info',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ],
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('ID: ${parsedJson!['unique_id']}',
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Name: ${parsedJson!['name']}',
                                    maxLines: 3,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              Divider(),
                              if (parsedJson!['designation']?.isNotEmpty ??
                                  false)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                      'Designation: ${parsedJson!['designation']}',
                                      maxLines: 4,
                                      style: const TextStyle(fontSize: 18)),
                                ),
                              if (parsedJson!['designation']?.isNotEmpty ??
                                  false)
                                Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'No. of Adults:',
                                  textAlign: TextAlign.left,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    children: List.generate(5, (index) {
                                      return ChoiceChip(
                                        showCheckmark: false,
                                        label: Text((index + 1).toString()),
                                        selected: selectedAdults ==
                                            (index + 1).toString(),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedAdults = selected
                                                ? (index + 1).toString()
                                                : 0.toString();
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'No. of Children:',
                                  textAlign: TextAlign.left,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 8,
                                    children: List.generate(5, (index) {
                                      return ChoiceChip(
                                        showCheckmark: false,
                                        label: Text((index + 1).toString()),
                                        selected: selectedChildren ==
                                            (index + 1).toString(),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedChildren = selected
                                                ? (index + 1).toString()
                                                : 0.toString();
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        if (!isSuccess) const SizedBox(height: 10),
                        if (!isSuccess)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 60),
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: saveScannedData,
                              child: const Text(
                                'Confirm Visitor',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        if (apiResponseMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color:
                                  isSuccess ? Colors.green : Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSuccess ? Icons.check_circle : Icons.error,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    apiResponseMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: (localSaveSuccess)
          ? FloatingActionButton.extended(
              onPressed: _onScanAgainPressed,
              label: const Text("Scan QR"),
              icon: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }
}
