import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:admin_app/models/med_model.dart';
import 'package:admin_app/controllers/data_controller.dart';

class AddGudang extends StatefulWidget {
  const AddGudang({Key? key}) : super(key: key);

  @override
  State<AddGudang> createState() => _AddGudangState();
}

class _AddGudangState extends State<AddGudang> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController totalController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController submissionController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController batchIdController = TextEditingController();
  DateTime? selectSubmissionDate;
  DateTime? selectExpiryDate;
  Gudang? selectedGudang;
  final DataController _dataController = DataController();

  // Declare the Future variable
  late Future<Map<String, Gudang>> futureGudangData;

  @override
  void initState() {
    super.initState();
    print('AddGudang initState');
    // Initialize the Future variable here
    futureGudangData = _dataController.getGudangData(); // Changed
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Gudang>>(
      future: futureGudangData, // Use the initialized Future here // Changed
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading Gudang data...');
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
          // title: Text('Tambah Data Gudang'),
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
          // title: Text('Tambah Data Gudang'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tambah Data Gudang',
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
                  hintText: 'Pcs',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan jumlah';
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
                    print('Data terpilih: ${selected?.name}');
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
                      hintText: 'Cari Obat dan BMHP',
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
                  hintText: 'Nama Obat dan BMHP',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: batchIdController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.tag,
                    size: 20,
                    color: Colors.grey,
                  ),
                  filled: true,
                  hintText: 'Batch ID',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan Batch ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: submissionController,
                readOnly: true,
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectSubmissionDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (newDate != null) {
                    setState(() {
                      submissionController.text =
                          DateFormat('dd/MM/yyyy').format(newDate);
                      selectSubmissionDate = newDate;
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
                  hintText: 'Tanggal penerimaan',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon Pilih tanggal penerimaan';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: expiryController,
                readOnly: true,
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectExpiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (newDate != null) {
                    setState(() {
                      expiryController.text =
                          DateFormat('dd/MM/yyyy').format(newDate);
                      selectExpiryDate = newDate;
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
                  hintText: 'Tanggal Kadaluarsa',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon pilih tanggal kadaluarsa';
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
                      if (selectedGudang == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mohon Pilih Obat dan BMHP')),
                        );
                      } else {
                        _saveData();
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
    if (selectedGudang == null) return;

    String newDetailId = DateTime.now().millisecondsSinceEpoch.toString();

    ExpiryDetail newDetail = ExpiryDetail(
      id: newDetailId,
      expiryDate: expiryController.text,
      quantity: int.tryParse(totalController.text) ?? 0,
      submissionDate: submissionController.text,
       batchId: batchIdController.text,
    );

    Map<String, ExpiryDetail> updatedExpiryDetails = {
      ...selectedGudang!.expiryDetails,
      newDetailId: newDetail,
    };

    int updatedTotal = selectedGudang!.totalObat + newDetail.quantity;

    Gudang updatedGudang = Gudang(
      id: selectedGudang!.id,
      name: selectedGudang!.name,
      tipe: selectedGudang!.tipe,
      totalObat: updatedTotal,
      expiryDetails: updatedExpiryDetails,
    );

    print('Updating Gudang with id: ${updatedGudang.id}');

    _dataController.updateGudang(selectedGudang!.id, updatedGudang);

    Navigator.of(context).pop();
  }
}
