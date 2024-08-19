import 'package:flutter/material.dart';
import 'package:admin_app/controllers/data_controller.dart';
import 'package:admin_app/models/med_model.dart'; // Adjust the path according to your project structure
import 'package:intl/intl.dart';  // Import the intl package

class NotificationScreen extends StatelessWidget {
  final DataController dataController = DataController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
      ),
      body: StreamBuilder<List<Gudang>>(
        stream: dataController.gudangStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          var gudangData = snapshot.data!;
          print('Gudang data received: $gudangData');  // Debugging output

          // Calculate unsafe items based on expiry dates
          var unsafeItems = gudangData.expand((gudang) {
            final dateFormat = DateFormat('dd/MM/yyyy');  // Adjust format if needed

            return gudang.expiryDetails.values.where((detail) {
              try {
                DateTime expiryDate = dateFormat.parse(detail.expiryDate);
                DateTime today = DateTime.now();
                Duration difference = expiryDate.difference(today);

                // Determine if item is 'Tidak Aman' based on six-month threshold
                return difference.inDays <= 180;
              } catch (e) {
                print('Error parsing date: ${detail.expiryDate}');
                return false;
              }
            }).map((detail) {
              return {
                'name': gudang.name,
                'batchId': detail.batchId,
                'expiryDate': detail.expiryDate,
                'tipe': gudang.tipe,
              };
            }).toList();
          }).toList();

          print('Unsafe items: $unsafeItems');  // Debugging output

          if (unsafeItems.isEmpty) {
            return Center(child: Text('All items are safe.'));
          }

          return ListView.builder(
            itemCount: unsafeItems.length,
            itemBuilder: (context, index) {
              var item = unsafeItems[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item['tipe'] == 'Obat' ? Icons.medical_services_outlined : Icons.health_and_safety,
                      color: Colors.red, // Red for 'Tidak Aman' status
                    ),
                    title: Text('${item['name']} (${item['batchId']})'),
                    subtitle: Text('Status: Tidak Aman'),
                    trailing: Text(item['expiryDate'] != null
                        ? 'Expires: ${item['expiryDate']}'
                        : 'No expiry date'),
                  ),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
