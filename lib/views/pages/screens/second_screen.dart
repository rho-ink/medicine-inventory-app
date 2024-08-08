import 'package:flutter/material.dart';
import 'package:admin_app/models/med_model.dart'; // Update if the path is different
import 'package:admin_app/controllers/data_controller.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late Future<Map<String, Gudang>> _futureGudangs;
  final DataController _dataController = DataController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureGudangs = _dataController.getGudangData(); // Fetch initial Gudang data
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureGudangs = _dataController.getGudangData(); // Refresh Gudang data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Obat dan BMHP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<Map<String, Gudang>>(
                future: _futureGudangs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    final gudangs = snapshot.data!.values.toList();
                    final filteredGudangs = gudangs.where((gudang) {
                      return gudang.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredGudangs.length,
                      itemBuilder: (context, index) {
                        var gudang = filteredGudangs[index];
                        return ListTile(
                          title: Text(gudang.name),
                          subtitle: Text('Persediaan: ${gudang.totalObat}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 16),
                                onPressed: () {
                                  _navigateToEditGudang(context, gudang);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline, size: 16),
                                onPressed: () {
                                  _showExpiryInfoDialog(gudang);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditGudang(BuildContext context, Gudang gudang) {
    _dataController.getGudangData().then((updatedGudangs) {
      final updatedGudang = updatedGudangs[gudang.id];

      if (updatedGudang != null) {
        final quantityControllers = <String, TextEditingController>{};
        final expiryDatesToDelete = <String>{};

        // Initialize TextEditingControllers for each ExpiryDetail
        updatedGudang.expiryDetails.forEach((id, detail) {
          final controller = TextEditingController(text: detail.quantity.toString());
          quantityControllers[id] = controller;
          print('Initialized controller for $id with quantity ${detail.quantity}');
        });

        print('Controllers before dialog: $quantityControllers');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            List<ExpiryDetail> expiryDetails = updatedGudang.expiryDetails.values.toList();
            
            return StatefulBuilder(
              builder: (context, setState) {
                void _updateTotalQuantity() {
                  setState(() {
                    updatedGudang.totalObat = expiryDetails.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    );
                  });
                }

                void _markForDeletion(String id) {
                  setState(() {
                    expiryDatesToDelete.add(id);
                    expiryDetails.removeWhere((detail) => detail.id == id);
                    final controller = quantityControllers.remove(id);
                    controller?.dispose();
                    _updateTotalQuantity();
                  });
                }

                void _saveChanges() async {
                  try {
                    // Delete marked expiry items
                    for (var id in expiryDatesToDelete) {
                      await _dataController.deleteExpiryItem(updatedGudang.id, id);
                    }

                    final updatedGudangWithCurrentData = Gudang(
                      id: updatedGudang.id,
                      name: updatedGudang.name,
                      tipe: updatedGudang.tipe,
                      totalObat: updatedGudang.totalObat,
                      expiryDetails: Map.fromEntries(
                        expiryDetails.map((detail) => MapEntry(detail.id, detail)),
                      ),
                    );

                    await _dataController.updateGudang(updatedGudang.id, updatedGudangWithCurrentData);

                    Navigator.of(context).pop();

                    _refreshData();
                  } catch (e) {
                    print('Error saving Gudang: $e');
                  }
                }

                print('Expiry Details: $expiryDetails');

                return AlertDialog(
                  title: Text('Edit Data Obat & BMHP: ${updatedGudang.name}'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipe: ${updatedGudang.tipe}'),
                        SizedBox(height: 10),
                        Text('Total Jumlah Obat: ${updatedGudang.totalObat}'),
                        SizedBox(height: 10),
                        Text('Detail Obat & BMHP:'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: expiryDetails.length,
                            itemBuilder: (context, index) {
                              var detail = expiryDetails[index];
                              final controller = quantityControllers[detail.id];
                              print('Detail id: ${detail.id}, Quantity controller text: ${controller?.text}');

                              return ListTile(
                                title: Text('Tanggal Kadaluwarsa: ${detail.expiryDate}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal Masuk: ${detail.submissionDate}'),
                                    TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          detail.quantity = int.tryParse(value) ?? 0;
                                          _updateTotalQuantity();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Jumlah',
                                        hintText: 'Enter quantity',
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _markForDeletion(detail.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: _saveChanges,
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    });
  }

Future<void> _showExpiryInfoDialog(Gudang gudang) {
  List<ExpiryDetail> expiryDetails = gudang.expiryDetails.values.toList();

  // Create infoWidgets for expiry details
  List<Widget> infoWidgets = expiryDetails.map((detail) {
    DateTime expiryDate = DateFormat('dd/MM/yyyy').parse(detail.expiryDate);
    DateTime today = DateTime.now();
    Duration difference = expiryDate.difference(today);

    String status = difference.inDays > 180 ? 'Aman' : 'Tidak Aman';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Tanggal Kadaluwarsa: ${detail.expiryDate} - Status: $status',
        style: TextStyle(
          color: difference.inDays > 180 ? Colors.green : Colors.red,
        ),
      ),
    );
  }).toList();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<Map<String, int>>(
        future: Future.wait([
          _dataController.getMonthlyDeletedGudangForMedicine(gudang.name)
              .then((amount) => {'monthlyDeletedGudang': amount}),
          _dataController.getMonthlyAddedGudangForMedicine(gudang.name)
              .then((amount) => {'monthlyAddedGudang': amount}),
          _dataController.getMonthlyTransactionForMedicine(gudang.name)
              .then((amount) => {'monthlyTransaction': amount}),
        ]).then((results) {
          final monthlyDeletedGudang = results[0]['monthlyDeletedGudang'] ?? 0;
          final monthlyAddedGudang = results[1]['monthlyAddedGudang'] ?? 0;
          final monthlyTransaction = results[2]['monthlyTransaction'] ?? 0;
          return {
            'monthlyDeletedGudang': monthlyDeletedGudang,
            'monthlyAddedGudang': monthlyAddedGudang,
            'monthlyTransaction': monthlyTransaction,
          };
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              title: Text('Informasi Kadaluarsa untuk: ${gudang.name}'),
              content: Center(child: CircularProgressIndicator()),
              actions: [
                TextButton(
                  child: Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Informasi Kadaluarsa untuk: ${gudang.name}'),
              content: Text('Error: ${snapshot.error}'),
              actions: [
                TextButton(
                  child: Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          } else {
            final data = snapshot.data ?? {};
            return AlertDialog(
              title: Text('Informasi Kadaluarsa untuk: ${gudang.name}'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add monthly totals below the title but above the scroll view
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Jumlah Kadaluarsa Bulanan: ${data['monthlyDeletedGudang']?.toString() ?? '0'}',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Jumlah Penerimaan Bulanan: ${data['monthlyAddedGudang']?.toString() ?? '0'}',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Jumlah Transaksi Bulanan: ${data['monthlyTransaction']?.toString() ?? '0'}',
                    ),
                  ),
                  
                  // Add a spacer to provide some margin before the scroll view
                  SizedBox(height: 16),
                  
                  // Wrap the infoWidgets in SingleChildScrollView
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: infoWidgets,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        },
      );
    },
  );
}

}
