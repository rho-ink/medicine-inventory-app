import 'package:flutter/material.dart';
import 'package:admin_app/models/med_model.dart';
import 'package:admin_app/controllers/data_controller.dart';

class AddObatPage extends StatefulWidget {
  @override
  _AddObatPageState createState() => _AddObatPageState();
}

class _AddObatPageState extends State<AddObatPage> {
  final DataController _dataController = DataController();
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _tipe = 'Obat'; // Default value

  void _addOrUpdateObat([String? id]) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Gudang obat = Gudang(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        tipe: _tipe,
        totalObat: 0, // Set totalObat to 0
      );

      if (id == null) {
        _dataController.addObat(obat);
      } else {
        _dataController.updateObat(obat);
      }

      Navigator.of(context).pop();
    }
  }

  void _deleteObat(String id) {
    _dataController.deleteObat(id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Obat'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // This might be unnecessary if the StreamBuilder is working
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Gudang>>(
  stream: _dataController.gudangStream,
  builder: (context, AsyncSnapshot<List<Gudang>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No Obat available'));
    }

    // Remove the filtering by 'tipe' to show all Gudang items
    final obatList = snapshot.data!;

    return ListView.builder(
      itemCount: obatList.length,
      itemBuilder: (context, index) {
        final obat = obatList[index];

        return ListTile(
          title: Text(obat.name),
          subtitle: Text('Total: ${obat.totalObat}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showObatDialog(obat),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteObat(obat.id),
              ),
            ],
          ),
        );
      },
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showObatDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showObatDialog([Gudang? obat]) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(obat == null ? 'Add Obat' : 'Edit Obat'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: obat?.name,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                DropdownButtonFormField<String>(
                  value: _tipe,
                  decoration: InputDecoration(labelText: 'Tipe'),
                  items: ['Obat', 'UPTD'].map((tipe) {
                    return DropdownMenuItem(
                      value: tipe,
                      child: Text(tipe),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipe = value!;
                    });
                  },
                  onSaved: (value) => _tipe = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _addOrUpdateObat(obat?.id),
              child: Text(obat == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}
