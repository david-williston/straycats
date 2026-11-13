#!/usr/bin/env node
// Grant or revoke a role (for now: admin) on a Stray Cats user.
// Sets the custom claim (what the rules enforce) and writes roles/{uid} plus a history entry.
// Uses Application Default Credentials from `gcloud auth application-default login`.
// No key file is read or written.
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const PROJECT = 'straycats-love';
const ROLES = ['admin'];

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const [command, who, role = 'admin'] = args.filter((a) => !a.startsWith('--'));

function usage() {
  console.error(`Usage: node set-role.mjs <grant|revoke> <uid|email> [admin] [--dry-run]`);
  process.exit(1);
}
if (!['grant', 'revoke'].includes(command) || !who || !ROLES.includes(role)) usage();

initializeApp({ credential: applicationDefault(), projectId: PROJECT });
const auth = getAuth();
const db = getFirestore();

const user = who.includes('@') ? await auth.getUserByEmail(who) : await auth.getUser(who);
const on = command === 'grant';
const before = user.customClaims ?? {};
const claims = { ...before };
if (on) claims[role] = true;
else delete claims[role];

const roleDoc = db.doc(`roles/${user.uid}`);
const current = (await roleDoc.get()).data()?.roles ?? {};
const roles = { ...current, [role]: on };
const updatedBy = process.env.USER ? `script:${process.env.USER}` : 'script';

console.log(`Project: ${PROJECT}${dryRun ? '  (dry run, nothing written)' : ''}`);
console.log(`User:    ${user.uid}${user.email ? ` <${user.email}>` : ''}`);
console.log(`Action:  ${command} ${role}`);
console.log(`Claims:  ${JSON.stringify(before)} -> ${JSON.stringify(claims)}`);
console.log(`roles/${user.uid}.roles: ${JSON.stringify(current)} -> ${JSON.stringify(roles)}`);

if (!dryRun) {
  await auth.setCustomUserClaims(user.uid, claims);
  await roleDoc.set({ roles, updatedAt: FieldValue.serverTimestamp(), updatedBy });
  const h = await roleDoc.collection('history').add({
    role, granted: on, updatedAt: FieldValue.serverTimestamp(), updatedBy,
  });
  console.log(`Wrote claim, roles/${user.uid} and history/${h.id}.`);
  console.log('The person must sign out and in, or the app must refresh the token, to see it.');
}
