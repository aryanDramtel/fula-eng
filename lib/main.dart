// ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(TranslatorApp());
}

class TranslatorApp extends StatefulWidget {
  @override
  _TranslatorAppState createState() => _TranslatorAppState();
}

class _TranslatorAppState extends State<TranslatorApp> with WidgetsBindingObserver {
  Map<String, String> dictionary = {}; // Single dictionary for both directions
  TextEditingController _controller = TextEditingController();
  String translation = "";
  double keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    loadCSV();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      keyboardHeight = bottomInset;
    });
  }

  Future<void> loadCSV() async {
  final rawData = await rootBundle.loadString('assets/dictionary.csv');
  List<List<dynamic>> csvData = const CsvToListConverter(
    eol: "\n", 
    fieldDelimiter: ",", 
    textDelimiter: '"',  
  ).convert(rawData);

  Map<String, String> tempDict = {};

  for (var row in csvData) {
    if (row.length < 2) continue; // Skip invalid rows

    // The last column is the Pulaar word
    String pulaarWord = row.last.toString().toLowerCase().trim();

    // Map each English synonym to the Pulaar word
    for (int i = 0; i < row.length - 1; i++) {
      String englishWord = row[i].toString().toLowerCase().trim();
      tempDict[englishWord] = pulaarWord;
      tempDict[pulaarWord] = englishWord; // Allows reverse lookup
    }
  }

  setState(() {
    dictionary = tempDict;
  });
}


  void translate() {
    String input = _controller.text.toLowerCase();
    if (dictionary.containsKey(input)) {
      // If the word is in the dictionary, determine if it's English or Pulaar
      setState(() {
        // Check if the input word is in English or Pulaar
        if (dictionary[input] != null) {
          if (input == dictionary[input]?.toLowerCase()) {
            // English -> Pulaar
            translation = 'Translation in Pulaar: \n"${dictionary[input]}"';
          } else {
            // Pulaar -> English
            translation = 'Translation in English: \n"${dictionary[input]}"';
          }
        } else {
          translation = "Not found";
        }
      });
    } else {
      setState(() {
        translation = "Not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    appBar: AppBar(title: Text('English - Fula Translator')),
    body: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Enter a word",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onSubmitted: (_) => translate(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: translate,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text("Translate"),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    translation,
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        buildFooter(), // Placing the footer at the bottom naturally
      ],
    ),
  ),
);

  }

  Widget buildFooter() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.black,
      width: double.infinity,
      child: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () => launchUrl(Uri.parse("https://instagram.com/saiyaman_x")),
            child: Text.rich(
              TextSpan(
                text: "Made with ",
                style: TextStyle(color: Colors.white, fontSize: 16),
                children: [
                  WidgetSpan(
                    child: Icon(Icons.favorite, color: Colors.red, size: 16),
                  ),
                  TextSpan(
                    text: " by Aryan",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
