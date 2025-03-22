import 'package:flutter/material.dart';

class DictionaryScreen extends StatefulWidget {
  final Map<String, String> dictionary;

  DictionaryScreen({required this.dictionary});

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, String>> _filteredWords = [];

  @override
  void initState() {
    super.initState();
    _filteredWords = widget.dictionary.entries.toList();
  }

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = widget.dictionary.entries.toList();
      } else {
        _filteredWords = widget.dictionary.entries
            .where((entry) => entry.key.contains(query.toLowerCase()) || entry.value.contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dictionary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
              ),
              onChanged: _filterWords,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('English', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Pulaar', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredWords.map((entry) => DataRow(cells: [
                  DataCell(Text(entry.key)),
                  DataCell(Text(entry.value)),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
