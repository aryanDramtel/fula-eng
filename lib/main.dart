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
  List<Map<String, dynamic>> dictionary = [];
  TextEditingController _controller = TextEditingController();
  String translation = "";
  String fromLang = "English";
  String toLang = "Fula_FoutaDjallon";
  double keyboardHeight = 0.0;

  List<String> languages = ["English", "French", "Fula_FoutaDjallon", "Fula_FoutaToro"];

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
    final rawData = await rootBundle.loadString('assets/merged_dictionary_EN-FR-FDJ-FT.json');
    setState(() {
      dictionary = List<Map<String, dynamic>>.from(json.decode(rawData));
    });
  }

  void translate() {
    String input = _controller.text.toLowerCase().trim();
    for (var entry in dictionary) {
      if (entry[fromLang]?.toLowerCase() == input && entry[toLang]?.isNotEmpty == true) {
        setState(() {
          translation = 'Translation: \n"${entry[toLang]}"';
        });
        return;
      }
    }
    setState(() {
      translation = "Not found";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Fula Translator')),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: fromLang,
                            items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                            onChanged: (val) => setState(() => fromLang = val!),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.swap_horiz),
                          onPressed: () => setState(() {
                            final temp = fromLang;
                            fromLang = toLang;
                            toLang = temp;
                          }),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: toLang,
                            items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                            onChanged: (val) => setState(() => toLang = val!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
            onTap: () => launchUrl(Uri.parse("#")),
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
