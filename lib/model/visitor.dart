import 'package:hive_flutter/hive_flutter.dart';

part 'visitor.g.dart'; // Generated file by Hive

@HiveType(typeId: 0)
class Visitor extends HiveObject {
  @HiveField(0)
  final String eventsId;

  @HiveField(1)
  final String uniqueId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String designation;

  @HiveField(4)
  final String? gate;

  @HiveField(5)
  final String? deviceId;

  @HiveField(6)
  final String entryDate;

  @HiveField(7)
  final String adultCount;

  @HiveField(8)
  final String childCount;

  // Constructor with entryDate initialized to current time
  Visitor({
    required this.eventsId,
    required this.uniqueId,
    required this.name,
    required this.designation,
    this.gate,
    this.deviceId,
    required this.adultCount,
    required this.childCount,
  }) : entryDate = DateTime.now().toString();

  // Factory constructor to create an instance from JSON
  factory Visitor.fromJson(Map<String, String> json) {
    return Visitor(
      eventsId: json['events_id'] ?? '',
      uniqueId: json['unique_id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      gate: json['gate'],
      deviceId: json['device_id'],
      adultCount: json['adult_count'] ?? '0',
      childCount: json['child_count'] ?? '0',
    );
  }

  // Method to convert the model instance back to JSON
  Map<String, String> toJson() {
    return {
      'events_id': eventsId,
      'unique_id': uniqueId,
      'name': name,
      'designation': designation,
      'gate': gate ?? '',
      'device_id': deviceId ?? '',
      'entry_date': entryDate,
      'adult_count': adultCount,
      'child_count': childCount
    };
  }
}
