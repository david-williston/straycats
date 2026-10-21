# Visitor notifications on Telegram

Sends a Telegram message such as

```
🇨🇦 New visitor: Calgary, Alberta, CA
david-williston.github.io/straycats/posts/ninja/
```

the first time each browser visits the Stray Cats site in a day.

This is a separate copy of the Worker built for evnsteven.app. It has its own
Cloudflare Worker (`straycats-visitor-notify`) but sends to the same Telegram bot
and chat, so the hostname in each message tells you which site the visitor is on.

How it works: the site (`layouts/_partials/visitor-ping.html`, included from
`extend_footer.html`) sends one small beacon to a Cloudflare Worker
(`src/index.js`). Cloudflare adds the visitor's city and country to the request,
and the Worker forwards a message to the Telegram bot. No IP address is read,
stored or forwarded, nothing is kept, and no cookie is set. Visitors with Do Not
Track or Global Privacy Control, crawlers, automated browsers and you (after
opening any page with `?ping=off` once) are skipped. It never runs on
`npm run dev` (the script checks the hostname).

## One-time setup

You need the existing bot token and chat id from evnsteven.app. Type them only
when Wrangler asks for them, never into a file.

1. **Deploy the Worker** (Wrangler already logged in):
   ```bash
   cd tools/visitor-notify
   npx wrangler deploy
   npx wrangler secret put TELEGRAM_BOT_TOKEN
   npx wrangler secret put TELEGRAM_CHAT_ID
   ```
   `deploy` prints the Worker's address, like
   `https://straycats-visitor-notify.evnsteven.workers.dev`.
2. **Test it**:
   ```bash
   curl -i -X POST -A 'Mozilla/5.0' -H 'Origin: https://david-williston.github.io' \
     -d '{"path":"/straycats/test/"}' https://straycats-visitor-notify.evnsteven.workers.dev
   ```
   You should get `204` and a Telegram message. The `-A` matters: curl's own
   user agent is skipped as a bot (still `204`, but no message).
3. **Turn it on.** Put that address in `visitorPingURL` under `params` in
   `hugo.yaml`, in a PR, then release the site (`npm run deploy`).
4. **Opt yourself out** on each browser you use: open
   `https://david-williston.github.io/straycats/?ping=off` once.

## Check it

```bash
cd tools/visitor-notify && npm test
```

## Privacy note

City and country are derived from the visitor's network address, which some
privacy laws treat as personal data even when it is not stored. Consider one
sentence on the site (both languages) saying it notes the city and country of
visits, without keeping any other details.

## Cheatsheet

**What it does.** A new visitor triggers a Telegram message like
`🇨🇦 New visitor: Calgary, Alberta, CA` plus the site and page. At most once a day
per browser. Crawlers, Do Not Track / Global Privacy Control visitors and the
owner (after `?ping=off`) are skipped. No IP address, cookie or personal data is
kept.

**Where things live**
- Worker: `https://straycats-visitor-notify.evnsteven.workers.dev` (Cloudflare free
  plan). Code is in this folder; name and allowed origin in `wrangler.toml`.
- Site script: `layouts/_partials/visitor-ping.html`, on while
  `params.visitorPingURL` in `hugo.yaml` is set. Not on the hidden NotebookLM
  page, which has no scripts.
- Secrets `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` live on Cloudflare only
  (the same values as evnsteven.app). Never commit them.
- `ALLOWED_ORIGINS` is `https://david-williston.github.io`. Every GitHub Pages
  project under that account shares that origin; if the site gets its own
  domain, add it there and change the hostname check in the site script.
- `PATH_PREFIX` is `/straycats/`. A hit is refused (`400 Bad path`) unless its
  page is under that path and looks like a real page path: letters, digits,
  `- . _ ~ /` and `%` escapes, no spaces. Anyone can forge a hit with curl (the
  Origin header is only enforced by browsers), so this keeps forged hits from
  putting text or links into the chat. Change it if the site moves.

**Do on each browser you use:** open
`https://david-williston.github.io/straycats/?ping=off` once.

**Off-switches, quickest first**
1. Mute the chat in Telegram (also mutes evnsteven.app, same chat).
2. Set `visitorPingURL: ""` in `hugo.yaml` and release the site.
3. Delete the `straycats-visitor-notify` Worker in the Cloudflare dashboard.
4. Send `/revoke` to @BotFather. This kills the shared token, so evnsteven.app
   stops too.

**Changing things** (run from this folder)
- Message wording: `message()` in `src/index.js`; update the tests to match.
- After changing `src/index.js` or `wrangler.toml`, redeploy the Worker; the
  site does not need a release.
- Update the Worker: `npx wrangler deploy`
- Replace a secret: `npx wrangler secret put TELEGRAM_BOT_TOKEN` (or
  `TELEGRAM_CHAT_ID`)
- Tests: `npm test`
- If Wrangler says it cannot write `node_modules/.cache`, make the local
  cache folder: `mkdir -p node_modules/.cache`.

**Costs and risks.** The free plan cannot bill you; at its daily limit the
Worker just stops until the next day. Worst case is a flood of messages. Possible
later: a cooldown (one message per city per 6 hours, 15 an hour cap, needs a KV
namespace).
