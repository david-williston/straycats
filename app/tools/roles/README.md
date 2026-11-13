# Roles tool

`set-role.mjs` grants or revokes a global role (`admin`) for a Stray Cats user. It sets the
Firebase custom claim, which the Firestore and Storage rules enforce. It also writes
`roles/{uid}` and an append-only `roles/{uid}/history/{id}` entry as the readable record.
See `app/docs/access-design.md`.

## Prerequisites

- Node 20 or newer, then `npm install` in this folder.
- Your own Google login as Application Default Credentials. No service-account key file is used
  or written:

  ```bash
  gcloud auth application-default login
  ```

  Your account needs permission on project `straycats-love` (Firebase Auth admin and Firestore
  write).

## Usage

```bash
node set-role.mjs grant david@example.com admin --dry-run   # show what would change
node set-role.mjs grant david@example.com admin
node set-role.mjs revoke <uid> admin
```

The target is a uid or an email (looked up in Firebase Auth). The script prints the claims and
`roles/{uid}` before and after.

## Seeing the change

Claims ride on the ID token. The person must sign out and in again, or the app must call
`getIdTokenResult(true)`, before the claim shows. Revoking takes the same step (a token lasts up
to an hour).
