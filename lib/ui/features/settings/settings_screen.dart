import 'package:flutter/material.dart';
import '../../../data/repositories/local_game_storage.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final LocalGameStorage storage;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.onLocaleChanged,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentLocale;
  late String _currentTheme;
  late bool _sound;
  late bool _haptic;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.storage.getPreferredLocale();
    _currentTheme = widget.storage.getThemeMode();
    _sound = widget.storage.isSoundEnabled();
    _haptic = widget.storage.isHapticEnabled();
    _reducedMotion = widget.storage.isReducedMotion();
  }

  void _updateLocale(String code) async {
    await widget.storage.setPreferredLocale(code);
    setState(() => _currentLocale = code);
    widget.onLocaleChanged(Locale(code));
  }

  void _updateTheme(String mode) async {
    await widget.storage.setThemeMode(mode);
    setState(() => _currentTheme = mode);
    widget.onThemeChanged(mode == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ar', label: Text('العربية')),
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'fr', label: Text('Français')),
                    ],
                    selected: {_currentLocale},
                    onSelectionChanged: (set) => _updateLocale(set.first),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Theme section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: Colors.indigoAccent),
                      const SizedBox(width: 8),
                      Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'dark',
                        icon: const Icon(Icons.dark_mode_rounded),
                        label: Text(l10n.darkTheme),
                      ),
                      ButtonSegment(
                        value: 'light',
                        icon: const Icon(Icons.light_mode_rounded),
                        label: Text(l10n.lightTheme),
                      ),
                    ],
                    selected: {_currentTheme},
                    onSelectionChanged: (set) => _updateTheme(set.first),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Toggles
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: Text(l10n.soundEffects),
                  value: _sound,
                  onChanged: (val) {
                    widget.storage.setSoundEnabled(val);
                    setState(() => _sound = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: Text(l10n.hapticFeedback),
                  value: _haptic,
                  onChanged: (val) {
                    widget.storage.setHapticEnabled(val);
                    setState(() => _haptic = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.animation_rounded),
                  title: Text(l10n.reducedMotion),
                  value: _reducedMotion,
                  onChanged: (val) {
                    widget.storage.setReducedMotion(val);
                    setState(() => _reducedMotion = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Accessibility info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.accessibility_new_rounded, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Text(l10n.accessibilityShapes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.accessibilityDesc,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
