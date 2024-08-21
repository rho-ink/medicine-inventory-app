import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:admin_app/models/med_model.dart';
import 'package:admin_app/models/trans_model.dart';
import 'package:admin_app/controllers/data_controller.dart';

class AddTransaksi extends StatefulWidget {
  const AddTransaksi({Key? key}) : super(key: key);

  @override
  State<AddTransaksi> createState() => _AddTransaksiState();
}

class _AddTransaksiState extends State<AddTransaksi> {
  final TextEditingController totalController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController submissionController = TextEditingController();
  DateTime selectDate = DateTime.now();
  Gudang? selectedGudang;
  final DataController _dataController = DataController();

  final _formKey = GlobalKey<FormState>();

  // Declare the Future variable
  late Future<Map<String, Gudang>> futureGudangData;

  @override
  void initState() {
    super.initState();
    // Initialize the Future variable here
    futureGudangData = _dataController.getGudangData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Gudang>>(
      future: futureGudangData, // Use the initialized Future here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state with placeholder UI
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No Gudang data available.');
          return Center(child: Text('No Gudang data available.'));
        } else {
          List<Gudang> gudangs = snapshot.data!.values.toList();
          print('Gudang data loaded: ${gudangs.length} items');
          return _buildFormUI(gudangs);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Tambah Data Transaksi'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Loading...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            _buildTextFieldPlaceholder(),
            SizedBox(height: 10),
            _buildDropdownPlaceholder(),
            SizedBox(height: 10),
            _buildTextFieldPlaceholder(),
            SizedBox(height: 10),
            _buildTextFieldPlaceholder(),
            SizedBox(height: 10),
            _buildButtonPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldPlaceholder() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildDropdownPlaceholder() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildButtonPlaceholder() {
    return Container(
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16.0),
      ),
    );
  }

  Widget _buildFormUI(List<Gudang> gudangs) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Tambah Data Transaksi'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tambah Data Transaksi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.purple[200]),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.medication_liquid_sharp,
                    size: 20,
                    color: Colors.grey,
                  ),
                  filled: true,
                  hintText: 'Jumlah',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan jumlah';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Quantity must be a positive number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownSearch<Gudang>(
                items: gudangs,
                itemAsString: (Gudang item) => item.name,
                onChanged: (Gudang? selected) {
                  setState(() {
                    selectedGudang = selected;
                    if (selected != null) {
                      nameController.text = selected.name;
                    }
                    print('Data Terpilih: ${selected?.name}');
                  });
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      CupertinoIcons.list_dash,
                      size: 20,
                      color: Colors.grey,
                    ),
                    filled: true,
                    hintText: 'Pilih Obat dan BMHP',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Cari obat dan BMHP',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                readOnly: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.medication_liquid_sharp,
                    size: 20,
                    color: Colors.grey,
                  ),
                  filled: true,
                  hintText: 'Nama obat dan BMHP',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: submissionController,
                readOnly: true,
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (newDate != null) {
                    setState(() {
                      submissionController.text =
                          DateFormat('dd/MM/yyyy').format(newDate);
                      selectDate = newDate;
                    });
                  }
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    CupertinoIcons.calendar,
                    size: 20,
                    color: Colors.grey,
                  ),
                  filled: true,
                  hintText: 'Tanggal Transaksi',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon Pilih Tanggal';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (selectedGudang != null) {
                        _saveData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mohon Pilih Obat dan BMHP')),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveData() {
    if (selectedGudang == null) {
      print('No Gudang selected');
      return;
    }

    int quantityToDeduct = int.tryParse(totalController.text) ?? 0;

    print('Quantity to Deduct: $quantityToDeduct');

    // Validate quantity to be deducted
    if (quantityToDeduct <= 0) {
      print('Quantity must be greater than 0');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }

    if (quantityToDeduct > selectedGudang!.totalObat) {
      print(
          'Stock Gudang does not match. Available: ${selectedGudang!.totalObat}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok Gudang Tidak Sesuai')),
      );
      return;
    }

    print('Proceeding with stock update and transaction');
    // Proceed with updating Gudang stock and adding transaction
    _updateGudangStock(quantityToDeduct);
  }

  void _updateGudangStock(int quantityToDeduct) {
    // Retrieve and sort expiry details by date (FEFO)
    List<MapEntry<String, ExpiryDetail>> sortedExpiryDetails =
        selectedGudang!.expiryDetails.entries.toList()
          ..sort((a, b) => a.value.expiryDate.compareTo(b.value.expiryDate));

    print('Sorted Expiry Details:');
    for (var entry in sortedExpiryDetails) {
      print(
          'Batch ID: ${entry.value.batchId}, Expiry Date: ${entry.value.expiryDate}, Quantity: ${entry.value.quantity}');
    }

    int remainingQuantity = quantityToDeduct;
    Map<String, ExpiryDetail> updatedExpiryDetails = {};

    // Process batches according to FEFO
    for (var entry in sortedExpiryDetails) {
      String key = entry.key;
      ExpiryDetail detail = entry.value;

      print(
          'Processing Batch ID: $key, Quantity: ${detail.quantity}, Remaining Quantity: $remainingQuantity');

      if (remainingQuantity <= 0) {
        // No more quantity to deduct, retain remaining batches
        updatedExpiryDetails[key] = detail;
        print('Retained Batch ID: $key');
        continue;
      }

      if (detail.quantity > remainingQuantity) {
        // Deduct part of the batch and update its quantity
        updatedExpiryDetails[key] = ExpiryDetail(
          id: key,
          expiryDate: detail.expiryDate,
          quantity: detail.quantity - remainingQuantity,
          submissionDate: detail.submissionDate,
          batchId: detail.batchId,
        );
        print(
            'Updated Batch ID: $key, New Quantity: ${detail.quantity - remainingQuantity}');
        remainingQuantity = 0;
      } else {
        // Fully deduct the batch, remove it from stock
        print(
            'Exhausted Batch ID: $key, Deducted Quantity: ${detail.quantity}');
        remainingQuantity -= detail.quantity;
      }
    }

    // Only retain non-exhausted batches
    updatedExpiryDetails.removeWhere((key, detail) => detail.quantity <= 0);

    int updatedTotal = selectedGudang!.totalObat - quantityToDeduct;

    print('Updated Total Obat: $updatedTotal');

    Gudang updatedGudang = Gudang(
      id: selectedGudang!.id,
      name: selectedGudang!.name,
      tipe: selectedGudang!.tipe,
      totalObat: updatedTotal,
      expiryDetails: updatedExpiryDetails,
    );

    print('Updating Gudang with id: ${updatedGudang.id}');
    _dataController.updateGudang(selectedGudang!.id, updatedGudang);

    // Create and add the new transaction
    Transaksi newTransaction = Transaksi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: submissionController.text,
      gudangId: selectedGudang!.id,
      name: selectedGudang!.name,
      tipe: selectedGudang!.tipe,
      totalTrans: -quantityToDeduct,
    );

    print(
        'Creating Transaction: ID: ${newTransaction.id}, Total Trans: ${newTransaction.totalTrans}');
    _dataController.addTransaksi(newTransaction.id, newTransaction);

    Navigator.of(context).pop();
  }
}
