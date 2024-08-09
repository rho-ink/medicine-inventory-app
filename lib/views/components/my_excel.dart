import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:admin_app/controllers/data_controller.dart'; // Import your DataController

Future<void> exportToExcel() async {
  try {
    final dataController = DataController();

    // Fetch Gudang data
    final gudangData = await dataController.getGudangData();

    // Create an Excel document
    var excel = Excel.createExcel(); // Creates a new Excel document

    // Add a sheet to the document
    Sheet sheet = excel['Sheet1'];

    // Add headers to the sheet
    sheet.appendRow([
      TextCellValue('Nama'),
      TextCellValue('Tipe'),
      TextCellValue('Persediaan'),
      TextCellValue('Penerimaan Bulanan'),
      TextCellValue('Pengeluaran Bulanan'),
      TextCellValue('Kadaluarsa Bulanan')
    ]);

    // Process each Gudang and fill in the data
    for (var gudang in gudangData.values) {
      // Calculate the required fields
      final persediaan = gudang.totalObat;
      final penerimaanBulanan = await dataController.getMonthlyAddedGudangForMedicine(gudang.name); // Modify as needed
      final pengeluaranBulanan = await dataController.getMonthlyTransactionForMedicine(gudang.name); // Modify as needed
      final kadaluarsaBulanan = await dataController.getMonthlyDeletedGudangForMedicine(gudang.name); // Modify as needed

      // Append a row to the sheet
      sheet.appendRow([
        TextCellValue(gudang.name),
        TextCellValue(gudang.tipe),
        DoubleCellValue(persediaan.toDouble()), // Ensure persediaan is a number
        DoubleCellValue(penerimaanBulanan.toDouble()), // Ensure penerimaanBulanan is a number
        DoubleCellValue(pengeluaranBulanan.toDouble()), // Ensure pengeluaranBulanan is a number
        DoubleCellValue(kadaluarsaBulanan.toDouble()), // Ensure kadaluarsaBulanan is a number
      ]);
    }

     // Save the Excel file to device storage
    var directory = await getExternalStorageDirectory();
    if (directory != null) {
      var path = '${directory.path}/inventory_data.xlsx';
      var file = File(path);
      await file.writeAsBytes(await excel.encode()!);

      // Print the file path
      print('Excel file created at $path');
    } else {
      print('Directory not found');
    }
  } catch (e) {
    print('Error exporting to Excel: $e');
  }
}
