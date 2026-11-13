// Run with: firebase emulators:exec --only firestore,storage --project demo-straycats "npm test"
import { test, before, after, beforeEach, describe } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, collection, setDoc, updateDoc, deleteField, writeBatch, deleteDoc,
  serverTimestamp, Timestamp, GeoPoint,
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
const admin = () => env.authenticatedContext('root', { admin: true }).firestore();
const notAdmin = () => env.authenticatedContext('eve', { admin: false }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

const catDoc = (db, id = 'c1') => doc(db, 'users/alice/cats', id);
const encDoc = (db, id = 'e1') => doc(db, 'users/alice/encounters', id);
const cat = (extra = {}) => ({ name: 'Ninja', updatedAt: serverTimestamp(), ...extra });
const enc = (extra = {}) => ({
  catId: 'c1',
  photoId: 'e1',
  takenAt: Timestamp.fromDate(new Date('2025-06-01T10:00:00Z')),
  activity: 'eating',
  conditions: ['thin', 'limping'],
  care: ['fed'],
  note: 'Only eats if you sit with her',
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
  test('a cat can be missing, found or remembered, with a date and a note', async () => {
    const since = Timestamp.fromDate(new Date());
    for (const status of ['missing', 'found', 'remembered']) {
      await assertSucceeds(setDoc(catDoc(alice()), cat({ status, statusSince: since })));
      await assertSucceeds(setDoc(catDoc(alice()), cat({
        status, statusSince: since, statusNote: 'Last seen near the market on Tuesday',
      })));
    }
    await assertSucceeds(setDoc(catDoc(alice()), cat({ statusNote: 'x'.repeat(1000) })));
  });
  test('a status can be changed and cleared with an update', async () => {
    await seedCat();
    const since = Timestamp.fromDate(new Date());
    await assertSucceeds(updateDoc(catDoc(alice()), {
      status: 'missing', statusSince: since, updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(catDoc(alice()), {
      status: deleteField(), statusSince: deleteField(), statusNote: deleteField(),
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(catDoc(alice()), { name: 'Ciccio', updatedAt: serverTimestamp() }));
  });
  test('a bad status, date or note is denied', async () => {
    const since = Timestamp.fromDate(new Date());
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'dead', statusSince: since })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'known' })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 42 })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'missing', statusSince: 'yesterday' })));
    await assertFails(setDoc(catDoc(alice()), cat({
      status: 'missing', statusSince: Timestamp.fromDate(new Date(Date.now() + 3 * 86400000)),
    })));
    await assertFails(setDoc(catDoc(alice()), cat({
      status: 'missing', statusSince: Timestamp.fromDate(new Date('1990-01-01')),
    })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'missing', statusNote: 'x'.repeat(1001) })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'missing', statusNote: 42 })));
    await assertFails(setDoc(catDoc(alice()), cat({ status: 'missing', exactPlace: '1 Main St' })));
  });
  test('other users and admins cannot change a status', async () => {
    await seedCat();
    const change = { status: 'missing', statusSince: Timestamp.fromDate(new Date()), updatedAt: serverTimestamp() };
    await assertFails(updateDoc(catDoc(bob()), change));
    await assertFails(updateDoc(catDoc(admin()), change));
    await assertSucceeds(getDoc(catDoc(admin())));
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
    await assertSucceeds(setDoc(encDoc(alice()), enc({ activity: 'sleeping', conditions: [], care: [], note: '' })));
    await assertSucceeds(deleteDoc(encDoc(alice())));
  });
  test('encounter without photo or details is allowed', async () => {
    await seedCat();
    const { photoId, activity, conditions, care, note, ...rest } = enc();
    await assertSucceeds(setDoc(encDoc(alice(), 'e2'), rest));
  });
  test('every known activity, condition and care value is allowed', async () => {
    await seedCat();
    const activities = ['eating', 'sleeping', 'resting', 'waiting_at_door', 'playing', 'walking_by'];
    const conditions = ['healthy', 'thin', 'limping', 'unwell_or_injured', 'with_kittens', 'ear_tipped'];
    const care = ['fed', 'gave_water', 'took_to_vet', 'gave_medicine'];
    for (const activity of activities) {
      await assertSucceeds(setDoc(encDoc(alice(), `a-${activity}`), enc({ activity })));
    }
    await assertSucceeds(setDoc(encDoc(alice(), 'all-c'), enc({ conditions })));
    await assertSucceeds(setDoc(encDoc(alice(), 'all-k'), enc({ care })));
  });
  test('an old document with a type can still be read, but not written', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/alice/cats/c1'), { name: 'Ninja', updatedAt: Timestamp.now() });
      await setDoc(doc(ctx.firestore(), 'users/alice/encounters/old'), {
        catId: 'c1', photoId: 'old', takenAt: Timestamp.now(), type: 'fed', updatedAt: Timestamp.now(),
      });
    });
    await assertSucceeds(getDoc(encDoc(alice(), 'old')));
    await assertSucceeds(getDocs(collection(alice(), 'users/alice/encounters')));
    await assertFails(setDoc(encDoc(alice(), 'old'), enc({ type: 'fed' })));
    // Saving it again with the new fields replaces the whole document.
    await assertSucceeds(setDoc(encDoc(alice(), 'old'), enc({ photoId: 'old' })));
    await assertSucceeds(deleteDoc(encDoc(alice(), 'old')));
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
  test('unknown activity, condition or care value denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ activity: 'petted' })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ activity: ['eating'] })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ conditions: ['fed'] })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ care: ['thin'] })));
  });
  test('lists must be lists and no longer than the allowed values', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ conditions: 'thin' })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ care: 'fed' })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ care: ['fed', 'fed', 'fed', 'fed', 'fed'] })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({
      conditions: ['healthy', 'thin', 'limping', 'unwell_or_injured', 'with_kittens', 'ear_tipped', 'thin'],
    })));
  });
  test('note must be a string of at most 1000 characters', async () => {
    await seedCat();
    await assertSucceeds(setDoc(encDoc(alice(), 'e2'), enc({ note: 'x'.repeat(1000) })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ note: 'x'.repeat(1001) })));
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ note: 42 })));
  });
  test('area must be a geohash of exactly 6 characters, neighbourhood at most 80', async () => {
    await seedCat();
    await assertSucceeds(setDoc(encDoc(alice(), 'p1'), enc({ area: '9g3q4k' })));
    await assertSucceeds(setDoc(encDoc(alice(), 'p2'), enc({ area: '9g3q4k', neighbourhood: 'Rinconada' })));
    await assertSucceeds(setDoc(encDoc(alice(), 'p3'), enc({ area: 'ezs42b', neighbourhood: 'x'.repeat(80) })));
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9g3q4kx' })));   // 7 chars: too fine
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9g3q4' })));     // 5 chars
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9g3q4a' })));    // 'a' not in the alphabet
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9G3Q4K' })));    // upper case
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: 123456 })));
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9g3q4k', neighbourhood: 'x'.repeat(81) })));
    await assertFails(setDoc(encDoc(alice(), 'p4'), enc({ area: '9g3q4k', neighbourhood: 7 })));
  });
  test('exact coordinates are denied in any form', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'g1'), enc({ location: new GeoPoint(19.43, -99.13) })));
    await assertFails(setDoc(encDoc(alice(), 'g2'), enc({ lat: 19.43, lng: -99.13 })));
    await assertFails(setDoc(encDoc(alice(), 'g3'), enc({ area: new GeoPoint(19.43, -99.13) })));
  });
  test('place can be removed by saving without it, and admin can read it', async () => {
    await seedCat();
    await assertSucceeds(setDoc(encDoc(alice(), 'p1'), enc({ area: '9g3q4k', neighbourhood: 'Rinconada' })));
    await assertSucceeds(setDoc(encDoc(alice(), 'p1'), enc()));
    await assertSucceeds(getDoc(doc(admin(), 'users/alice/encounters/p1')));
    await assertFails(getDoc(doc(bob(), 'users/alice/encounters/p1')));
  });
  test('the old type field is no longer accepted', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ type: 'fed' })));
  });
  test('extra field, missing field, wrong types denied', async () => {
    await seedCat();
    await assertFails(setDoc(encDoc(alice(), 'e2'), enc({ mood: 'hi' })));
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

describe('firestore profile', () => {
  const profile = (db, uid = 'alice') => doc(db, 'users', uid);
  const seedProfile = (data = {}) => env.withSecurityRulesDisabled((ctx) =>
    setDoc(doc(ctx.firestore(), 'users/alice'), { createdAt: Timestamp.fromDate(new Date('2025-06-01')), ...data }));

  test('owner creates a profile, with or without nickname', async () => {
    await assertSucceeds(setDoc(profile(alice()), { createdAt: serverTimestamp() }));
    await assertSucceeds(getDoc(profile(alice())));
    await env.clearFirestore();
    await assertSucceeds(setDoc(profile(alice()), { createdAt: serverTimestamp(), nickname: 'Dave' }));
  });
  test('create denied for others, bad createdAt, extra fields, bad nickname', async () => {
    await assertFails(setDoc(profile(bob(), 'alice'), { createdAt: serverTimestamp() }));
    await assertFails(setDoc(profile(anon()), { createdAt: serverTimestamp() }));
    await assertFails(setDoc(profile(alice()), { createdAt: Timestamp.now() }));
    await assertFails(setDoc(profile(alice()), { nickname: 'Dave' }));
    await assertFails(setDoc(profile(alice()), { createdAt: serverTimestamp(), admin: true }));
    await assertFails(setDoc(profile(alice()), { createdAt: serverTimestamp(), nickname: '' }));
    await assertFails(setDoc(profile(alice()), { createdAt: serverTimestamp(), nickname: 'x'.repeat(41) }));
    await assertFails(setDoc(profile(alice()), { createdAt: serverTimestamp(), nickname: 5 }));
  });
  test('owner updates nickname but createdAt is immutable', async () => {
    await seedProfile();
    const created = Timestamp.fromDate(new Date('2025-06-01'));
    await assertSucceeds(setDoc(profile(alice()), { createdAt: created, nickname: 'Dave' }));
    await assertSucceeds(setDoc(profile(alice()), { createdAt: created, nickname: 'x'.repeat(40) }));
    await assertFails(setDoc(profile(alice()), { createdAt: created, nickname: 'x'.repeat(41) }));
    await assertFails(setDoc(profile(alice()), { createdAt: created, nickname: '' }));
    await assertFails(setDoc(profile(alice()), { createdAt: Timestamp.now(), nickname: 'Dave' }));
    await assertFails(setDoc(profile(alice()), { createdAt: serverTimestamp(), nickname: 'Dave' }));
    await assertFails(setDoc(profile(alice()), { createdAt: created, role: 'admin' }));
  });
  test('others cannot update; nobody deletes', async () => {
    await seedProfile();
    const created = Timestamp.fromDate(new Date('2025-06-01'));
    await assertFails(setDoc(profile(bob()), { createdAt: created, nickname: 'Hax' }));
    await assertFails(deleteDoc(profile(alice())));
    await assertFails(deleteDoc(profile(bob())));
    await assertFails(deleteDoc(profile(admin())));
  });
  test('only owner and admin read a profile', async () => {
    await seedProfile();
    await assertSucceeds(getDoc(profile(alice())));
    await assertSucceeds(getDoc(profile(admin())));
    await assertFails(getDoc(profile(bob())));
    await assertFails(getDoc(profile(notAdmin())));
    await assertFails(getDoc(profile(anon())));
  });
  test('admin can list users; others cannot', async () => {
    await seedProfile();
    await assertSucceeds(getDocs(collection(admin(), 'users')));
    await assertFails(getDocs(collection(bob(), 'users')));
    await assertFails(getDocs(collection(alice(), 'users')));
  });
});

describe('firestore admin access is read-only', () => {
  test('admin reads other people\'s cats and encounters', async () => {
    await seedCat();
    await assertSucceeds(getDoc(catDoc(admin())));
    await assertSucceeds(getDocs(collection(admin(), 'users/alice/cats')));
    await assertSucceeds(getDoc(encDoc(admin())));
    await assertSucceeds(getDocs(collection(admin(), 'users/alice/encounters')));
  });
  test('admin false or missing claim does not read', async () => {
    await seedCat();
    await assertFails(getDoc(catDoc(notAdmin())));
    await assertFails(getDoc(encDoc(notAdmin())));
    await assertFails(getDocs(collection(bob(), 'users/alice/cats')));
  });
  test('admin cannot write or delete other people\'s data', async () => {
    await seedCat();
    await assertFails(setDoc(catDoc(admin(), 'c2'), cat()));
    await assertFails(setDoc(catDoc(admin()), cat({ name: 'Renamed' })));
    await assertFails(deleteDoc(catDoc(admin())));
    await assertFails(setDoc(encDoc(admin(), 'e9'), enc()));
    await assertFails(setDoc(encDoc(admin()), enc({ note: 'x' })));
    await assertFails(deleteDoc(encDoc(admin())));
  });
  test('admin writes to own area still follow owner rules', async () => {
    const root = env.authenticatedContext('root', { admin: true }).firestore();
    await assertSucceeds(setDoc(doc(root, 'users/root/cats/c1'), cat()));
  });
});

describe('firestore roles', () => {
  const role = (db, uid = 'alice') => doc(db, 'roles', uid);
  const hist = (db, uid = 'alice') => doc(db, `roles/${uid}/history`, 'h1');
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'roles/alice'), { roles: { admin: false }, updatedAt: Timestamp.now(), updatedBy: 'x' });
      await setDoc(doc(ctx.firestore(), 'roles/alice/history/h1'), { at: Timestamp.now() });
    });
  });
  test('owner and admin read; others denied', async () => {
    await assertSucceeds(getDoc(role(alice())));
    await assertSucceeds(getDoc(role(admin())));
    await assertSucceeds(getDoc(hist(alice())));
    await assertSucceeds(getDoc(hist(admin())));
    await assertFails(getDoc(role(bob())));
    await assertFails(getDoc(hist(bob())));
    await assertFails(getDoc(role(anon())));
  });
  test('nobody writes roles from a client, not even admin or the owner', async () => {
    for (const db of [alice(), bob(), admin(), anon()]) {
      await assertFails(setDoc(role(db), { roles: { admin: true } }));
      await assertFails(setDoc(role(db, 'bob'), { roles: { admin: true } }));
      await assertFails(deleteDoc(role(db)));
      await assertFails(setDoc(hist(db), { at: Timestamp.now() }));
      await assertFails(deleteDoc(hist(db)));
    }
  });
});

describe('storage admin access', () => {
  const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
  const adminSt = () => env.authenticatedContext('root', { admin: true }).storage();
  const st = (uid) => env.authenticatedContext(uid).storage();
  const p = (s, uid = 'alice') => ref(s, `users/${uid}/photos/1.jpg`);
  test('admin reads others\' photos but cannot write them', async () => {
    await assertSucceeds(uploadBytes(p(st('alice')), jpeg, { contentType: 'image/jpeg' }));
    await assertSucceeds(getBytes(p(adminSt())));
    await assertFails(getBytes(p(st('bob'))));
    await assertFails(uploadBytes(p(adminSt()), jpeg, { contentType: 'image/jpeg' }));
  });
});
