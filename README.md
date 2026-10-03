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

## Deploy

Pushing to `main` builds and deploys to GitHub Pages via `.github/workflows/hugo.yml`
(enable Pages → Source: "GitHub Actions" in the repo settings).
