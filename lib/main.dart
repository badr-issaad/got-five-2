import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/repositories/local_game_storage.dart';
import 'l10n/app_localizations.dart';
import 'ui/controllers/game_controller.dart';
import 'ui/core/theme.dart';
import 'ui/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await LocalGameStorage.create();
  final gameController = GameController(storage: storage);

  runApp(GotFiveApp(
    storage: storage,
    gameController: gameController,
  ));
}

class GotFiveApp extends StatefulWidget {
  final LocalGameStorage storage;
  final GameController gameController;

  const GotFiveApp({
    super.key,
    required this.storage,
    required this.gameController,
  });

  @override
  State<GotFiveApp> createState() => _GotFiveAppState();
}

class _GotFiveAppState extends State<GotFiveApp> {
  late Locale _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final savedLocale = widget.storage.getPreferredLocale();
    _locale = Locale(savedLocale);

    final savedTheme = widget.storage.getThemeMode();
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void _onLocaleChanged(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  void _onThemeChanged(ThemeMode newMode) {
    setState(() => _themeMode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Got Five!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(
        gameController: widget.gameController,
        storage: widget.storage,
        onLocaleChanged: _onLocaleChanged,
        onThemeChanged: _onThemeChanged,
      ),
    );
  }
}
