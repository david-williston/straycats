// Publishes the site as a calendar-versioned release (`npm run deploy`).
//
//   1. Checks the working tree is clean and main is pushed to origin.
//   2. Tags HEAD vYYYY.MM.DD (Puerto Escondido time), or vYYYY.MM.DD.N for the
//      Nth extra release that day. If HEAD is already tagged, redeploys that tag.
//   3. Builds the site locally, to catch errors before anything is published.
//   4. Pushes the tag. GitHub Actions (.github/workflows/hugo.yml) then builds
//      and deploys that tag to GitHub Pages. If the build or push fails, a
//      newly created tag is removed.
//
// Usage: npm run deploy   (or: node scripts/release.mjs --dry-run)

import { execFileSync } from 'node:child_process';

const DRY_RUN = process.argv.includes('--dry-run');
const TIME_ZONE = 'America/Mexico_City'; // Puerto Escondido (Oaxaca) is on Central time
const VERSION_TAG = /^v\d{4}\.\d{2}\.\d{2}(\.\d+)?$/;

// With stdio: 'inherit' the output goes to the terminal and execFileSync returns null.
const run = (cmd, args, opts = {}) => (execFileSync(cmd, args, { encoding: 'utf8', ...opts }) ?? '').trim();
const git = (...args) => run('git', args);
const step = (message) => console.log(`\n▸ ${message}`);
const fail = (message) => {
    console.error(`\n✖ ${message}`);
    process.exit(1);
};

// --- 1. Preflight -----------------------------------------------------------

const branch = git('rev-parse', '--abbrev-ref', 'HEAD');
if (branch !== 'main') fail(`Releases are made from main (currently on ${branch}).`);

if (git('status', '--porcelain')) {
    fail('There are uncommitted changes. Commit (and push) them first, so the release matches the repository.');
}

step('Checking main is pushed to origin');
git('fetch', '--quiet', '--tags', 'origin');
const head = git('rev-parse', 'HEAD');
const remote = git('rev-parse', 'origin/main');
if (head !== remote) fail('main and origin/main differ. Push (or pull) first: git push');

// --- 2. Version tag ---------------------------------------------------------

const existing = git('tag', '--points-at', 'HEAD').split('\n').filter((t) => VERSION_TAG.test(t));
let version;
let created = false;

if (existing.length) {
    version = existing.sort((a, b) => Number(a.split('.')[3] ?? 0) - Number(b.split('.')[3] ?? 0)).at(-1);
    step(`HEAD is already released as ${version}; redeploying it`);
} else {
    const today = new Intl.DateTimeFormat('en-CA', {
        timeZone: TIME_ZONE, year: 'numeric', month: '2-digit', day: '2-digit'
    }).format(new Date()).replaceAll('-', '.');
    const sameDay = git('tag', '--list', `v${today}`, `v${today}.*`).split('\n').filter(Boolean);
    const suffixes = sameDay.map((t) => (t === `v${today}` ? 0 : Number(t.split('.').at(3))));
    version = sameDay.length ? `v${today}.${Math.max(...suffixes) + 1}` : `v${today}`;

    step(`Tagging ${git('log', '-1', '--format=%h %s')} as ${version}`);
    if (!DRY_RUN) {
        git('tag', '-a', version, '-m', `Release ${version}`);
        created = true;
    }
}

if (DRY_RUN) {
    console.log(`\nDry run: would build ${version} locally, then push the tag so GitHub Actions deploys it.`);
    process.exit(0);
}

// --- 3–4. Build, then publish the tag ---------------------------------------

try {
    step('Building');
    run('npm', ['run', 'build'], { stdio: 'inherit' });

    step(`Pushing tag ${version} (GitHub Actions deploys it)`);
    if (existing.length) {
        // Re-running the workflow for an existing tag: trigger it by hand.
        run('gh', ['workflow', 'run', 'hugo.yml', '--ref', version], { stdio: 'inherit' });
    } else {
        git('push', '--quiet', 'origin', version);
    }
} catch (error) {
    if (created) {
        git('tag', '-d', version);
        console.error(`\nRemoved tag ${version} because the release did not complete.`);
    }
    fail(`Release failed: ${error.message.split('\n')[0]}`);
}

console.log(`\n✔ Released ${version}. Follow the deploy with: gh run watch`);
