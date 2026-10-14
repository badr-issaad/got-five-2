import 'package:flutter_test/flutter_test.dart';
import 'package:got_five_app/data/repositories/local_game_storage.dart';
import 'package:got_five_app/main.dart';
import 'package:got_five_app/ui/controllers/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Got Five app smoke test boots to HomeScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalGameStorage(prefs);
    final controller = GameController(storage: storage);

    await tester.pumpWidget(GotFiveApp(
      storage: storage,
      gameController: controller,
    ));

    await tester.pumpAndSettle();

    // Verify main screen renders
    expect(find.textContaining('Got Five'), findsWidgets);
  });
}
