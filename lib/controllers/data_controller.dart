import 'package:firebase_database/firebase_database.dart';
import 'package:admin_app/models/med_model.dart';
import 'package:admin_app/models/trans_model.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

class DataController {
  final DatabaseReference _gudangRef =
      FirebaseDatabase.instance.ref('gudangData');
  final DatabaseReference _transaksiRef =
      FirebaseDatabase.instance.ref('transaksiData');
  final DatabaseReference _logRef =
      FirebaseDatabase.instance.ref().child('gudangLog');

  // Fetch Gudang data from Firebase
// Fetch Gudang data from Firebase
  Future<Map<String, Gudang>> getGudangData() async {
    try {
      final snapshot = await _gudangRef.get();
      print('Raw snapshot data: ${snapshot.value}');

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? data =
            snapshot.value as Map<dynamic, dynamic>?;
        print('Data runtime type: ${data.runtimeType}');
        print('Data content: $data');

        if (data == null) {
          return {};
        }

        return data.map((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> convertedValue =
                Map<String, dynamic>.from(value);
            return MapEntry(
              key as String,
              Gudang.fromJson(convertedValue, key as String),
            );
          } else {
            print('Unexpected data format for Gudang: $value');
            return MapEntry(
              key as String,
              Gudang(
                id: key as String,
                name: '',
                tipe: '',
                totalObat: 0,
                expiryDetails: {},
              ),
            );
          }
        }).cast<String, Gudang>();
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching Gudang data: $e');
      return {};
    }
  }

  // Fetch Transaksi data from Firebase
  Future<Map<String, Transaksi>> getTransaksiData() async {
    try {
      final snapshot = await _transaksiRef.get();
      print('Raw snapshot data: ${snapshot.value}');

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? data =
            snapshot.value as Map<dynamic, dynamic>?;
        print('Data runtime type: ${data.runtimeType}');
        print('Data content: $data');

        if (data == null) {
          return {};
        }

        return data.map((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final Map<String, dynamic> convertedValue =
                Map<String, dynamic>.from(value);
            return MapEntry(
              key as String,
              Transaksi.fromJson(convertedValue),
            );
          } else {
            print('Unexpected data format for Transaksi: $value');
            return MapEntry(
                key as String,
                Transaksi(
                  id: key as String,
                  date: '',
                  gudangId: '',
                  name: '',
                  tipe: '',
                  totalTrans: 0,
                ));
          }
        }).cast<String, Transaksi>();
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching Transaksi data: $e');
      return {};
    }
  }

  // Add a new Gudang entry to Firebase
  Future<void> addGudang(String id, Gudang gudang) async {
    try {
      await _gudangRef.child(id).set(gudang.toJson());
    } catch (e) {
      print('Error adding Gudang data: $e');
    }
  }

  // Add a new Transaksi entry to Firebase
  Future<void> addTransaksi(String id, Transaksi transaksi) async {
    try {
      await _transaksiRef.child(id).set(transaksi.toJson());
    } catch (e) {
      print('Error adding Transaksi data: $e');
    }
  }

  // Update an existing Gudang entry in Firebasea
  Future<void> deleteExpiryItem(String gudangId, String expiryDate) async {
    try {
      // Fetch current Gudang data
      final gudangData = await getGudangData();
      if (!gudangData.containsKey(gudangId)) {
        print('Gudang ID not found: $gudangId');
        return;
      }

      Gudang gudang = gudangData[gudangId]!;

      // Check if expiry details contain the specified expiryDate
      if (!gudang.expiryDetails.values
          .any((detail) => detail.expiryDate == expiryDate)) {
        print('Expiry date not found: $expiryDate');
        return;
      }

      // Remove the expiry detail from the Gudang's expiryDetails
      gudang.expiryDetails
          .removeWhere((key, detail) => detail.expiryDate == expiryDate);

      // Update total quantity
      int newTotalQuantity = gudang.expiryDetails.values
          .fold(0, (sum, detail) => sum + detail.quantity);

      Gudang updatedGudang = Gudang(
        id: gudang.id,
        name: gudang.name,
        tipe: gudang.tipe,
        totalObat: newTotalQuantity,
        expiryDetails: gudang.expiryDetails,
      );

      print('Updating Gudang stock: ${updatedGudang.toJson()}');

      // Update the Gudang data in Firebase
      await updateGudang(gudang.id, updatedGudang);

      // Optionally, you can also log the deletion in gudangLog
      await _logRef.push().set({
        'action': 'delete',
        'expiryDetail': {
          'name': gudang.name,
          'expiryDate': expiryDate,
          'quantity': 0, // Log quantity if needed
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error deleting Expiry Item: $e');
    }
  }

  //
  Future<void> updateGudang(String id, Gudang gudang) async {
    try {
      await _gudangRef.child(id).update(gudang.toJson());
    } catch (e) {
      print('Error updating Gudang data: $e');
    }
  }

  // Update Gudang stock based on transaction (unused)
  Future<void> updateGudangStock(String gudangId, int quantityChange) async {
    try {
      // Fetch current Gudang data
      final gudangData = await getGudangData();
      if (!gudangData.containsKey(gudangId)) {
        print('Gudang ID not found: $gudangId');
        return;
      }

      Gudang gudang = gudangData[gudangId]!;

      // Check if the new total stock will be negative
      int newTotalQuantity = gudang.totalObat + quantityChange;
      if (newTotalQuantity < 0) {
        print('Insufficient stock in Gudang');
        return;
      }

      // Prioritize expiry details based on submission date
      List<ExpiryDetail> expiryList = gudang.expiryDetails.values.toList();
      expiryList.sort((a, b) => a.submissionDate.compareTo(b.submissionDate));

      int remainingQuantity = quantityChange;
      Map<String, ExpiryDetail> updatedExpiryDetails = {};

      for (var expiry in expiryList) {
        if (remainingQuantity <= 0) break;

        if (expiry.quantity <= remainingQuantity) {
          remainingQuantity -= expiry.quantity;
        } else {
          updatedExpiryDetails[expiry.id] = ExpiryDetail(
            id: expiry.id,
            expiryDate: expiry.expiryDate,
            quantity: expiry.quantity - remainingQuantity,
            submissionDate: expiry.submissionDate,
            batchId: expiry.batchId,
          );
          remainingQuantity = 0;
        }
      }

      // Create updated Gudang object
      Gudang updatedGudang = Gudang(
        id: gudang.id,
        name: gudang.name,
        tipe: gudang.tipe,
        totalObat: newTotalQuantity,
        expiryDetails: updatedExpiryDetails,
      );

      print('Updating Gudang stock: ${updatedGudang.toJson()}');

      // Update the Gudang data in Firebase
      await updateGudang(gudang.id, updatedGudang);
    } catch (e) {
      print('Error updating Gudang stock: $e');
    }
  }

  //calculate
  Future<int> getMonthlyAddedGudangForMedicine(String medicineName) async {
    try {
      final snapshot =
          await _logRef.get(); // Ensure _logRef points to gudangLog
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print('No data found in gudangLog.');
        return 0;
      }

      int totalAddedGudang = 0;
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth =
          DateTime(now.year, now.month + 1, 0); // Last day of the current month

      for (var entry in data.entries) {
        final action = entry.value['action'] as String?;
        final timestampStr = entry.value['timestamp'] as String?;
        final timestamp = DateTime.tryParse(timestampStr ?? '');

        if (action == 'update') {
          final gudangId = entry.value['gudangId'] as String?;
          final beforeData = entry.value['before'] as Map<dynamic, dynamic>?;
          final afterData = entry.value['after'] as Map<dynamic, dynamic>?;

          if (beforeData != null && afterData != null && gudangId != null) {
            final beforeTotal = beforeData['totalObat'] as num?;
            final afterTotal = afterData['totalObat'] as num?;
            final gudangName = afterData['name'] as String?;

            if (beforeTotal != null &&
                afterTotal != null &&
                gudangName == medicineName) {
              final quantityAdded = (afterTotal - beforeTotal).toInt();

              if (timestamp != null &&
                  timestamp
                      .isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
                  timestamp.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
                if (quantityAdded > 0) {
                  totalAddedGudang += quantityAdded;
                }
              }
            }
          }
        }
      }

      return totalAddedGudang;
    } catch (e) {
      print("Error fetching monthly added Gudang: $e");
      return 0;
    }
  }

  Future<int> getMonthlyTransactionForMedicine(String medicineName) async {
    try {
      final snapshot =
          await _transaksiRef.get(); // Ensure _transRef points to transaksiData
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print('No data found in transaksiData.');
        return 0;
      }

      int totalTransaction = 0;
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth =
          DateTime(now.year, now.month + 1, 0); // Last day of the current month

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final name = value['name'] as String?;
          final totalTrans = (value['totalTrans'] as num?)?.toInt();
          final dateStr = value['date'] as String?;
          final date = DateFormat('dd/MM/yyyy').parse(dateStr ?? '');

          if (name == medicineName &&
              totalTrans != null &&
              date.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
              date.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
            totalTransaction += totalTrans;
          }
        }
      });

      return totalTransaction;
    } catch (e) {
      print("Error fetching monthly transaction: $e");
      return 0;
    }
  }

  Future<int> getMonthlyDeletedGudangForMedicine(String medicineName) async {
    try {
      final snapshot =
          await _logRef.get(); // Ensure _logRef points to gudangLog
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print('No data found in gudangLog.');
        return 0;
      }

      int totalDeletedGudang = 0;
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth =
          DateTime(now.year, now.month + 1, 0); // Last day of the current month

      print('Processing log entries...');

      for (var entry in data.entries) {
        final action = entry.value['action'] as String?;
        final timestampStr = entry.value['timestamp'] as String?;
        final timestamp = DateTime.tryParse(timestampStr ?? '');

        print('Processing entry: action=$action, timestamp=$timestampStr');

        if (action == 'delete_expiry_detail' && timestamp != null) {
          if (timestamp.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
              timestamp.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
            final gudangId = entry.value['gudangId'] as String?;
            final deletedDetail =
                entry.value['deletedDetail'] as Map<dynamic, dynamic>?;

            if (deletedDetail != null && gudangId != null) {
              final quantity = deletedDetail['quantity'] as num?;
              final quantityToAdd = quantity?.toInt() ?? 0;

              // Debugging output
              print('Found deleted detail with quantity: $quantityToAdd');

              // Fetch Gudang details by gudangId
              final gudangSnapshot = await _gudangRef.child(gudangId).get();
              final gudangData = gudangSnapshot.value as Map<dynamic, dynamic>?;

              if (gudangData != null) {
                final gudangName = gudangData['name'] as String?;

                if (gudangName == medicineName) {
                  totalDeletedGudang += quantityToAdd;
                  print(
                      'Added $quantityToAdd to totalDeletedGudang for $medicineName.');
                } else {
                  print(
                      'Gudang name $gudangName does not match $medicineName.');
                }
              } else {
                print('Gudang data for ID $gudangId not found.');
              }
            } else {
              print('Deleted detail or Gudang ID missing.');
            }
          } else {
            print('Skipping entry with timestamp outside of this month.');
          }
        } else {
          print('Skipping entry with non-delete action or invalid timestamp.');
        }
      }

      print('Final totalDeletedGudang for $medicineName: $totalDeletedGudang');
      return totalDeletedGudang;
    } catch (e) {
      print("Error fetching monthly deleted Gudang: $e");
      return 0;
    }
  }

  // Stream to get all Gudang items
  Stream<List<Gudang>> get gudangStream {
    return _gudangRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      print('Data received from stream: $data'); // Debugging output
      if (data == null) return [];
      return data.entries.map((e) {
        final gudang =
            Gudang.fromJson(Map<String, dynamic>.from(e.value), e.key);
        print('Parsed Gudang item: $gudang'); // Debugging output
        return gudang;
      }).toList();
    });
  }

  // Add new Obat
  Future<void> addObat(Gudang obat) async {
    await _gudangRef.child(obat.id).set(obat.toJson());
  }

  // Update existing Obat
  Future<void> updateObat(Gudang obat) async {
    await _gudangRef.child(obat.id).update(obat.toJson());
  }

  // Delete Obat
  Future<void> deleteObat(String id) async {
    await _gudangRef.child(id).remove();
  }
}
