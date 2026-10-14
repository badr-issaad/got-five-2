# Got Five! (خمسة أدلة / Trouve Cinq) 🎲

A complete, modern deduction board game application built with **Flutter & Dart**, faithfully implementing the official rules of **Got Five!** by Yoann Levet (Blue Orange Games).

---

## 🌟 Key Features

### 1. Faithful Official Rules Implementation
- **60 Unique Tiles**: 5 colors (Green, Pink, Blue, Red, Yellow) with 12 tiles each.
- **Accurate Dot Sequence**: 1-5 = 1 dot, 6-10 = 2 dots, 11-15 = 3 dots (repeating every 15 tiles). Confirmed USA edition specification: **Tile 38 has 2 dots**.
- **Tactile Stands & Ascending Order**: Players receive 5 random tiles (one of each color) arranged strictly in ascending order. Players see their colors but never their own numbers or dots; opponents' numbers are visible.
- **Turn Flow**:
  1. **Reveal a Tile**: Draw a tile of chosen color from reserve and add it to the common pool (expanding it to 6 tiles).
  2. **Ask for a Clue**: Select 1 of the 6 pool tiles for either **SORT** (fits in 1 of 6 positions relative to hidden rack) or **COMPARE** (yes/no match for dots with a hidden tile).
- **"Got Five!" Guess**: A single attempt per game. Correct = Instant Win! Incorrect = Immediate Elimination. Last player standing wins if all others are eliminated.
- **Digital Edge Case**: Clear reserve depletion fallback allowing direct clue selection when reserve is exhausted.

### 2. Fair AI Opponent (Single Player)
- **Zero-Cheating Guarantee**: The AI algorithm operates purely on public information (opponents' racks, pool tiles, revealed clues, color distributions). It never inspects hidden numbers or RNG seeds.
- **3 Difficulty Tiers**: Easy, Medium, and Hard (with entropy-reducing constraint propagation).
- **State Persistence**: Match progress is automatically saved to local storage upon app closure and can be resumed at any time.

### 3. Trilingual Modern Localization (ARB)
- Modern Standard Arabic (**العربية الفصحى**), **English**, and **French**.
- Full **RTL** support with **locked LTR rack order and mathematical indicators** (`MIN < ... > MAX`) ensuring deduction logic never inverts.
- Dynamic runtime language switching from Settings.

### 4. Tabletop & Paper Hybrid Modes
- **Option A**: Connected devices with printed paper deduction sheets.
- **Option B**: Single shared phone pass-and-play with a full-screen privacy cover between turns.
- **Option C**: Helper phone companion for physical/cut-out tiles.

### 5. Printable Offline PDFs (A4)
- **Full-Color A4 Deduction Sheet**: 60-tile grid, dots, and 5 solution boxes.
- **Eco Ink-Saver B&W Sheet**: Outlined tiles with distinct geometric symbols.
- **Cut-Out Tiles & Stands Sheet**: Printable tiles and foldable paper stands.

### 6. Multiplayer (Online & Local LAN)
- **Local Wi-Fi / Hotspot P2P**: Direct socket host-authoritative play without internet or configuration.
- **Firebase Online Multiplayer**: Guest anonymous authentication, Firestore rooms, and Cloud Functions move validation with secret state isolation (`games/{id}/secrets/master` vs `games/{id}/playerViews/{uid}`).

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.47+ & Dart SDK 3.13+
- Chrome, Android Emulator, or connected physical device

### Running Locally
```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget test suite
flutter test

# Run on connected device (Android or Chrome)
flutter run
```

### Firebase Emulator (Optional)
```bash
# Start local Firebase emulator suite
firebase emulators:start
```
See [FIREBASE_SETUP.md](file:///c:/Dev/got%20five/FIREBASE_SETUP.md) for detailed backend instructions.
