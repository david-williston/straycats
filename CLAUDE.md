# Stray Cats

The project website for Stray Cats: a Hugo + PaperMod site in English (`/`) and Spanish
(`/es/`), published to GitHub Pages. See README.md for running locally, adding content,
photos, languages and releases.

```bash
npm run dev               # local server with change history and version
npm run release:dry-run   # show the version the next release would get
npm run deploy            # release: tag vYYYY.MM.DD[.N] and publish (see README)
```

## Conventions

- **Every change goes through a PR.** No commits directly to `main` (branch-protected: a PR is
  required, no approval needed while David is the only collaborator).
  - One short-lived branch per change, cut from an up-to-date `main`: `content/...`,
    `fix/...`, `docs/...`, `chore/...`. GitHub deletes it on merge; delete the local copy too.
  - Link the issue (`Fixes #n`) when there is one. Fixes found and made on the spot need no
    issue — the PR description is the record.
  - Keep PRs to one concern. Something unrelated noticed mid-task gets its own branch/PR, or an
    issue if it can wait — never folded into the current PR unless the current change needs it.
  - The **Build site** check (`.github/workflows/pr-build.yml`) must pass before merging.
  - Merge only when David says to.
- **Merging doesn't publish.** Releasing is a separate step from an up-to-date `main`
  (`npm run deploy`), so several merged PRs can go out in one release. Add the release's
  section to What's New (`content/whats-new.md` and `.es.md`), and `updated:` dates on
  changed pages, in a PR before releasing (see README).
- **Tags mean shipped**: `vYYYY.MM.DD[.N]` tags are created only by `scripts/release.mjs`.
- **Commit subjects are public.** The Change history page lists them, so write plain sentences
  for visitors ("Add the NotebookLM audio overviews"), not `feat:`-style prefixes.
- **Both languages, always.** Every content change goes into the `.md` and the `.es.md`, with
  `alt` text in each.
