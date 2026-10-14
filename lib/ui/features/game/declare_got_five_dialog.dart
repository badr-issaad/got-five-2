import 'package:flutter/material.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';

class DeclareGotFiveDialog extends StatefulWidget {
  final Player player;
  final List<String> initialGuesses;

  const DeclareGotFiveDialog({
    super.key,
    required this.player,
    this.initialGuesses = const ['', '', '', '', ''],
  });

  @override
  State<DeclareGotFiveDialog> createState() => _DeclareGotFiveDialogState();
}

class _DeclareGotFiveDialogState extends State<DeclareGotFiveDialog> {
  late final List<TextEditingController> _controllers;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (i) => TextEditingController(
        text: i < widget.initialGuesses.length ? widget.initialGuesses[i] : '',
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _validateAndSubmit() {
    final numbers = <int>[];
    for (int i = 0; i < 5; i++) {
      final text = _controllers[i].text.trim();
      final num = int.tryParse(text);
      if (num == null || num < 1 || num > 60) {
        setState(() {
          _error = 'Please enter valid tile numbers between 1 and 60.';
        });
        return;
      }
      numbers.add(num);
    }

    // Verify strictly ascending order
    for (int i = 0; i < 4; i++) {
      if (numbers[i] >= numbers[i + 1]) {
        setState(() {
          _error = 'Numbers must be in strictly ascending order: slot ${i + 1} (${numbers[i]}) must be smaller than slot ${i + 2} (${numbers[i + 1]}).';
        });
        return;
      }
    }

    Navigator.of(context).pop(numbers);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.confirmAnnouncementTitle)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Text(
                l10n.oneAttemptWarning,
                style: const TextStyle(fontSize: 12.5, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.enterYourFiveNumbers,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final color = widget.player.rackColors[index];
                  final tileColor = AppColors.colorForTileColor(color);

                  return SizedBox(
                    width: 52,
                    child: TextField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        filled: true,
                        fillColor: tileColor.withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: tileColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.amberAccent, width: 2.5),
                        ),
                        hintText: Tile.symbolForColor(color).symbolUnicode,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // cancel doesn't consume attempt!
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.black,
          ),
          onPressed: _validateAndSubmit,
          child: Text(l10n.confirmSubmission, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
