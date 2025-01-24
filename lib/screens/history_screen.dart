import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/visitor.dart';
import '../utils/data_service.dart';
import '../widgets/appbar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Visitor> scannedVisitors = [];
  String apiResponseMessage = '';
  bool isSuccess = false;
  bool apiSaveSuccess = false;
  bool isUploading = false;

  Future<void> _loadScannedData() async {
    // Open the Hive box
    var box = await Hive.openBox('scannedDataBox');

    // Load the scanned data (all visitor objects in the box)
    final List<Visitor> scannedVisitors = box.values.toList().cast<Visitor>();

    setState(() {
      this.scannedVisitors = scannedVisitors;
    });
  }

  Future<void> _clearScannedData() async {
    // Open the Hive box
    var box = await Hive.openBox('scannedDataBox');

    // Clear the data in the box
    await box.clear();

    setState(() {
      // Clear the local scanned visitors list
      scannedVisitors.clear();
    });
  }

  // Show confirmation dialog for delete or upload actions
  Future<bool> _showConfirmationDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    _loadScannedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KAppbar(
        appBarTitle: "History",
        iconData: Icons.history,
        isHistoryPage: true,
      ),
      body: isUploading
          ? Center(child: CircularProgressIndicator())
          : scannedVisitors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_sharp, size: 100),
                      Text(
                        'No scan history available.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: scannedVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = scannedVisitors.reversed.toList()[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          "ID : ${visitor.uniqueId}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name : ${visitor.name}'),
                            Visibility(
                              visible: visitor.designation.isNotEmpty,
                              child: Text(
                                'Designation: ${visitor.designation}',
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      floatingActionButton: Visibility(
        visible: scannedVisitors.isNotEmpty,
        child: FloatingActionButton.extended(
          onPressed: _sendDataToApi,
          tooltip: 'Upload Data to API',
          heroTag: 'exportToApiFAB', // Unique heroTag
          icon: const Icon(Icons.cloud_sync_outlined),
          label: const Text('Sync To db'),
        ),
      ),
    );
  }

  Future<void> _sendDataToApi() async {
    // Ask for confirmation before uploading data
    bool confirmUpload = await _showConfirmationDialog(
      context,
      'Are you sure you want to upload the scanned data?',
    );
    if (!confirmUpload) {
      return;
    }

    if (scannedVisitors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scanned data to send')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    await sendDataToAPI(context, scannedVisitors).then((isApiSuccess) {
      apiSaveSuccess = isApiSuccess;
      setState(() {
        if (apiSaveSuccess) {
          _clearScannedData();
          apiResponseMessage = 'Visitor Saved Successfully';
          isSuccess = true;
        } else {
          apiResponseMessage = 'Failed to save visitor data to API';
        }
        isUploading = false;
      });
    }).catchError((e) {
      debugPrint('Error sending data to API: $e');
      setState(() {
        apiResponseMessage = 'Error sending data to API';
        isUploading = false;
      });
    });

    // Display the result as a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(apiResponseMessage)),
    );
  }
}
