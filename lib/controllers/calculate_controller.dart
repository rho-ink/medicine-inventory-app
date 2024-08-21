import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalculateController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Helper method to convert date to string in the format 'yyyy-MM'
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  // Parse date from 'dd/MM/yyyy' format
  DateTime _parseDate(String dateStr) {
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dateStr);
      print('Parsed date: $date');
      return date;
    } catch (e) {
      print('Error parsing date: $e. Date string: $dateStr');
      return DateTime.now(); // Handle the error as needed
    }
  }

  Future<int> getCurrentTotalObat(String obatName, DateTimeRange? dateRange) async {
    try {
      int total = 0;
      final snapshot = await _dbRef.child('gudangData').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.values) {
            final item = entry as Map<dynamic, dynamic>;
            final name = item['name'] as String?;
            if (name == obatName) {
              total += (item['totalObat'] as int? ?? 0);
            }
          }
        }
      }
      print('Current Total Obat: $total');
      return total;
    } catch (e) {
      print('Error fetching current total obat: $e');
      return 0;
    }
  }

  Future<int> getPreviousMonthTotalObat(String obatName) async {
    try {
      int total = 0;
      final lastMonth = DateTime.now().subtract(Duration(days: 30));
      final snapshot = await _dbRef.child('gudangData').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.values) {
            final item = entry as Map<dynamic, dynamic>;
            final name = item['name'] as String?;
            final dateStr = item['date'] as String?;
            final date = dateStr != null ? _parseDate(dateStr) : null;

            if (name == obatName && date != null && date.isBefore(DateTime.now()) && date.isAfter(lastMonth)) {
              total += (item['totalObat'] as int? ?? 0);
            }
          }
        }
      }
      print('Previous Month Total Obat: $total');
      return total;
    } catch (e) {
      print('Error fetching previous month total obat: $e');
      return 0;
    }
  }

  Future<int> getTotalDeletedGudang(String obatName, DateTimeRange? dateRange) async {
  try {
    int total = 0;
    final snapshot = await _dbRef.child('gudangLog').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        for (var entry in data.values) {
          final record = entry as Map<dynamic, dynamic>;
          final name = record['name'] as String?;
          final dateStr = record['date'] as String?;
          final date = dateStr != null ? _parseDate(dateStr) : null;

          if (name == obatName && 
              (dateRange == null || 
              (date != null && date.isAfter(dateRange.start) && date.isBefore(dateRange.end)))) {
            total += (record['deletedQuantity'] as int? ?? 0);
          }
        }
      }
    }
    print('Total Deleted Gudang: $total');
    return total;
  } catch (e) {
    print('Error fetching total deleted gudang: $e');
    return 0;
  }
}


  Future<int> getTotalPenerimaan(String obatName, DateTimeRange? dateRange) async {
  try {
    int total = 0;
    final snapshot = await _dbRef.child('gudangLog').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        for (var entry in data.values) {
          final record = entry as Map<dynamic, dynamic>;
          final name = record['name'] as String?;
          final dateStr = record['date'] as String?;
          final date = dateStr != null ? _parseDate(dateStr) : null;

          if (name == obatName && 
              (dateRange == null || 
              (date != null && date.isAfter(dateRange.start) && date.isBefore(dateRange.end)))) {
            total += (record['receivedQuantity'] as int? ?? 0);
          }
        }
      }
    }
    print('Total Penerimaan: $total');
    return total;
  } catch (e) {
    print('Error fetching total penerimaan: $e');
    return 0;
  }
}


  Future<int> getTotalTransaksi(String obatName, DateTimeRange? dateRange) async {
  try {
    int total = 0;
    final snapshot = await _dbRef.child('transaksi').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        for (var entry in data.values) {
          final record = entry as Map<dynamic, dynamic>;
          final name = record['name'] as String?;
          final dateStr = record['date'] as String?;
          final date = dateStr != null ? _parseDate(dateStr) : null;

          if (name == obatName && 
              (dateRange == null || 
              (date != null && date.isAfter(dateRange.start) && date.isBefore(dateRange.end)))) {
            total += (record['totalTrans'] as int? ?? 0);
          }
        }
      }
    }
    print('Total Transaksi: $total');
    return total;
  } catch (e) {
    print('Error fetching total transaksi: $e');
    return 0;
  }
}


  Future<int> getSafetyStock(String obatName, DateTimeRange? dateRange, int threshold) async {
    try {
      int total = 0;
      final snapshot = await _dbRef.child('gudangData').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.values) {
            final item = entry as Map<dynamic, dynamic>;
            final name = item['name'] as String?;
            final stock = item['totalObat'] as int?;

            if (name == obatName && stock != null && stock < threshold) {
              total += (threshold - stock);
            }
          }
        }
      }
      print('Safety Stock: $total');
      return total;
    } catch (e) {
      print('Error fetching safety stock: $e');
      return 0;
    }
  }

  Future<List<String>> getObatNames() async {
    try {
      final snapshot = await _dbRef.child('gudangData').get();
      List<String> obatNames = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          for (var entry in data.values) {
            final item = entry as Map<dynamic, dynamic>;
            final name = item['name'] as String?;
            if (name != null && !obatNames.contains(name)) {
              obatNames.add(name);
            }
          }
        }
      }
      print('Obat Names: $obatNames');
      return obatNames;
    } catch (e) {
      print('Error fetching obat names: $e');
      return [];
    }
  }
}
