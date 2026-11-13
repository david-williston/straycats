// Run with: firebase emulators:exec --only firestore,storage --project demo-straycats "npm test"
import { test, before, after, beforeEach, describe } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, collection, setDoc, writeBatch, deleteDoc,
  serverTimestamp, Timestamp,
} from 'firebase/firestore';
import { ref, uploadBytes, getBytes } from 'firebase/storage';

const PROJECT = 'demo-straycats';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    storageBucket: `${PROJECT}.appspot.com`,
    firestore: { rules: readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8080 },
    storage: { rules: readFileSync('../storage.rules', 'utf8'), host: '127.0.0.1', port: 9199 },
  });
});
after(async () => env.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
});

const alice = () => env.authenticatedContext('alice').firestore();
const bob = () => env.authenticatedContext('bob').firestore();
const anon = () => env.unauthenticatedContext().firestore();

const catDoc = (db, id = 'c1') => doc(db, 'users/alice/cats', id);
const encDoc = (db, id = 'e1') => doc(db, 'users/alice/encounters', id);
const cat = (extra = {}) => ({ name: 'Ninja', updatedAt: serverTimestamp(), ...extra });
const enc = (extra = {}) => ({
  catId: 'c1',
  photoId: 'e1',
  takenAt: Timestamp.fromDate(new Date('2025-06-01T10:00:00Z')),
  type: 'fed',
  updatedAt: serverTimestamp(),
  ...extra,
});

async function seedCat() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/alice/cats/c1'), { name: 'Ninja', updatedAt: Timestamp.now() });
    await setDoc(doc(ctx.firestore(), 'users/alice/encounters/e1'), {
      catId: 'c1', photoId: 'e1', takenAt: Timestamp.now(), updatedAt: Timestamp.now(),
    });
  });
}

describe('firestore cats', () => {
  test('owner creates, reads, updates and deletes a cat', async () => {
    await assertSucceeds(setDoc(catDoc(alice()), cat()));
    await assertSucceeds(getDoc(catDoc(alice())));
    await assertSucceeds(setDoc(catDoc(alice()), cat({ name: 'Ciccio' })));
    await assertSucceeds(deleteDoc(catDoc(alice())));
  });
  test('owner can list own cats', async () => {
    await assertSucceeds(getDocs(collection(alice(), 'users/alice/cats')));
    await assertSucceeds(getDocs(collection(alice(), 'users/alice/encounters')));
  });
  test('empty name is allowed', async () => {
    await assertSucceeds(setDoc(catDoc(alice()), cat({ name: '' })));
  });
  test('other user and signed-out are denied', async () => {
    await seedCat();
    for (const db of [bob(), anon()]) {
      await assertFails(getDoc(catDoc(db)));
      await assertFails(getDocs(collection(db, 'users/alice/cats')));
      await assertFails(setDoc(catDoc(db, 'c2'), cat()));
      await assertFails(setDoc(catDoc(db), cat({ name: 'Mine now' })));
      await assertFails(deleteDoc(catDoc(db)));
    }
  });
  test('extra field, missing field, wrong types, long name denied', async () => {
    await assertFails(setDoc(catDoc(alice()), cat({ color: 'black' })));
    await assertFails(setDoc(catDoc(alice()), { name: 'Ninja' }));
    await assertFails(setDoc(catDoc(alice()), cat({ name: 42 })));
    await assertFails(setDoc(catDoc(alice()), cat({ name: 'x'.repeat(101) })));
    await assertFails(setDoc(catDoc(alice()), cat({ updatedAt: Timestamp.fromDate(new Date('2020-01-01')) })));
  });
  test('bad cat id denied', async () => {
    await assertFails(setDoc(catDoc(alice(), 'bad id!'), cat()));
    await assertFails(setDoc(catDoc(alice(), 'x'.repeat(65)), cat()));
  });
  test('unknown path denied', async () => {
    await assertFails(setDoc(doc(alice(), 'users/alice/other/x'), { a: 1 }));
    await assertFails(setDoc(doc(alice(), 'users/alice'), { a: 1 }));
  });
});

describe('firestore encounters', () => {
  test('new cat and first encounter in one batch', async () => {
    const db = alice();
    const b = writeBatch(db);
    b.set(catDoc(db), cat());
    b.set(encDoc(db), enc());
    await assertSucceeds(b.commit());
  });
  test('owner reads, updates (move to another cat) and deletes', async () => {
    await seedCat();
    await assertSucceeds(getDoc(encDoc(alice())));
    await assertSucceeds(setDoc(encDoc(alice()), enc({ type: 'seen' })));
    await assertSucceeds(deleteDoc(encDoc(alice())));
  });
  test('encounter without photo or type is allowed', async () => {
    await seedCat();
    const { photoId, type, ...rest } = enc();
    await assertSucceeds(setDoc(encDoc(alice(), 'e2'), rest));
  });
  test('every known type is allowed', async () => {
    await seedCat();
    for (const type of ['seen', 'fed', 'unwell', 'kittens', 'ear_tipped']) {
      await assertSucceeds(setDoc(encDoc(alice(), `t-${type}`), enc({ type })));
    }
  });
  test('other user and signed-out are denied', async () => {
    await seedCat();
    for (const db of [bob(), anon()]) {
      await assertFails(getDoc(encDoc(db)));
      await assertFails(getDocs(collection(db, 'users/alice/encounters')));
      await assertFails(setDoc(encDoc(db, 'e9'), enc()));
      await assertFails(deleteDoc(encDoc(db)));
    }
  });
  test('unknown type denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ type: 'petted' })));
  });
  test('extra field, missing field, wrong types denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ note: 'hi' })));
    const { takenAt, ...noTaken } = enc();
    await assertFails(setDoc(encDoc(alice(), 'e2'), noTaken));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ takenAt: '2025-06-01' })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ catId: 7 })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ photoId: 'bad/id' })));
  });
  test('encounter for a missing cat denied', async () => {
    await assertFails(setDoc(encDoc(alice()), enc({ catId: 'ghost' })));
  });
  test('takenAt too old or in the future denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ takenAt: Timestamp.fromDate(new Date('1999-01-01')) })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ takenAt: Timestamp.fromDate(new Date(Date.now() + 3 * 86400000)) })));
  });
  test('client-supplied updatedAt denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ updatedAt: Timestamp.now() })));
  });
});

describe('storage photos', () => {
  const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
  const st = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).storage();
  const photo = (s, uid = 'alice', name = '123.jpg') => ref(s, `users/${uid}/photos/${name}`);
  const put = (s, path, bytes = jpeg, type = 'image/jpeg') =>
    uploadBytes(path, bytes, { contentType: type });

  test('owner uploads a jpeg and reads it back', async () => {
    await assertSucceeds(put(st('alice'), photo(st('alice'))));
    await assertSucceeds(getBytes(photo(st('alice'))));
  });
  test('owner can overwrite', async () => {
    await assertSucceeds(put(st('alice'), photo(st('alice'))));
    await assertSucceeds(put(st('alice'), photo(st('alice'))));
  });
  test('wrong content type denied', async () => {
    await assertFails(put(st('alice'), photo(st('alice')), jpeg, 'image/png'));
    await assertFails(put(st('alice'), photo(st('alice')), jpeg, 'text/html'));
  });
  test('empty and over-limit files denied', async () => {
    await assertFails(put(st('alice'), photo(st('alice')), new Uint8Array(0)));
    await assertFails(put(st('alice'), photo(st('alice')), new Uint8Array(10 * 1024 * 1024)));
  });
  test('bad file name denied', async () => {
    await assertFails(put(st('alice'), photo(st('alice'), 'alice', '123.png')));
    await assertFails(put(st('alice'), photo(st('alice'), 'alice', 'a b.jpg')));
  });
  test('other user and signed-out cannot upload to alice', async () => {
    await assertFails(put(st('bob'), photo(st('bob'))));
    await assertFails(put(st(null), photo(st(null))));
  });
  test('other user and signed-out cannot read alice photos', async () => {
    await assertSucceeds(put(st('alice'), photo(st('alice'))));
    await assertFails(getBytes(photo(st('bob'))));
    await assertFails(getBytes(photo(st(null))));
  });
  test('paths outside users/{uid}/photos denied', async () => {
    await assertFails(put(st('alice'), ref(st('alice'), 'users/alice/other/1.jpg')));
    await assertFails(put(st('alice'), ref(st('alice'), 'stray.jpg')));
  });
});
