import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'dictionary_screen.dart';

void main() {
  runApp(TranslatorApp());
}

class TranslatorApp extends StatefulWidget {
  @override
  _TranslatorAppState createState() => _TranslatorAppState();
}

class _TranslatorAppState extends State<TranslatorApp> with WidgetsBindingObserver {
  Map<String, String> dictionary = {};
  TextEditingController _controller = TextEditingController();
  String translation = "";
  double keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    loadJSON();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    setState(() {
      keyboardHeight = bottomInset;
    });
  }

  Future<void> loadJSON() async {
    // Get all JSON files from the 'dict' folder
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestJson) as Map<String, dynamic>;
    final jsonFiles = manifest.keys
        .where((key) => key.startsWith('assets/dict/') && key.endsWith('.json'))
        .toList();

    Map<String, String> tempDict = {};

    // Loop through each JSON file
    for (var file in jsonFiles) {
      final rawData = await rootBundle.loadString(file);
      List<dynamic> jsonData = json.decode(rawData);

      // Add dictionary entries from the JSON file to the tempDict
      for (var entry in jsonData) {
        String englishWord = entry['English'].toLowerCase();
        String pulaarWord = entry['Pulaar'].toLowerCase();
        tempDict[englishWord] = pulaarWord;
        tempDict[pulaarWord] = englishWord;
      }
    }

    setState(() {
      dictionary = tempDict;
    });
  }

  void translate() {
    String input = _controller.text.toLowerCase().trim();
    setState(() {
      translation = dictionary.containsKey(input)
          ? 'Translation: \n"${dictionary[input]}"'
          : "Not found";
    });
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
                      ),
                      onSubmitted: (_) => translate(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: translate,
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
                    SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DictionaryScreen(dictionary: dictionary),
                              ),
                            );
                          },
                          child: Text("View Dictionary"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            buildFooter(),
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
