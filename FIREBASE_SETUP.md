# Firebase Setup & Server-Authoritative Architecture Guide

## 📌 Architecture Overview
The Got Five! online multiplayer mode enforces a **strict server-authoritative architecture** to guarantee game integrity:
- **Zero Hidden Leakage**: A player's client device is never sent their own secret rack numbers. Only sanitized views (`games/{gameId}/playerViews/{userId}`) are delivered to clients.
- **Server Move Validation**: All actions (Revealing tiles, Sort clues, Compare clues, Got Five declarations) are processed by Cloud Functions (`functions/src/index.ts`).
- **Secret Master State**: Stored in `games/{gameId}/secrets/master` and completely blocked from client read/write by Firestore security rules (`firestore.rules`).

---

## 🛠️ Local Development with Firebase Emulator
To run the full backend locally during development without incurring cloud costs:

1. **Install Firebase CLI** (if not installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Install Functions Dependencies**:
   ```bash
   cd functions
   npm install
   npm run build
   cd ..
   ```

3. **Start the Emulators**:
   ```bash
   firebase emulators:start
   ```
   This will boot:
   - **Authentication Emulator**: `localhost:9099` (Supports anonymous guest login without emails)
   - **Firestore Emulator**: `localhost:8080` (Enforces `firestore.rules`)
   - **Cloud Functions Emulator**: `localhost:5001`
   - **Emulator UI Suite**: `localhost:4000`

4. **Connecting the Flutter App to the Emulator**:
   In `lib/main.dart` or during app initialization, enable:
   ```dart
   if (kDebugMode) {
     FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
     FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
   }
   ```

---

## 🚀 Production Deployment Steps

1. Create a Firebase Project at [https://console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Anonymous Authentication** in the Firebase Console under `Authentication -> Sign-in method`.
3. Create a **Cloud Firestore** database.
4. Deploy Firestore Rules and Indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```
5. Deploy Cloud Functions:
   ```bash
   firebase deploy --only functions
   ```
6. Add your Flutter apps:
   ```bash
   flutterfire configure
   ```

---

## 📡 Disconnection & Reconnection Policy
- **Temporary Disconnect**: If a player loses internet connection, the server preserves their rack and clue state for a 60-second grace window.
- **Permanent Departure**: If the grace period expires without reconnection, the server marks the seat as departed and seamlessly substitutes a fair AI bot so other players can conclude their match without disruption.
- **Single Guess Attempt**: Cloud Functions strictly enforce that `hasGuessed` cannot be reset, preventing players from disconnecting to undo an incorrect guess attempt.
