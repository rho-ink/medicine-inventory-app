import 'package:flutter/material.dart';
import 'package:admin_app/models/trans_model.dart';
import 'package:admin_app/controllers/data_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<Map<String, Transaksi>> _futureTransaksi;
  final DataController _dataController = DataController();

  @override
  void initState() {
    super.initState();
    _futureTransaksi = _dataController.getTransaksiData(); // Fetch initial data
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureTransaksi = _dataController.getTransaksiData(); // Refresh the data
    });
  }

  Icon getIcon(String type) {
    switch (type) {
      case 'Obat':
        return Icon(Icons.medical_services_outlined);
      case 'UPTD':
        return Icon(Icons.health_and_safety);
      default:
        return Icon(Icons.error); // Handle any other cases or errors
    }
  }

  Future<void> _showDialog() async {
    final currentMonth = DateTime.now().toString().substring(0, 7); // "YYYY-MM"

    // Fetch monthly transaction data
    final monthlyTransactions =
        await _dataController.getMonthlyTotalTransactions(currentMonth);
    // Fetch monthly added Gudang data
    final monthlyAddedGudang =
        await _dataController.getMonthlyAddedGudang(currentMonth);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Monthly Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pengeluaran Bulan Ini: $monthlyTransactions'),
                Text('Penerimaan Bulan Ini: $monthlyAddedGudang'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, Transaksi>>(
          future: _futureTransaksi,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              final transactions = snapshot.data!.values.toList();

              // Sort transactions by date in descending order
              transactions.sort((a, b) => b.date.compareTo(a.date));

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pemakaian Obat Harian',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showDialog(); // Show the dialog with monthly transaction data
                          },
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          var transaction = transactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        getIcon(transaction.tipe),
                                        SizedBox(width: 12),
                                        Text(
                                          transaction.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          transaction.totalTrans.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          transaction.date,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
