import test from 'node:test';
import { strict as eq } from 'node:assert';
import worker, { flag, cleanPath, hostOf, message } from '../src/index.js';

const env = {
  TELEGRAM_BOT_TOKEN: 'T',
  TELEGRAM_CHAT_ID: '42',
  ALLOWED_ORIGINS: 'https://david-williston.github.io',
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

test('a broken body still reports a visit, on the home page', async () => {
  const { sent } = await run(hit({ body: '{not json' }));
  eq.match(sent[0].body.text, /\ndavid-williston\.github\.io\/$/);
});

test('flag, path and message helpers', () => {
  eq.equal(flag('CA'), '🇨🇦');
  eq.equal(flag('xx'), '');
  eq.equal(cleanPath('/a/b?c=d#e'), '/a/b');
  eq.equal(cleanPath('evil\nline'), '/');
  eq.equal(hostOf('https://david-williston.github.io'), 'david-williston.github.io');
  eq.equal(hostOf('not a url'), '');
  eq.equal(message({ city: 'Paris', country: 'FR' }, '/'), '🇫🇷 New visitor: Paris, FR\n/');
  eq.equal(
    message({ city: 'Calgary', region: 'Alberta', country: 'CA' }, '/straycats/', 'david-williston.github.io'),
    '🇨🇦 New visitor: Calgary, Alberta, CA\ndavid-williston.github.io/straycats/',
  );
});
