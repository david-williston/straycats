// Writes the git commit history to data/git_history.json for the
// Change history page (content/change-history.md, the git-history shortcode).
// Run automatically by `npm run build` and `npm run dev`.
//
// Each commit is assigned to the release it first shipped in: the oldest
// calendar-version tag (vYYYY.MM.DD or vYYYY.MM.DD.N) that contains it. Releases
// are tagged on merge commits (one per pull request), so containment is worked out
// from the commit graph rather than from the order of the log. Merge commits
// themselves are left out of the list. Commits in no release have `release: null`.

import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';

const FIELD = '\x1f';
const RECORD = '\x1e';
const VERSION_TAG = /^v\d{4}\.\d{2}\.\d{2}(\.\d+)?$/;

const git = (...args) => execFileSync('git', args, { encoding: 'utf8' });

let log = '';
try {
    log = git(
        'log', '--no-merges',
        `--format=%H${FIELD}%h${FIELD}%aI${FIELD}%s${FIELD}%b${RECORD}`
    );
} catch (error) {
    console.warn(`git-history: could not read git log (${error.message.split('\n')[0]}); writing an empty history`);
}

// Drop trailers such as "Co-Authored-By:" and "Signed-off-by:" from commit bodies.
const TRAILER = /^[A-Za-z-]+-By: .*$|^Signed-off-by: .*$/gim;

// Compares vYYYY.MM.DD[.N] tags so a later same-day release sorts last.
const versionKey = (tag) => tag.slice(1).split('.').map(Number);
const compareVersions = (a, b) => {
    const [ka, kb] = [versionKey(a), versionKey(b)];
    for (let i = 0; i < Math.max(ka.length, kb.length); i += 1) {
        const diff = (ka[i] ?? -1) - (kb[i] ?? -1);
        if (diff) return diff;
    }
    return 0;
};

// Release date for each tag: when the tag was created (annotated) or its commit date.
const tagDates = {};
try {
    for (const line of git('for-each-ref', '--format=%(refname:short) %(creatordate:iso-strict)', 'refs/tags/').split('\n')) {
        const [tag, date] = line.split(' ');
        if (tag && VERSION_TAG.test(tag)) tagDates[tag] = date;
    }
} catch {
    // No tags yet.
}

// Walk the releases oldest first; each claims the commits it contains that no earlier release did.
const releaseOf = {};
const released = [];
for (const tag of Object.keys(tagDates).sort(compareVersions)) {
    const range = [`${tag}^{commit}`, ...released.map((t) => `^${t}^{commit}`)];
    for (const hash of git('rev-list', ...range).split('\n').filter(Boolean)) releaseOf[hash] = tag;
    released.push(tag);
}

const commits = log
    .split(RECORD)
    .map((entry) => entry.trim())
    .filter(Boolean)
    .map((entry) => {
        const [hash, short, date, subject, body = ''] = entry.split(FIELD);
        const release = releaseOf[hash] ?? null;
        return {
            hash,
            short,
            date,
            subject,
            body: body.replace(TRAILER, '').trim(),
            release,
            releaseDate: release ? tagDates[release] ?? null : null
        };
    });

// Group by release, newest first (unreleased commits on top), keeping date order within each.
// A branch commit can be older than a release it wasn't part of, so log order alone would split groups.
const rank = (c) => (c.release === null ? Infinity : released.indexOf(c.release));
commits.sort((a, b) => rank(b) - rank(a));

// Current site version: the newest release tag on HEAD, or the latest release plus
// "+dev" when building unreleased changes (npm run dev, preview deploys).
const headTags = released.length ? git('tag', '--points-at', 'HEAD').split('\n').filter((t) => VERSION_TAG.test(t)) : [];
const headReleased = headTags.length > 0;
const latest = headReleased ? headTags.sort(compareVersions).at(-1) : released.at(-1) ?? null;
const siteVersion = {
    version: latest ? (headReleased ? latest : `${latest}+dev`) : 'unreleased',
    released: headReleased
};

mkdirSync('data', { recursive: true });
writeFileSync('data/git_history.json', JSON.stringify(commits, null, 2) + '\n');
writeFileSync('data/site_version.json', JSON.stringify(siteVersion, null, 2) + '\n');
const releases = new Set(commits.map((c) => c.release).filter(Boolean));
console.log(`git-history: wrote ${commits.length} commits in ${releases.size} releases; site version ${siteVersion.version}`);
