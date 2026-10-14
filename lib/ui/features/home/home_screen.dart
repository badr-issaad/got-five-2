import 'package:flutter/material.dart';
import '../../../data/repositories/local_game_storage.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../controllers/game_controller.dart';
import '../../widgets/tile_widget.dart';
import '../game/game_screen.dart';
import '../game/setup_game_screen.dart';
import '../multiplayer/online_room_screen.dart';
import '../pdf/printable_materials_screen.dart';
import '../settings/settings_screen.dart';
import '../tabletop/tabletop_mode_screen.dart';
import '../tutorial/tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  final GameController gameController;
  final LocalGameStorage storage;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.gameController,
    required this.storage,
    required this.onLocaleChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    storage: storage,
                    onLocaleChanged: onLocaleChanged,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Brand Banner with 5 tactile colorful sample tiles
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E1B4B), // Deep indigo
                      Color(0xFF312E81),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.amberAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Row of 5 iconic tiles (one of each color)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TileWidget(tile: Tile.fromNumber(1), width: 44, height: 62),
                          const SizedBox(width: 6),
                          TileWidget(tile: Tile.fromNumber(12), width: 44, height: 62),
                          const SizedBox(width: 6),
                          TileWidget(tile: Tile.fromNumber(23), width: 44, height: 62),
                          const SizedBox(width: 6),
                          TileWidget(tile: Tile.fromNumber(34), width: 44, height: 62),
                          const SizedBox(width: 6),
                          TileWidget(tile: Tile.fromNumber(45), width: 44, height: 62),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resume Game Card (if active saved match exists)
              ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  if (!gameController.hasActiveGame || gameController.state!.isGameOver) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.play_circle_filled_rounded, size: 26),
                      label: Text(
                        '${l10n.resumeGame} (Round ${gameController.state!.turnNumber})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameScreen(controller: gameController),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // 1. Single Player Mode
              _buildMenuCard(
                context: context,
                icon: Icons.person_rounded,
                iconColor: Colors.amberAccent,
                title: l10n.singlePlayer,
                subtitle: 'Challenge 1 to 3 AI opponents with fair deduction.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SetupGameScreen(controller: gameController),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 2. Tabletop & Paper Mode
              _buildMenuCard(
                context: context,
                icon: Icons.table_restaurant_rounded,
                iconColor: Colors.tealAccent,
                title: l10n.tableMode,
                subtitle: 'Single shared phone pass & play, or paper deduction notes.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TabletopModeScreen(controller: gameController),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 3. Online Multiplayer
              _buildMenuCard(
                context: context,
                icon: Icons.public_rounded,
                iconColor: Colors.lightBlueAccent,
                title: l10n.multiplayer,
                subtitle: 'Play with friends via Room Code, QR code, or Local Wi-Fi.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnlineRoomScreen(gameController: gameController),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 4. Tutorial & Training
              _buildMenuCard(
                context: context,
                icon: Icons.school_rounded,
                iconColor: Colors.pinkAccent,
                title: l10n.tutorial,
                subtitle: 'Interactive step-by-step rules and deduction guide.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TutorialScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 5. Printable Materials (PDF)
              _buildMenuCard(
                context: context,
                icon: Icons.print_rounded,
                iconColor: Colors.orangeAccent,
                title: l10n.printMaterials,
                subtitle: 'Offline printable A4 sheets, eco B&W version, and cut-outs.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrintableMaterialsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
