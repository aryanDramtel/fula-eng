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
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowOptions = [5, 10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _filteredWords = List.from(widget.dictionary);
  }

  void _filterWords(String query) {
    setState(() {
      _currentPage = 0;
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

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) _currentPage--;
    });
  }

  void _nextPage() {
    setState(() {
      if ((_currentPage + 1) * _rowsPerPage < _filteredWords.length) _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_filteredWords.length / _rowsPerPage).ceil();
    final currentItems = _filteredWords.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();

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

          // Pagination Controls (TOP LEFT)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                  tooltip: "Previous Page",
                ),
                Text("Page ${_currentPage + 1} of $totalPages"),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextPage,
                  tooltip: "Next Page",
                ),
                Spacer(),
                Text("Rows per page: "),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _rowsPerPage = value;
                        _currentPage = 0;
                      });
                    }
                  },
                  items: _rowOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                      .toList(),
                ),
              ],
            ),
          ),

          // ZOOMABLE TABLE
          Expanded(
            child: Center(
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 2.5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('English', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('French', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fouta Djallon', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fouta Toro', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Source', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(currentItems.length, (index) {
                        final entry = currentItems[index];
                        final globalIndex = _currentPage * _rowsPerPage + index + 1;
                        return DataRow(cells: [
                          DataCell(Text(globalIndex.toString())),
                          DataCell(Text(entry['English'] ?? '')),
                          DataCell(Text(entry['French'] ?? '')),
                          DataCell(Text(entry['Fula_FoutaDjallon'] ?? '')),
                          DataCell(Text(entry['Fula_FoutaToro'] ?? '')),
                          DataCell(Text(entry['source'] ?? '')),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
