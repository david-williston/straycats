// Tells you on Telegram which city and country a visitor of the Stray Cats
// site is in. The site sends one small "hit" per browser per day (see
// layouts/_partials/visitor-ping.html); Cloudflare adds the visitor's city and
// country to the request, so no IP address is read, kept or sent on.
//
// Secrets (set with `wrangler secret put`, never committed):
//   TELEGRAM_BOT_TOKEN  the token BotFather gave you
//   TELEGRAM_CHAT_ID    the chat that should receive the messages
// Variable (wrangler.toml):
//   ALLOWED_ORIGINS     comma separated sites allowed to send hits
//   PATH_PREFIX         hits for pages outside this path are refused

const BOT_PATTERN =
  /bot|crawl|spider|slurp|facebookexternalhit|preview|monitor|uptime|headless|lighthouse|curl|wget|python|go-http/i;

/** "CA" becomes the Canadian flag. Anything unexpected gives no flag. */
export function flag(country) {
  if (!/^[A-Z]{2}$/.test(country || '')) return '';
  return String.fromCodePoint(
    ...[...country].map((c) => 0x1f1e6 + c.charCodeAt(0) - 65),
  );
}

/** A page path that is safe to print: short, one line, no query string. */
export function cleanPath(raw) {
  const text = typeof raw === 'string' ? raw : '/';
  const path = text.split(/[?#]/)[0].replace(/[\r\n\t]/g, ' ').trim();
  return (path.startsWith('/') ? path : '/').slice(0, 120);
}

// What a real page path looks like: letters, digits, - . _ ~ / and the %
// escapes a browser uses for anything else. No spaces, so a forged hit cannot
// put a sentence or a link into the chat.
const PATH_PATTERN = /^\/[A-Za-z0-9\-._~%/]*$/;

/** True for a cleaned path that could be one of the site's own pages. */
export function isSitePath(path, prefix = '/') {
  return PATH_PATTERN.test(path) && path.startsWith(prefix);
}

/** The site's hostname, taken from an Origin that has already been allowed. */
export function hostOf(origin) {
  try {
    return new URL(origin).hostname;
  } catch {
    return '';
  }
}

export function message({ city, country, region }, path, host = '') {
  const where = [city, region && region !== city ? region : '', country]
    .filter(Boolean)
    .join(', ');
  return `${flag(country)} New visitor: ${where || 'somewhere unknown'}\n${host}${path}`.trim();
}

export default {
  async fetch(request, env, ctx) {
    const origin = request.headers.get('Origin') || '';
    const allowed = (env.ALLOWED_ORIGINS || 'https://david-williston.github.io')
      .split(',')
      .map((s) => s.trim());

    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }
    if (!allowed.includes(origin)) {
      return new Response('Forbidden', { status: 403 });
    }
    // Crawlers and monitors are not visitors.
    if (BOT_PATTERN.test(request.headers.get('User-Agent') || '')) {
      return new Response(null, { status: 204 });
    }
    if (!env.TELEGRAM_BOT_TOKEN || !env.TELEGRAM_CHAT_ID) {
      return new Response('Not configured', { status: 500 });
    }

    // The site's script always sends its page; anything else is not a visit.
    let path = '';
    try {
      path = cleanPath(JSON.parse((await request.text()).slice(0, 500)).path);
    } catch {}
    if (!isSitePath(path, env.PATH_PREFIX || '/')) {
      return new Response('Bad path', { status: 400 });
    }

    const cf = request.cf || {};
    const text = message(
      { city: cf.city, country: cf.country, region: cf.region },
      path,
      hostOf(origin),
    );

    ctx.waitUntil(
      fetch(
        `https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            chat_id: env.TELEGRAM_CHAT_ID,
            text,
            disable_notification: false,
          }),
        },
      ).catch(() => {}),
    );
    return new Response(null, { status: 204 });
  },
};
