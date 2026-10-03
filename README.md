# Stray Cats 🐾

An open-source, non-profit idea about how communities could identify, remember and care for
the cats nobody owns (and, one day, dogs).

> **There is no app here (yet).** Stray Cats is at the concept stage: the ideas are still
> being formed, and no software has been written, [on purpose](https://david-williston.github.io/straycats/posts/all-talk-no-code/).
> This repository holds only the project's **website**, a notebook of stories and ideas.
> Cloning it won't give you anything to run except that website.

## Get involved

The most useful thing right now is your experience and your opinion, not code:

- **Read** the stories and ideas: <https://david-williston.github.io/straycats/>
  ([en español](https://david-williston.github.io/straycats/es/))
- **Tell me what I'm missing**: reply to any story by email, or start a conversation in
  [Discussions](https://github.com/david-williston/straycats/discussions)
- **Suggest a correction or a new idea** in [Issues](https://github.com/david-williston/straycats/issues)

If you're a developer, designer or rescuer who'd like to help build it one day, say hi in
Discussions. When there's software to work on, it will be announced on the site.

---

## Working on the website

The rest of this README is for editing the website itself, built with
[Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
theme. You only need it to change the site's pages, text or design.

### Run locally

```sh
git clone --recurse-submodules https://github.com/david-williston/straycats.git
cd straycats
npm run dev           # http://localhost:1313 (or: hugo server -D)
```

If you already cloned without submodules: `git submodule update --init --recursive`.

### Add content

```sh
hugo new content ideas/my-idea.md     # a new idea
hugo new content posts/my-story.md    # a new story
```

New files start as `draft: true`; set it to `false` to publish.

The home page lists stories, then ideas, in `weight` order (stories 1–99, ideas 100+), and
the previous/next links follow the same order. Give a new story the next number after the
last one, and a new idea a weight in the hundreds.

### Photos

Pages with photos are *page bundles*: a folder holding `index.md`, `index.es.md` and the
images, shared by both languages.

```
content/posts/the-cats-nobody-owns/
  index.md        index.es.md
  cover.jpg       # landscape (3:2) cover, set in front matter under `cover:`
  vet-visit.jpg   # inline photo
```

In the text:

```
{{</* photo src="vet-visit.jpg" alt="…" caption="…" */>}}
{{</* gallery images="a.jpg b.jpg c.jpg" alt="…" caption="…" */>}}   # add anchor="Top" if heads get cropped
{{</* gallery images="a.jpg b.jpg" alts="Ciccio, a black cat | Tenkilo, a cream cat" caption="…" */>}}   # one description per photo
```

Hugo resizes and converts images at build time. Always write `alt` text (in each language),
and name the cats in it when you know who they are.

### Languages

The site is in **English** (`/`) and **Spanish** (`/es/`). Each page has a translation
alongside it with a `.es.md` suffix:

```
content/posts/the-cats-nobody-owns.md      # English
content/posts/the-cats-nobody-owns.es.md   # Español (give it a Spanish `slug:`)
```

Menus and the home page intro are per language in `hugo.yaml`; the "Respond to this idea"
box text lives in `i18n/`. In content, link to pages by their English path
(e.g. `[feedback](/feedback/)`): links resolve to the right language automatically.

### Making changes

Every change goes through a pull request; `main` is protected. Cut a short-lived branch from
an up-to-date `main` (`content/...`, `fix/...`, `docs/...`, `chore/...`), open a PR, and merge
it once the **Build site** check passes. GitHub deletes the branch on merge. Merging doesn't publish the site;
releasing does (below). See CLAUDE.md for the full conventions.

### Deploy: versioning and releases

Pushing to `main` does **not** publish the site. Publishing is a release:

```sh
npm run release:dry-run   # show which version would be created
npm run deploy            # tag, build, and publish
```

Releases use calendar versions, tagged in git: `vYYYY.MM.DD` for the first release of a day
(Puerto Escondido time), then `vYYYY.MM.DD.1`, `.2` and so on. `npm run deploy` runs
`scripts/release.mjs`, which:

1. Refuses to release if there are uncommitted changes, you're not on `main`, or `main`
   isn't pushed to `origin`.
2. Tags `HEAD` with the next version (or redeploys the existing tag if `HEAD` is already
   released).
3. Builds the site locally, to catch errors before anything is published.
4. Pushes the tag. `.github/workflows/hugo.yml` then builds and deploys it to GitHub Pages
   (follow it with `gh run watch`). If the build or push fails, the new tag is deleted.

Before releasing, add a `### vYYYY.MM.DD · Month D, YYYY` section to the hand-written notes
in `content/release-notes.md` and `content/release-notes.es.md`. The change history below
the notes is built from the commit messages and grouped by release automatically
(`scripts/git-history.mjs`). The footer shows the current version, with `+dev` on builds
that include unreleased changes.

Use `npm run dev` instead of `hugo server` to see the change history and version locally.

The repo's `github-pages` environment must allow deploys from `v*` tags (Settings →
Environments → github-pages → Deployment branches and tags).
