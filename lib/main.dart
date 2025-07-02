import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l10n/app_localizations.dart';
import 'dictionary_screen.dart';
import 'settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 16;
  String _languageCode = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
      _fontSize = prefs.getDouble('fontSize') ?? 16;
      _languageCode = prefs.getString('language') == 'French' ? 'fr' : 'en';
      _isLoading = false;
    });
  }

  void _updateTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void _updateFontSize(double size) async {
    setState(() => _fontSize = size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  void _updateLanguage(String language) async {
    setState(() => _languageCode = (language == 'French') ? 'fr' : 'en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    final textTheme = TextTheme(
      bodyLarge: TextStyle(fontSize: _fontSize),
      bodyMedium: TextStyle(fontSize: _fontSize),
      bodySmall: TextStyle(fontSize: _fontSize - 2),
      titleLarge: TextStyle(fontSize: _fontSize + 2),
      titleMedium: TextStyle(fontSize: _fontSize),
      titleSmall: TextStyle(fontSize: _fontSize - 2),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(_languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _themeMode,
      theme: ThemeData(brightness: Brightness.light, textTheme: textTheme),
      darkTheme: ThemeData(brightness: Brightness.dark, textTheme: textTheme),
      home: TranslatorApp(
        themeMode: _themeMode,
        fontSize: _fontSize,
        languageCode: _languageCode,
        onThemeChanged: _updateTheme,
        onFontSizeChanged: _updateFontSize,
        onLanguageChanged: _updateLanguage,
      ),
    );
  }
}

class TranslatorApp extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final void Function(double) onFontSizeChanged;
  final void Function(String) onLanguageChanged;
  final ThemeMode themeMode;
  final double fontSize;
  final String languageCode;

  const TranslatorApp({
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onLanguageChanged,
    required this.themeMode,
    required this.fontSize,
    required this.languageCode,
  });

  @override
  State<TranslatorApp> createState() => _TranslatorAppState();
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
    final local = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.appTitle, style: textTheme.titleLarge),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(local.menu, style: TextStyle(color: Colors.white, fontSize: widget.fontSize + 4)),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(local.dictionary, style: textTheme.titleMedium),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DictionaryScreen(dictionary: dictionary),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(local.settings, style: textTheme.titleMedium),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      currentTheme: widget.themeMode,
                      currentFontSize: widget.fontSize,
                      currentLanguage: widget.languageCode == 'fr' ? 'French' : 'English',
                      onThemeChanged: widget.onThemeChanged,
                      onFontSizeChanged: widget.onFontSizeChanged,
                      onLanguageChanged: widget.onLanguageChanged,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(local.about, style: textTheme.titleMedium),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(local.about),
                    content: Text(local.aboutText),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(local.close))
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: local.enterWord,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onSubmitted: (_) => translate(),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: translate,
                    child: Text(local.translate, style: textTheme.bodyMedium),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      translation,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildFooter(context),
        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context) {
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
                style: TextStyle(color: Colors.white, fontSize: widget.fontSize),
                children: [
                  WidgetSpan(child: Icon(Icons.favorite, color: Colors.red, size: widget.fontSize)),
                  TextSpan(
                    text: " by Aryan",
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
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
