# Stray Cats app

A personal prototype of the Stray Cats app. Photograph a cat you meet, say who it is,
and keep its encounters in one place. Your cats are kept in Firebase
(Firestore for the records, Cloud Storage for the photos, anonymous sign-in), and work offline:
photos are saved on the phone first and uploaded when there is a connection. The first launch
needs internet once. Cats kept on the phone before Firebase are imported once, automatically.
See `docs/firebase-design.md`.

## Run

From the repository root:

```bash
cd app
flutter run
```

## Test

```bash
cd app
flutter test
flutter analyze
```

## Spec

The project website at the repository root (Hugo, English and Spanish) is the spec for
this app. Start with `content/ideas/` for what the app should do and why.
