import 'package:cloud_firestore/cloud_firestore.dart';

class Meter {
  final String meterNumber;
  final double currentReading;
  final DateTime lastReadingDate;
  final String provider;
  final double monthlyAverage;
  final double yearlyTotal;

  Meter({
    required this.meterNumber,
    required this.currentReading,
    required this.lastReadingDate,
    required this.provider,
    required this.monthlyAverage,
    required this.yearlyTotal,
  });

  factory Meter.fromMap(Map<String, dynamic> map) {
    return Meter(
      meterNumber: map['meterNumber'] ?? '',
      currentReading: (map['currentReading'] ?? 0.0).toDouble(),
      lastReadingDate: map['lastReadingDate'] != null
          ? (map['lastReadingDate'] as Timestamp).toDate()
          : DateTime.now(),
      provider: map['provider'] ?? '',
      monthlyAverage: (map['monthlyAverage'] ?? 0.0).toDouble(),
      yearlyTotal: (map['yearlyTotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'meterNumber': meterNumber,
      'currentReading': currentReading,
      'lastReadingDate': lastReadingDate,
      'provider': provider,
      'monthlyAverage': monthlyAverage,
      'yearlyTotal': yearlyTotal,
    };
  }

  Meter copyWith({
    String? meterNumber,
    double? currentReading,
    DateTime? lastReadingDate,
    String? provider,
    double? monthlyAverage,
    double? yearlyTotal,
  }) {
    return Meter(
      meterNumber: meterNumber ?? this.meterNumber,
      currentReading: currentReading ?? this.currentReading,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      provider: provider ?? this.provider,
      monthlyAverage: monthlyAverage ?? this.monthlyAverage,
      yearlyTotal: yearlyTotal ?? this.yearlyTotal,
    );
  }
}
