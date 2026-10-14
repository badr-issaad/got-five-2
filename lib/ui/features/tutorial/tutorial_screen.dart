import 'package:flutter/material.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../widgets/tile_widget.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final steps = [
      _TutorialStepData(
        title: l10n.tutorialStep1Title,
        description: l10n.tutorialStep1Desc,
        icon: Icons.lightbulb_outline_rounded,
        customWidget: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TileWidget(tile: Tile.hidden(TileColor.green), width: 50, height: 72),
              const SizedBox(width: 6),
              TileWidget(tile: Tile.hidden(TileColor.pink), width: 50, height: 72),
              const SizedBox(width: 6),
              TileWidget(tile: Tile.hidden(TileColor.blue), width: 50, height: 72),
              const SizedBox(width: 6),
              TileWidget(tile: Tile.hidden(TileColor.red), width: 50, height: 72),
              const SizedBox(width: 6),
              TileWidget(tile: Tile.hidden(TileColor.yellow), width: 50, height: 72),
            ],
          ),
        ),
      ),
      _TutorialStepData(
        title: l10n.tutorialStep2Title,
        description: l10n.tutorialStep2Desc,
        icon: Icons.visibility_rounded,
        customWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TileWidget(tile: Tile.fromNumber(14), width: 52, height: 74), // Red
            const SizedBox(width: 8),
            TileWidget(tile: Tile.fromNumber(27), width: 52, height: 74), // Pink
            const SizedBox(width: 8),
            TileWidget(tile: Tile.fromNumber(38), width: 52, height: 74), // Blue
          ],
        ),
      ),
      _TutorialStepData(
        title: l10n.tutorialStep3Title,
        description: l10n.tutorialStep3Desc,
        icon: Icons.add_circle_outline_rounded,
        customWidget: Column(
          children: [
            const Icon(Icons.arrow_downward_rounded, color: Colors.amberAccent, size: 28),
            const SizedBox(height: 6),
            TileWidget(tile: Tile.fromNumber(41), width: 56, height: 80), // Green 41
          ],
        ),
      ),
      _TutorialStepData(
        title: l10n.tutorialStep4Title,
        description: l10n.tutorialStep4Desc,
        icon: Icons.psychology_rounded,
        customWidget: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sort_rounded, color: Colors.indigoAccent),
                  const SizedBox(width: 6),
                  Text(l10n.sortClue, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  const Icon(Icons.compare_arrows_rounded, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Text(l10n.compareClue, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.sortClueDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      _TutorialStepData(
        title: l10n.tutorialStep5Title,
        description: l10n.tutorialStep5Desc,
        icon: Icons.stars_rounded,
        customWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amberAccent, width: 2),
          ),
          child: const Text(
            '🎯 "GOT FIVE!"',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
            ),
          ),
        ),
      ),
    ];

    final isLast = _currentStep == steps.length - 1;
    final step = steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tutorial),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / steps.length,
                backgroundColor: Colors.white12,
                color: AppColors.darkAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Icon(step.icon, size: 54, color: Colors.amberAccent),
                      const SizedBox(height: 16),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 28),
                      step.customWidget,
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: Text(l10n.previousStep),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast ? Colors.amber.shade600 : AppColors.darkAccent,
                      foregroundColor: isLast ? Colors.black : Colors.white,
                    ),
                    onPressed: () {
                      if (isLast) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _currentStep++);
                      }
                    },
                    child: Text(isLast ? l10n.finishTutorial : l10n.nextStep),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStepData {
  final String title;
  final String description;
  final IconData icon;
  final Widget customWidget;

  const _TutorialStepData({
    required this.title,
    required this.description,
    required this.icon,
    required this.customWidget,
  });
}
