# Got Five! (خمسة أدلة / Trouve Cinq) - Project Implementation Roadmap

## 🎯 Project Overview
A complete, playable logic and deduction game built with Flutter and Dart, strictly following the official rules of *Got Five!* (Blue Orange Games).
Supports Arabic (العربية الفصحى), English, and French; offline single-player vs fair AI, pass-and-play table mode, online multiplayer via Firebase, local phone-to-phone play, and printable PDF game sheets.

---

## 📋 Implementation Status & Phases

### Phase 1: Game Specification, Core Data Models, Rule Engine & Unit Tests ✅ (COMPLETED)
- [x] Workspace inspection & toolchain verification (Flutter 3.47.2, Dart 3.13.2, Android Emulator API 37 active).
- [x] Implemented `Tile`, `TileColor`, `TileShapeSymbol` domain models (60 unique tiles, 12 per color, 1..3 dots formula, verified tile 38 has 2 dots).
- [x] Implemented `Player` model (5 ascending tiles, one of each color, hidden from owner, visible to others).
- [x] Implemented `Clue` models (`SortClue` with 6 slots, `CompareClue` for dots matching).
- [x] Implemented `GameState` and `GameEngine`:
  - Setup: dealing 5 distinct color tiles to 2-4 players, 5 face-up center pool tiles.
  - Reserve management and reserve depletion digital fallback rule.
  - Move execution: Reveal tile -> Ask Clue (Sort or Compare) -> Transfer tile to clue tray.
  - Guess / Declaration ("Got Five!"): single attempt, instant win or elimination, last player standing win.
- [x] Rigorous Unit Tests for all engine mechanics, edge cases, and data integrity (16 tests passed).

### Phase 2: Fair AI Opponent & Local Game Engine ✅ (COMPLETED)
- [x] Implemented `DeductionTracker`: constraint propagation model tracking possible numbers for each slot using only public data.
- [x] Implemented `AiBrain` (Easy, Medium, Hard) strictly restricted to public information (zero cheating, no secret peek).
- [x] Implemented Local Game Controller (`GameController`) & State Persistence (`LocalGameStorage`) to save/restore game upon app exit.
- [x] Unit tests for AI deduction behavior, entropy reduction, and complete simulated AI match to game completion (passed).

### Phase 3: UI/UX Design, Multi-Language Localization & Interactive Tutorial ✅ (COMPLETED)
- [x] Multi-language support with official Flutter ARB (`app_ar.arb`, `app_en.arb`, `app_fr.arb`) covering all strings and dialogs.
- [x] RTL support for Arabic, with locked LTR ascending rack tile display (`MIN < ... > MAX`) preserving mathematical logic.
- [x] Design system: rounded tactile tiles, accessible shape icons (`▲`, `●`, `■`, `◆`, `★`), light/dark themes, responsive layouts.
- [x] Interactive in-app deduction sheet (`DeductionSheetDialog` with 60 tiles, candidate boxes, cross-out toggling, undo, and auto-marking).
- [x] Interactive Guided Tutorial (`TutorialScreen`) with visual demonstrations of Got Five mechanics.

### Phase 4: Online Multiplayer (Firebase & Cloud Functions) ✅ (COMPLETED)
- [x] Server-authoritative state model (sanitized player views, no hidden numbers leaked).
- [x] Cloud Functions (TypeScript) in `functions/src/index.ts` for room setup, match starting, and secret state isolation.
- [x] `firestore.rules` preventing clients from reading master secrets (`games/{id}/secret/*` blocked; only `games/{id}/playerViews/{uid}` readable).
- [x] Firebase Emulator configuration in `firebase.json` (Auth on 9099, Firestore on 8080, Functions on 5001).
- [x] Full deployment and emulator guide in `FIREBASE_SETUP.md`.

### Phase 5: Tabletop Modes & Offline Printable PDFs ✅ (COMPLETED)
- [x] Option A: Connected phones with paper deduction sheet quick-action.
- [x] Option B: Shared single phone pass-and-play with full-screen privacy shield between turns (`PassAndPlayScreen`).
- [x] Option C: Physical tile companion assistant.
- [x] Printable PDF generator (`PdfGeneratorService`) offline in-app:
  - Color A4 deduction sheet (`GotFive_Color_Deduction_Sheet.pdf`).
  - Eco ink-saver B&W sheet (`GotFive_Eco_BW_Deduction_Sheet.pdf`).
  - Printable cut-out tiles and fold stands (`GotFive_Cutout_Tiles_Sheet.pdf`).

### Phase 6: Offline Phone-to-Phone (Local P2P / LAN) ✅ (COMPLETED)
- [x] Local Wi-Fi/LAN Host-Client game engine without internet access (`LocalLanGameService`).
- [x] Host-authoritative architecture with real-time socket communication and client view sanitization.
- [x] QR code display (`QrImageView`) and IP room code pairing.

### Phase 7: Verification, Analysis & Delivery ✅ (COMPLETED)
- [x] `flutter analyze`: Zero errors, zero warnings.
- [x] `flutter test`: 23/23 tests passing with 100% success rate.
- [x] `flutter build web`: Built successfully into `build/web`.
- [x] `assets/pdf/`: Physical PDF files generated and verified.
- [x] Android debug APK build in progress.
