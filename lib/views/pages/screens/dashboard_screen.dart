import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:admin_app/controllers/calculate_controller.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CalculateController _calculateController = CalculateController();
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _selectedObatName = '';
  DateTimeRange? _selectedDateRange;
  List<String> _obatNames = [];
  Map<String, int>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadObatNames();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    int currentTotalObat = 0;
    int previousMonthTotalObat = 0;
    int totalDeleted = 0;
    int totalPenerimaan = 0;
    int totalTransaksi = 0;
    int safetyStock = 0;

    try {
      print('Fetching dashboard data...');
      currentTotalObat = await _calculateController.getCurrentTotalObat(_selectedObatName, _selectedDateRange);
      previousMonthTotalObat = await _calculateController.getPreviousMonthTotalObat(_selectedObatName);
      totalDeleted = await _calculateController.getTotalDeletedGudang(_selectedObatName, _selectedDateRange);
      totalPenerimaan = await _calculateController.getTotalPenerimaan(_selectedObatName, _selectedDateRange);
      totalTransaksi = await _calculateController.getTotalTransaksi(_selectedObatName, _selectedDateRange);
      safetyStock = await _calculateController.getSafetyStock(_selectedObatName, _selectedDateRange, 1);

      print('Dashboard data fetched: $currentTotalObat, $previousMonthTotalObat, $totalDeleted, $totalPenerimaan, $totalTransaksi, $safetyStock');
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }

    if (mounted) {
      setState(() {
        _dashboardData = {
          'currentTotalObat': currentTotalObat,
          'previousMonthTotalObat': previousMonthTotalObat,
          'totalDeleted': totalDeleted,
          'totalPenerimaan': totalPenerimaan,
          'totalTransaksi': totalTransaksi,
          'safetyStock': safetyStock,
        };
      });
    }
  }

  Future<void> _loadObatNames() async {
    print('Loading obat names...');
    final obatNames = await _calculateController.getObatNames();
    print('Obat names loaded: $obatNames');
    setState(() {
      _obatNames = obatNames;
    });
  }

  void _onMonthChanged(DateTime? date) {
    if (date != null) {
      setState(() {
        _selectedMonth = DateFormat('yyyy-MM').format(date);
        _selectedDateRange = DateTimeRange(
          start: DateTime(date.year, date.month, 1),
          end: DateTime(date.year, date.month + 1, 0),
        );
        _fetchDashboardData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Dashboard'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownSearch<String>(
              items: _obatNames,
              selectedItem: _selectedObatName,
              dropdownBuilder: (context, selectedItem) => Text(
                selectedItem ?? "Choose Obat",
                style: TextStyle(color: selectedItem == null ? Colors.grey : Colors.black),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedObatName = value ?? '';
                  print('Selected obat: $_selectedObatName');
                  _fetchDashboardData();
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Bulan: $_selectedMonth'),
            ElevatedButton(
              onPressed: () async {
                DateTime? date = await showMonthPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                _onMonthChanged(date);
              },
              child: const Text('Pilih Bulan'),
            ),
            Expanded(
              child: ListView(
                children: [
                  _dashboardData != null
                      ? Card(
                          child: ListTile(
                            title: const Text('Total Persediaan'),
                            subtitle: Text('${_dashboardData!['currentTotalObat']}'),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                  Card(
                    child: ListTile(
                      title: const Text('Stok Awal'),
                      subtitle: Text('${_dashboardData?['previousMonthTotalObat'] ?? 0}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Total Kadaluarsa'),
                      subtitle: Text('${_dashboardData?['totalDeleted'] ?? 0}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Total Penerimaan'),
                      subtitle: Text('${_dashboardData?['totalPenerimaan'] ?? 0}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Total Pengeluaran'),
                      subtitle: Text('${_dashboardData?['totalTransaksi'] ?? 0}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Safety Stock'),
                      subtitle: Text('${_dashboardData?['safetyStock'] ?? 0}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
