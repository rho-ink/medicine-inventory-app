import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:dropdown_search/dropdown_search.dart';
import 'package:admin_app/controllers/data_controller.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DataController _dataController = DataController();
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _selectedObatName = '';
  DateTimeRange? _selectedDateRange;
  List<String> _obatNames = [];
  Map<String, int>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadObatNames();
    _fetchDashboardData(); // Fetch data initially
  }

  Future<void> _fetchDashboardData() async {
    int added = 0;
    int reduced = 0;
    int deleted = 0;

    try {
      added = await _dataController.getMonthlyAddedGudangForMedicine(_selectedMonth);
      reduced = await _dataController.getMonthlyTransactionForMedicine(_selectedObatName);
      deleted = await _dataController.getMonthlyDeletedGudangForMedicine(_selectedObatName);
    } catch (e) {
      // Handle error
    }

    if (mounted) {
      setState(() {
        _dashboardData = {
          'added': added,
          'reduced': reduced,
          'deleted': deleted,
        };
      });
    }
  }

  Future<void> _loadObatNames() async {
    final obatData = await _dataController.getObatNames();
    if (mounted) {
      setState(() {
        _obatNames = obatData;
      });
    }
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: _selectedDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null && pickedDateRange != _selectedDateRange) {
      setState(() {
        _selectedDateRange = pickedDateRange;
        _selectedMonth = DateFormat('yyyy-MM').format(pickedDateRange.start);
        _fetchDashboardData(); // Refresh data based on the new date range
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informasi Data Gudang',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownSearch<String>(
              items: _obatNames,
              onChanged: (String? selected) {
                setState(() {
                  _selectedObatName = selected ?? '';
                });
                _fetchDashboardData(); // Refresh data when an item is selected
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.search,
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _dashboardData == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DashboardCard(
                            title: 'Penerimaan', quantity: _dashboardData?['added'] ?? 0),
                        DashboardCard(
                            title: 'Distribusi',
                            quantity: _dashboardData?['reduced'] ?? 0),
                        DashboardCard(
                            title: 'Kadaluarsa',
                            quantity: _dashboardData?['deleted'] ?? 0),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectDateRange,
        child: Icon(Icons.calendar_today),
      ),
    );
  }
}


class DashboardCard extends StatelessWidget {
  final String title;
  final int quantity;

  DashboardCard({required this.title, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
