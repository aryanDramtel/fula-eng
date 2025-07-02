import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final double currentFontSize;
  final String currentLanguage;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(double) onFontSizeChanged;
  final void Function(String) onLanguageChanged;

  const SettingsScreen({
    Key? key,
    required this.currentTheme,
    required this.currentFontSize,
    required this.currentLanguage,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late double _fontSize;
  late String _language;

  final List<String> supportedLanguages = ['English', 'French'];

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentTheme;
    _fontSize = widget.currentFontSize;
    _language = supportedLanguages.contains(widget.currentLanguage)
        ? widget.currentLanguage
        : 'English';
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString('language', _language);
  }

  void _updateTheme(ThemeMode? mode) {
    if (mode != null) {
      setState(() => _themeMode = mode);
      widget.onThemeChanged(mode);
      _savePreferences();
    }
  }

  void _updateFontSize(double size) {
    setState(() => _fontSize = size);
    widget.onFontSizeChanged(size);
    _savePreferences();
  }

  void _updateLanguage(String lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged(lang);
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Theme', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: _updateTheme,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: _updateTheme,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: _updateTheme,
                ),
              ],
            ),
            const Divider(),
            Text('Font Size', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            Slider(
              value: _fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: _fontSize.toStringAsFixed(0),
              onChanged: _updateFontSize,
            ),
            const Divider(),
            Text('Language Preference', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _language,
              onChanged: (val) => _updateLanguage(val!),
              items: supportedLanguages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
