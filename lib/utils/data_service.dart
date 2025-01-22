import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart'; // For connectivity check
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tnrb/utils/constant.dart';

import '../model/visitor.dart';

// Function to check internet connectivity
Future<bool> isConnectedToInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

Future<bool> sendDataToAPI(BuildContext context, List<Visitor> visitors) async {
  // Check if device is connected to the internet
  if (!await isConnectedToInternet()) {
    // Show SnackBar if there's no internet connection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No internet connection')),
    );
    return false; // Return false if no internet connection
  }

  var headers = {
    'Content-Type': 'application/json',
    'Cookie':
        'PHPSESSID=obfnliq4c47tdsr2or44qtu2gh' // Replace with your session ID
  };
  debugPrint("am here");

  var data = json.encode(
    visitors.map((visitor) => visitor.toJson()).toList(),
  );

  debugPrint(data);

  var dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10), // Increased timeout to 10 seconds
      receiveTimeout: Duration(seconds: 10), // Increased timeout to 10 seconds
    ),
  );

  try {
    var response = await dio.post(
      Api.url,
      data: data,
      options: Options(
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      var responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        debugPrint('Data saved successfully: ${json.encode(responseData)}');
        return true; // API save success
      } else {
        debugPrint('Error: ${responseData?['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData?['message']}')),
        );
        return false; // API save failed
      }
    } else {
      debugPrint('Server error: ${response.statusMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusMessage}')),
      );
      return false; // API save failed due to server error
    }
  } catch (e) {
    debugPrint('Error: $e');

    // Check if it's a DioException with SocketException (Failed host lookup)
    if (e is DioException && e.error is SocketException) {
      // Show SnackBar for network error (host lookup failure)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Failed to connect. Please check your network connection.')),
      );
    } else {
      // Generic error handling for other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    return false; // API save failed due to exception
  }
}
