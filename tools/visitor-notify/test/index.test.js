import test from 'node:test';
import { strict as eq } from 'node:assert';
import worker, { flag, cleanPath, isSitePath, hostOf, message } from '../src/index.js';

const env = {
  TELEGRAM_BOT_TOKEN: 'T',
  TELEGRAM_CHAT_ID: '42',
  ALLOWED_ORIGINS: 'https://david-williston.github.io',
  PATH_PREFIX: '/straycats/',
};

function hit({ origin = 'https://david-williston.github.io', ua = 'Mozilla/5.0', body, cf } = {}) {
  const request = new Request('https://w.example/', {
    method: 'POST',
    headers: { Origin: origin, 'User-Agent': ua },
    body: body ?? JSON.stringify({ path: '/straycats/posts/ninja/?x=1' }),
  });
  Object.defineProperty(request, 'cf', {
    value: cf ?? { city: 'Calgary', country: 'CA', region: 'Alberta' },
  });
  return request;
}

async function run(request, e = env) {
  const sent = [];
  const realFetch = globalThis.fetch;
  globalThis.fetch = async (url, init) => {
    sent.push({ url, body: JSON.parse(init.body) });
    return new Response('{}');
  };
  const pending = [];
  const res = await worker.fetch(request, e, { waitUntil: (p) => pending.push(p) });
  await Promise.all(pending);
  globalThis.fetch = realFetch;
  return { res, sent };
}

test('a visit is sent to Telegram with city, country, site and page', async () => {
  const { res, sent } = await run(hit());
  eq.equal(res.status, 204);
  eq.equal(sent.length, 1);
  eq.match(sent[0].url, /\/botT\/sendMessage$/);
  eq.equal(sent[0].body.chat_id, '42');
  eq.match(sent[0].body.text, /Calgary, Alberta, CA/);
  eq.match(sent[0].body.text, /\ndavid-williston\.github\.io\/straycats\/posts\/ninja\/$/);
  eq.doesNotMatch(sent[0].body.text, /x=1/);
});

test('other sites are refused and nothing is sent', async () => {
  const { res, sent } = await run(hit({ origin: 'https://evil.example' }));
  eq.equal(res.status, 403);
  eq.equal(sent.length, 0);
});

test('crawlers are ignored', async () => {
  const { res, sent } = await run(hit({ ua: 'Googlebot/2.1' }));
  eq.equal(res.status, 204);
  eq.equal(sent.length, 0);
});

test('only POST is accepted', async () => {
  const request = new Request('https://w.example/', { method: 'GET' });
  const { res } = await run(request);
  eq.equal(res.status, 405);
});

test('a missing location still reports a visit', async () => {
  const { sent } = await run(hit({ cf: {} }));
  eq.match(sent[0].body.text, /somewhere unknown/);
});

for (const [name, body] of [
  ['a broken body', '{not json'],
  ['a missing path', '{}'],
  ['a page outside the site', JSON.stringify({ path: '/other-project/' })],
  ['text in the path', JSON.stringify({ path: '/straycats/ buy now at evil.example' })],
  ['a link in the path', JSON.stringify({ path: '/straycats/<https://evil.example>' })],
]) {
  test(`${name} is refused and nothing is sent`, async () => {
    const { res, sent } = await run(hit({ body }));
    eq.equal(res.status, 400);
    eq.equal(sent.length, 0);
  });
}

test('Spanish and escaped page paths are accepted', async () => {
  for (const path of ['/straycats/es/comparte-tu-opinion/', '/straycats/es/ideas/se%C3%B1as/']) {
    const { res, sent } = await run(hit({ body: JSON.stringify({ path }) }));
    eq.equal(res.status, 204);
    eq.equal(sent.length, 1);
  }
});

test('flag, path and message helpers', () => {
  eq.equal(flag('CA'), '🇨🇦');
  eq.equal(flag('xx'), '');
  eq.equal(cleanPath('/a/b?c=d#e'), '/a/b');
  eq.equal(cleanPath('evil\nline'), '/');
  eq.ok(isSitePath('/straycats/', '/straycats/'));
  eq.ok(!isSitePath('/', '/straycats/'));
  eq.ok(!isSitePath('/straycats/a b/', '/straycats/'));
  eq.ok(isSitePath('/anything/'));
  eq.equal(hostOf('https://david-williston.github.io'), 'david-williston.github.io');
  eq.equal(hostOf('not a url'), '');
  eq.equal(message({ city: 'Paris', country: 'FR' }, '/'), '🇫🇷 New visitor: Paris, FR\n/');
  eq.equal(
    message({ city: 'Calgary', region: 'Alberta', country: 'CA' }, '/straycats/', 'david-williston.github.io'),
    '🇨🇦 New visitor: Calgary, Alberta, CA\ndavid-williston.github.io/straycats/',
  );
});
