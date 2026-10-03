# Stray Cats 🐾

An open-source, non-profit project to help communities spot, identify and track stray
cats (and dogs). This repo currently holds the project's website — a place to collect
thoughts, feedback and ideas — built with [Hugo](https://gohugo.io/) and the
[PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme.

## Run locally

```sh
git clone --recurse-submodules https://github.com/david-williston/straycats.git
cd straycats
hugo server -D        # http://localhost:1313
```

If you already cloned without submodules: `git submodule update --init --recursive`.

## Add content

```sh
hugo new content ideas/my-idea.md     # a new idea
hugo new content posts/my-update.md   # a news update
```

New files start as `draft: true`; set it to `false` to publish.

## Languages

The site is in **English** (`/`) and **Spanish** (`/es/`). Each page has a translation
alongside it with a `.es.md` suffix:

```
content/posts/the-cats-nobody-owns.md      # English
content/posts/the-cats-nobody-owns.es.md   # Español (give it a Spanish `slug:`)
```

Menus and the home page intro are per language in `hugo.yaml`; the "Respond to this idea"
box text lives in `i18n/`. In content, link to pages by their English path
(e.g. `[feedback](/feedback/)`): links resolve to the right language automatically.

## Deploy

Pushing to `main` builds and deploys to GitHub Pages via `.github/workflows/hugo.yml`
(enable Pages → Source: "GitHub Actions" in the repo settings).
