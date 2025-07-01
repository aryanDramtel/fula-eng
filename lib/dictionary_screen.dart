import 'package:flutter/material.dart';

class DictionaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> dictionary;

  DictionaryScreen({required this.dictionary});

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredWords = [];

  @override
  void initState() {
    super.initState();
    _filteredWords = List.from(widget.dictionary);
  }

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = List.from(widget.dictionary);
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredWords = widget.dictionary.where((entry) {
          return (entry['English']?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (entry['French']?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (entry['Fula_FoutaDjallon']?.toLowerCase().contains(lowerQuery) ?? false) ||
                 (entry['Fula_FoutaToro']?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
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
                labelText: "Search any language",
                border: OutlineInputBorder(),
              ),
              onChanged: _filterWords,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(label: Text('English', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('French', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Fouta Djallon', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Fouta Toro', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredWords.map((entry) => DataRow(cells: [
                  DataCell(Text(entry['English'] ?? '')),
                  DataCell(Text(entry['French'] ?? '')),
                  DataCell(Text(entry['Fula_FoutaDjallon'] ?? '')),
                  DataCell(Text(entry['Fula_FoutaToro'] ?? '')),
                  DataCell(Text(entry['source'] ?? '')),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
