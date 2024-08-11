import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
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
  String _filterType = 'daily'; // Default filter type

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

  List<Transaksi> _filterTransactions(List<Transaksi> transactions) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy'); // Date format

    if (_filterType == 'daily') {
      // Filter for today's transactions
      return transactions.where((trans) {
        try {
          final transDate = dateFormat.parse(trans.date);
          return transDate.year == now.year &&
              transDate.month == now.month &&
              transDate.day == now.day;
        } catch (e) {
          return false; // If parsing fails, exclude the transaction
        }
      }).toList();
    } else if (_filterType == 'monthly') {
      // Filter for this month's transactions
      return transactions.where((trans) {
        try {
          final transDate = dateFormat.parse(trans.date);
          return transDate.year == now.year && transDate.month == now.month;
        } catch (e) {
          return false; // If parsing fails, exclude the transaction
        }
      }).toList();
    }
    return transactions; // No filtering if filterType is not recognized
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
              var transactions = snapshot.data!.values.toList();
              transactions.sort((a, b) => b.date.compareTo(a.date));

              // Filter transactions based on selected filter type
              transactions = _filterTransactions(transactions);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pemakaian Obat dan BMHP',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        ToggleButtons(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Harian'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Bulanan'),
                                ),
                              ],
                              isSelected: [_filterType == 'daily', _filterType == 'monthly'],
                              onPressed: (int index) {
                                setState(() {
                                  _filterType = index == 0 ? 'daily' : 'monthly';
                                });
                              },
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
