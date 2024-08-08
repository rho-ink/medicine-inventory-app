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

  Future<Map<String, int>> _fetchDashboardData() async {
    // Fetch data based on _selectedMonth and _selectedObatName
    int added = await _dataController.getMonthlyAddedGudang(_selectedMonth);
    int reduced = await _dataController
        .getMonthlyTransactionForMedicine(_selectedObatName);
    int deleted = await _dataController
        .getMonthlyDeletedGudangForMedicine(_selectedObatName);

    return {
      'added': added,
      'reduced': reduced,
      'deleted': deleted,
    };
  }

  Future<void> _loadObatNames() async {
    final obatData = await _dataController.getObatNames(); // Adjust method if needed
    setState(() {
      _obatNames = obatData;
    });
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
        // Refresh data based on the new date range
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadObatNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownSearch<String>(
              items: _obatNames,
              onChanged: (String? selected) {
                setState(() {
                  _selectedObatName = selected ?? '';
                });
                // Trigger refresh after selection
                _fetchDashboardData();
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
                  hintText: 'Select Obat',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search Obat',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<Map<String, int>>(
              future: _fetchDashboardData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data'));
                }

                final data = snapshot.data;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DashboardCard(
                          title: 'Added Items', quantity: data?['added'] ?? 0),
                      DashboardCard(
                          title: 'Reduced Items',
                          quantity: data?['reduced'] ?? 0),
                      DashboardCard(
                          title: 'Deleted Items',
                          quantity: data?['deleted'] ?? 0),
                    ],
                  ),
                );
              },
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
      width: 150,
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
